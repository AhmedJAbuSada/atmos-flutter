import 'package:atmos_domain/atmos_domain.dart';
import 'package:material_ui/material_ui.dart';

import '../components/message_view.dart';
import '../error_message.dart';
import '../formatting/weather_formatter.dart';
import '../l10n/app_localizations.dart';
import '../theme/atmos_colors.dart';
import '../weather/condition_ui.dart';
import 'home_state.dart';

/// Home (US-01, US-02, US-03, US-07): state in, events out. No view model, no navigation.
class HomeView extends StatelessWidget {
  const HomeView({required this.state, required this.onEvent, super.key});

  final HomeState state;
  final ValueChanged<HomeEvent> onEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = this.state;
    return Scaffold(
      appBar: AppBar(
        title: switch (state) {
          HomeContent(:final placeName) => Text(placeName ?? l10n.homeCurrentLocation),
          _ => null,
        },
        centerTitle: true,
        leading: IconButton(
          key: const Key('home.openCities'),
          icon: const Icon(Icons.list),
          tooltip: l10n.homeOpenCities,
          onPressed: () => onEvent(const HomeOpenCities()),
        ),
        actions: [
          IconButton(
            key: const Key('home.openSettings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.homeOpenSettings,
            onPressed: () => onEvent(const HomeOpenSettings()),
          ),
        ],
      ),
      body: switch (state) {
        HomeLoading() => const _HomeSkeleton(),
        HomeNeedsLocation() => MessageView(
          icon: '📍',
          title: l10n.homeNoLocationTitle,
          message: l10n.homeNoLocationMessage,
          action: (
            title: l10n.homeAllowLocation,
            onPressed: () => onEvent(const HomeRequestLocation()),
          ),
          secondaryAction: (
            title: l10n.homeSearchCity,
            onPressed: () => onEvent(const HomeOpenCities()),
          ),
        ),
        HomeFailed(:final error) => switch (errorMessage(error, l10n)) {
          // A cancelled load is never shown (ADR-0006): keep the skeleton.
          null => const _HomeSkeleton(),
          final message => MessageView(
            icon: '⚠️',
            message: message,
            action: (title: l10n.actionRetry, onPressed: () => onEvent(const HomeRetry())),
            secondaryAction: (
              title: l10n.homeSearchCity,
              onPressed: () => onEvent(const HomeOpenCities()),
            ),
          ),
        },
        final HomeContent content => _HomeForecast(
          content: content,
          onRefresh: () => onEvent(const HomeRefresh()),
        ),
      },
    );
  }
}

class _HomeForecast extends StatelessWidget {
  const _HomeForecast({required this.content, required this.onRefresh});

