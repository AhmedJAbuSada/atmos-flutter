import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../theme/atmos_colors.dart';

/// What the user can do on About (US-10).
sealed class AboutEvent {
  const AboutEvent();
}

final class AboutOpenDataSource extends AboutEvent {
  const AboutOpenDataSource();
}

final class AboutOpenSourceCode extends AboutEvent {
  const AboutOpenSourceCode();
}

/// About (US-10, F-11): the Open-Meteo attribution the licence requires, the version and the
/// source code.
class AboutView extends StatelessWidget {
  const AboutView({required this.version, required this.onEvent, super.key});

  final String version;
  final ValueChanged<AboutEvent> onEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AtmosColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AtmosSpacing.m),
        children: [
          Text('Atmos', textAlign: TextAlign.center, style: textTheme.headlineMedium),
          Text(
            l10n.aboutVersion(version),
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(color: colors.secondaryText),
          ),
          const SizedBox(height: AtmosSpacing.l),
          ListTile(
            key: const Key('about.dataSource'),
            title: Text(l10n.aboutDataSource),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => onEvent(const AboutOpenDataSource()),
          ),
          ListTile(
            key: const Key('about.sourceCode'),
            title: Text(l10n.aboutSourceCode),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => onEvent(const AboutOpenSourceCode()),
          ),
          ListTile(title: Text(l10n.aboutLicense)),
        ],
      ),
    );
  }
}
