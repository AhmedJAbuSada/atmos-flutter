import 'package:atmos_domain/atmos_domain.dart';
import 'package:atmos_presentation/atmos_presentation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/pump.dart';

City cityOf(int id, String name, {String? region, String? country}) => City(
  id: id,
  name: name,
  region: region,
  country: country,
  coordinates: Coordinates.validated(41, 29) ?? (throw StateError('valid')),
);

final istanbul = cityOf(745044, 'İstanbul', region: 'İstanbul', country: 'Türkiye');
final ankara = cityOf(323786, 'Ankara', country: 'Türkiye');

void main() {
  for (final language in languages) {
    group('[$language] Cities', () {
      late AppLocalizations l10n;
      setUp(() async => l10n = await l10nFor(language));

      Future<Events<CitiesEvent>> show(WidgetTester tester, CitiesState state) async {
        final events = Events<CitiesEvent>();
        await pumpView(
          tester,
          CitiesView(state: state, onEvent: events.call),
          language: language,
        );
        return events;
      }

      testWidgets('with no saved city, the current location is alone and a hint follows', (
        tester,
      ) async {
        await show(tester, const CitiesState());
        expect(find.text(l10n.homeCurrentLocation), findsOneWidget);
        expect(find.text(l10n.citiesEmptySaved), findsOneWidget);
      });

      testWidgets('saved cities follow the current location, which cannot be removed (US-05)', (
        tester,
      ) async {
        final events = await show(
          tester,
          CitiesState(
            places: [
              const PlaceItem(CurrentLocation()),
              PlaceItem(
                SavedPlace(ankara),
                temperature: const Temperature(12),
                condition: WeatherCondition.rain,
              ),
            ],
          ),
        );
        final current = tester.getTopLeft(find.byKey(const Key('current')));
        final saved = tester.getTopLeft(find.byKey(Key('city-${ankara.id}')));
        expect(current.dy, lessThan(saved.dy));
        expect(find.text('\u206612°\u2069'), findsOneWidget);
        expect(find.byTooltip(l10n.citiesRemove(ankara.name)), findsOneWidget);
        expect(
          find.byIcon(Icons.remove_circle_outline),
          findsOneWidget,
        ); // none for the current location
        await tester.tap(find.byTooltip(l10n.citiesRemove(ankara.name)));
        await tester.tap(find.text('Ankara'));
        await tester.tap(find.text(l10n.homeCurrentLocation));
        expect(events.sent, [
          isA<CitiesRemove>().having((e) => e.city, 'city', ankara),
          isA<CitiesSelect>().having((e) => e.place, 'place', SavedPlace(ankara)),
          isA<CitiesSelect>().having((e) => e.place, 'place', const CurrentLocation()),
        ]);
      });

      testWidgets('typing reports the query; the clear button empties it', (tester) async {
        final events = await show(tester, const CitiesState(query: 'is'));
        await tester.enterText(find.byKey(const Key('cities.search')), 'ista');
        await tester.tap(find.byTooltip(l10n.actionClearSearch));
        expect(events.sent, [
          isA<CitiesQueryChanged>().having((e) => e.query, 'query', 'ista'),
          isA<CitiesQueryChanged>().having((e) => e.query, 'query', ''),
        ]);
      });

      testWidgets('results show the name, region and country, with Add (US-04)', (tester) async {
        final events = await show(
          tester,
          CitiesState(query: 'ista', search: SearchResults([istanbul])),
        );
        expect(find.text('İstanbul · Türkiye'), findsOneWidget);
        await tester.tap(find.byTooltip(l10n.citiesAdd('İstanbul')));
        expect(events.sent, [isA<CitiesAdd>().having((e) => e.city, 'city', istanbul)]);
      });

      testWidgets('searching shows progress', (tester) async {
        await show(tester, const CitiesState(query: 'ista', search: Searching()));
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('no match is a message, not an error (US-04)', (tester) async {
        await show(tester, const CitiesState(query: 'zzzz', search: NoSearchResults()));
        expect(find.text(l10n.citiesNoResults), findsOneWidget);
        expect(find.text(l10n.actionRetry), findsNothing);
      });

      testWidgets('a failed search offers a retry (US-04)', (tester) async {
        final events = await show(
          tester,
          const CitiesState(query: 'ista', search: SearchFailed(NoConnection())),
        );
        expect(find.text(l10n.errorNoConnection), findsOneWidget);
        await tester.tap(find.text(l10n.actionRetry));
        expect(events.sent, [isA<CitiesRetrySearch>()]);
      });

      testWidgets('a cancelled search shows no error', (tester) async {
        await show(tester, const CitiesState(query: 'ista', search: SearchFailed(Cancelled())));
        expect(find.text(l10n.actionRetry), findsNothing);
      });

      testWidgets('after a removal, Undo is offered (US-05)', (tester) async {
        final events = await show(tester, CitiesState(notice: CityRemoved(ankara)));
        expect(find.text(l10n.citiesRemoved('Ankara')), findsOneWidget);
        await tester.tap(find.text(l10n.citiesUndo));
        expect(events.sent, [isA<CitiesUndo>()]);
      });

      testWidgets('adding a saved city again says so, with no Undo', (tester) async {
        await show(tester, CitiesState(notice: CityAlreadySaved(ankara)));
        expect(find.text(l10n.citiesAlreadySaved('Ankara')), findsOneWidget);
        expect(find.text(l10n.citiesUndo), findsNothing);
      });
    });
  }

  testWidgets('a new query from the view model replaces the text in the field', (tester) async {
    await pumpView(
      tester,
      CitiesView(
        state: const CitiesState(query: 'ista'),
        onEvent: (_) {},
      ),
    );
    await pumpView(tester, CitiesView(state: const CitiesState(), onEvent: (_) {}));
    expect(find.text('ista'), findsNothing);
  });
}