  final HomeContent content;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AtmosColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final HomeContent(:forecast, :settings) = content;
    final format = WeatherFormatter(
      Localizations.localeOf(context).languageCode,
      utcOffset: forecast.utcOffset,
    );
    final today = forecast.daily
        .where((day) => format.sameDay(day.date, forecast.current.time))
        .firstOrNull;
    final outdatedBy = content.outdatedBy;
    final (sunrise, sunset) = (today?.sunrise, today?.sunset);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView(
        key: const Key('home.forecast'),
        padding: const EdgeInsetsDirectional.all(AtmosSpacing.m),
        children: [
          if (content.refreshing) const LinearProgressIndicator(),
          if (outdatedBy != null)
            Semantics(
              liveRegion: true,
              child: Container(
                key: const Key('home.outdated'),
                padding: const EdgeInsetsDirectional.all(AtmosSpacing.s),
                decoration: BoxDecoration(
                  color: colors.warningBackground,
                  borderRadius: BorderRadius.circular(AtmosSpacing.s),
                ),
                child: Text(
                  '⚠️ ${_updatedAgoText(updatedAgo(outdatedBy), l10n)}',
                  style: textTheme.bodyMedium?.copyWith(color: colors.warningText),
                ),
              ),
            ),
          _CurrentConditions(forecast: forecast, settings: settings, format: format),
          if (sunrise != null && sunset != null)
            Text(
              '🌅 ${l10n.homeSunriseSunset(format.time(sunrise), format.time(sunset))}',
              key: const Key('home.sun'),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colors.secondaryText),
            ),
          _SectionHeader(l10n.homeNext24Hours),
          SizedBox(
            height: 132 * MediaQuery.textScalerOf(context).scale(1),
            child: ListView(
              key: const Key('home.hourly'),
              scrollDirection: Axis.horizontal,
              children: [
                for (final (index, hour) in forecast.hourly.indexed)
                  _HourCell(
                    hour: hour,
                    label: index == 0 ? l10n.homeNow : format.time(hour.time),
                    settings: settings,
                    format: format,
                  ),
              ],
            ),
          ),
          _SectionHeader(l10n.homeNext7Days),
          Column(
            key: const Key('home.daily'),
            children: [
              for (final day in forecast.daily)
                _DayRow(
                  day: day,
                  label: day == today ? l10n.homeToday : format.dayName(day.date),
                  range: _weekRange(forecast.daily),
                  settings: settings,
                  format: format,
                ),
            ],
          ),
          const SizedBox(height: AtmosSpacing.m),
          Text(
            l10n.homeAttribution,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: colors.secondaryText),
          ),
        ],
      ),
    );
  }
}

String _updatedAgoText(({UpdatedAgoUnit unit, int count}) ago, AppLocalizations l10n) =>
    switch (ago.unit) {
      UpdatedAgoUnit.minutes => l10n.homeUpdatedMinutes(ago.count),
      UpdatedAgoUnit.hours => l10n.homeUpdatedHours(ago.count),
      UpdatedAgoUnit.days => l10n.homeUpdatedDays(ago.count),
    };

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: AtmosSpacing.l, bottom: AtmosSpacing.s),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    ),
  );
}

class _CurrentConditions extends StatelessWidget {
  const _CurrentConditions({required this.forecast, required this.settings, required this.format});

  final Forecast forecast;
  final UserSettings settings;
  final WeatherFormatter format;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AtmosColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final current = forecast.current;
    final condition = conditionLabel(current.condition, l10n);
    final temperature = format.temperature(current.temperature, settings.temperatureUnit);
    final feelsLike = l10n.homeFeelsLike(
      format.temperature(current.feelsLike, settings.temperatureUnit),
    );
    final humidity = l10n.homeHumidity(format.percentage(current.humidityPercent));
    final wind = l10n.homeWind(format.windSpeed(current.windSpeed, settings.windSpeedUnit));
    final secondary = textTheme.bodyLarge?.copyWith(color: colors.secondaryText);
    return Semantics(
      key: const Key('home.current'),
      container: true,
      label: '$temperature, $condition, $feelsLike, $humidity, $wind',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: AtmosSpacing.l),
        child: Column(
          children: [
            Text(
              conditionIcon(current.condition, isDay: current.isDay),
              style: textTheme.displayMedium,
            ),
            Text(temperature, style: textTheme.displayLarge),
            Text(condition, style: textTheme.titleLarge),
            const SizedBox(height: AtmosSpacing.s),
            Text('$feelsLike · $humidity', style: secondary, textAlign: TextAlign.center),
            Text(wind, style: secondary, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _HourCell extends StatelessWidget {
  const _HourCell({
    required this.hour,
    required this.label,
    required this.settings,
    required this.format,
  });

  final HourlyForecast hour;
  final String label;
  final UserSettings settings;
  final WeatherFormatter format;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AtmosColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final temperature = format.temperature(hour.temperature, settings.temperatureUnit);
    // 0% is noise: the chance is shown only when there is one (US-02).
    final chance = switch (hour.precipitationChancePercent) {
      final percent? when percent > 0 => format.percentage(percent),
      _ => null,
    };
    final spoken = [
      label,
      temperature,
      conditionLabel(hour.condition, l10n),
      if (chance != null) l10n.homePrecipitationChance(chance),
    ].join(', ');
    return Semantics(
      label: spoken,
      excludeSemantics: true,
      child: Container(
        width: 72,
        margin: const EdgeInsetsDirectional.only(end: AtmosSpacing.s),
        padding: const EdgeInsetsDirectional.all(AtmosSpacing.s),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.bodySmall?.copyWith(color: colors.secondaryText)),
            Text(conditionIcon(hour.condition), style: textTheme.titleLarge),
            Text(temperature, style: textTheme.bodyLarge),
            Text(chance ?? ' ', style: textTheme.bodySmall?.copyWith(color: colors.accent)),
          ],
        ),
      ),
    );
  }
}

