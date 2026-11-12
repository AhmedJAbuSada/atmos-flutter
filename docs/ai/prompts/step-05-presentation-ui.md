# Prompts — step 05: presentation (Flutter)

| Task | Instruction |
|---|---|
| Views | "Port the React Native views to Flutter: Home, Cities, Settings, About take a sealed state and report sealed events. No view models, no navigation yet." |
| Strings | "Convert the React Native texts (from the iOS app) to ARB with a script, keep the Arabic plural forms, mark Turkish and Arabic as AI-written and not reviewed. Test that every key and placeholder exists in all three." |
| Probe first | "Before the formatter, print what `intl` gives for Arabic digits, Turkish times and percents. Before gen-l10n, read how `material_ui` expects localizations." |
| Formatting | "Directional isolates around every value; Latin digits for Arabic; Turkish `07:46` and `%69`; times at the place." |
| Theme | "Light and dark tokens with a WCAG AA test; start/end only." |
| Tests | "Every state in en, tr and ar; dark mode; 200% text. Query what the user sees or hears." |
| Language | "The OS owns the language. Declare the languages to Android and iOS. Check that Flutter picks the language the way the other apps do." |
