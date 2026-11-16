import 'package:atmos_domain/atmos_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../components/message_view.dart';
import '../error_message.dart';
import '../formatting/weather_formatter.dart';
import '../l10n/app_localizations.dart';
import '../theme/atmos_colors.dart';
import '../weather/condition_ui.dart';
import 'cities_state.dart';

/// Cities (US-04, US-05): the search field, then either the results or the saved places.
///
/// A visible remove button instead of a swipe, as in the React Native app: it works with every
/// screen reader, and the behaviour (remove, then Undo) is what US-05 asks for.
class CitiesView extends StatefulWidget {
  const CitiesView({required this.state, required this.onEvent, super.key});

  final CitiesState state;
  final ValueChanged<CitiesEvent> onEvent;

  @override
  State<CitiesView> createState() => _CitiesViewState();
}

/// The only state here is the text field's controller, a Flutter detail; the query itself
/// lives in [CitiesState] and the controller follows it.
class _CitiesViewState extends State<CitiesView> {
  late final _query = TextEditingController(text: widget.state.query);

  @override
  void didUpdateWidget(CitiesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_query.text != widget.state.query) _query.text = widget.state.query;
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _send(CitiesEvent event) => widget.onEvent(event);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = widget.state;
    final notice = state.notice;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.citiesTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.all(AtmosSpacing.m),
            child: TextField(
              key: const Key('cities.search'),
              controller: _query,
              onChanged: (text) => _send(CitiesQueryChanged(text)),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.citiesSearchPrompt,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: state.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: l10n.actionClearSearch,
                        onPressed: () => _send(const CitiesQueryChanged('')),
                      ),
              ),
            ),
          ),
          Expanded(child: _body(state, l10n)),
          if (notice != null) _NoticeBar(notice: notice, onUndo: () => _send(const CitiesUndo())),
        ],
      ),
    );
  }

  Widget _body(CitiesState state, AppLocalizations l10n) => switch (state.search) {
    SearchIdle() => _Places(state: state, onEvent: _send),
    Searching() => const Center(child: CircularProgressIndicator()),
    NoSearchResults() => MessageView(icon: '🔍', message: l10n.citiesNoResults),
    SearchFailed(:final error) => switch (errorMessage(error, l10n)) {
      // A cancelled search was replaced by a newer one: nothing to say.
      null => const Center(child: CircularProgressIndicator()),
      final message => MessageView(
        icon: '⚠️',
        message: message,
        action: (title: l10n.actionRetry, onPressed: () => _send(const CitiesRetrySearch())),
      ),
    },
    SearchResults(:final cities) => ListView(
      key: const Key('cities.results'),
      children: [
        for (final city in cities)
          ListTile(
            key: Key('result-${city.id}'),
            title: Text(city.name),
            subtitle: _placeLine(city) == null ? null : Text(_placeLine(city) ?? ''),
            trailing: IconButton(
              key: Key('cities.add.${city.id}'),
              icon: const Icon(Icons.add),
              tooltip: l10n.citiesAdd(city.name),
              onPressed: () => _send(CitiesAdd(city)),
            ),
          ),
      ],
    ),
  };
}

/// "İstanbul · Türkiye": the region and the country, when known.
String? _placeLine(City city) {
  final parts = [?city.region, ?city.country];
  return parts.isEmpty ? null : parts.join(' · ');
}

class _Places extends StatelessWidget {
  const _Places({required this.state, required this.onEvent});

  final CitiesState state;
  final ValueChanged<CitiesEvent> onEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AtmosColors.of(context);
    final format = WeatherFormatter(Localizations.localeOf(context).languageCode);
    final onlyCurrent = state.places.length <= 1;
    return ListView(
      key: const Key('cities.places'),
      children: [
        for (final item in state.places)
          ListTile(
            key: Key(placeKey(item.place)),
            leading: switch (item.place) {
              CurrentLocation() => const ExcludeSemantics(child: Text('📍')),
              SavedPlace() => null,
            },
            title: Text(switch (item.place) {
              CurrentLocation() => l10n.homeCurrentLocation,
              SavedPlace(:final city) => city.name,
            }),
            subtitle: switch (item.place) {
              SavedPlace(:final city) when _placeLine(city) != null => Text(_placeLine(city) ?? ''),
              _ => null,
            },
            onTap: () => onEvent(CitiesSelect(item.place)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.temperature case final temperature?)
                  Text(format.temperature(temperature, state.temperatureUnit)),
                if (item.condition case final condition?)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: AtmosSpacing.xs),
                    child: Text(conditionIcon(condition)),
                  ),
                // The current location cannot be removed (US-05).
                if (item.place case SavedPlace(:final city))
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    tooltip: l10n.citiesRemove(city.name),
                    onPressed: () => onEvent(CitiesRemove(city)),
                  ),
              ],
            ),
          ),
        if (onlyCurrent)
          Padding(
            padding: const EdgeInsetsDirectional.all(AtmosSpacing.m),
            child: Text(
              l10n.citiesEmptySaved,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.secondaryText),
            ),
          ),
      ],
    );
  }
}

class _NoticeBar extends StatelessWidget {
  const _NoticeBar({required this.notice, required this.onUndo});

  final CitiesNotice notice;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AtmosColors.of(context);
    final notice = this.notice;
    return Semantics(
      liveRegion: true,
      child: Material(
        key: const Key('cities.notice'),
        color: colors.surface,
        elevation: 2,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: AtmosSpacing.m),
            child: Row(
              children: [
                Expanded(
                  child: Text(switch (notice) {
                    CityRemoved(:final city) => l10n.citiesRemoved(city.name),
                    CityAlreadySaved(:final city) => l10n.citiesAlreadySaved(city.name),
                  }),
                ),
                if (notice is CityRemoved)
                  TextButton(onPressed: onUndo, child: Text(l10n.citiesUndo)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