/// The coldest and warmest temperatures of the week: the scale of every day's bar.
({double min, double max}) _weekRange(List<DailyForecast> days) {
  if (days.isEmpty) return (min: 0, max: 1);
  final min = days.map((day) => day.minTemperature.celsius).reduce((a, b) => a < b ? a : b);
  final max = days.map((day) => day.maxTemperature.celsius).reduce((a, b) => a > b ? a : b);
  return (min: min, max: max > min ? max : min + 1);
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.label,
    required this.range,
    required this.settings,
    required this.format,
  });

  final DailyForecast day;
  final String label;
  final ({double min, double max}) range;
  final UserSettings settings;
  final WeatherFormatter format;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AtmosColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final low = format.temperature(day.minTemperature, settings.temperatureUnit);
    final high = format.temperature(day.maxTemperature, settings.temperatureUnit);
    final span = range.max - range.min;
    final start = (day.minTemperature.celsius - range.min) / span;
    final width = ((day.maxTemperature.celsius - day.minTemperature.celsius) / span).clamp(
      0.04,
      1.0,
    );
    return Semantics(
      label: '$label, ${conditionLabel(day.condition, l10n)}, ${l10n.homeLowHigh(low, high)}',
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AtmosSpacing.minTouchTarget),
        child: Row(
          children: [
            Expanded(flex: 3, child: Text(label, style: textTheme.bodyLarge, maxLines: 1)),
            Text(conditionIcon(day.condition), style: textTheme.titleMedium),
            const SizedBox(width: AtmosSpacing.s),
            SizedBox(
              width: 44,
              child: Text(
                low,
                textAlign: TextAlign.end,
                style: textTheme.bodyMedium?.copyWith(color: colors.secondaryText),
              ),
            ),
            const SizedBox(width: AtmosSpacing.s),
            // The bar runs from low to high, from the start edge: it mirrors in Arabic.
            Expanded(
              flex: 4,
              child: LayoutBuilder(
                builder: (context, constraints) => Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: colors.skeleton,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(start: constraints.maxWidth * start),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        width: constraints.maxWidth * width,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AtmosSpacing.s),
            SizedBox(width: 44, child: Text(high, style: textTheme.bodyLarge)),
          ],
        ),
      ),
    );
  }
}

/// The loading state keeps the layout of the content, so nothing jumps when data arrives.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AtmosColors.of(context);
    Widget block(double height) => Container(
      height: height,
      margin: const EdgeInsetsDirectional.only(bottom: AtmosSpacing.m),
      decoration: BoxDecoration(color: colors.skeleton, borderRadius: BorderRadius.circular(12)),
    );
    return Semantics(
      key: const Key('home.loading'),
      label: l10n.homeLoading,
      liveRegion: true,
      excludeSemantics: true,
      child: ListView(
        padding: const EdgeInsetsDirectional.all(AtmosSpacing.m),
        physics: const NeverScrollableScrollPhysics(),
        children: [block(200), block(24), block(120), block(48), block(48), block(48)],
      ),
    );
  }
}
