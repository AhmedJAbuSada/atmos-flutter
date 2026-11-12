# Prompts — step 02: project structure (Flutter)

| Task | Instruction |
|---|---|
| Project | "Install the current stable Flutter, generate the app with `flutter create --platforms android,ios`, and read the template's pubspec and imports before changing anything." → found `material_ui` (ADR-0013). |
| Ids | "Application id and bundle id `dev.ahmedabusada.atmos.flutter`; Android 8.0 and iOS 17 as minimums (NF-09)." |
| Layers | "One package per layer in a pub workspace. The domain has no dependencies. Step 01 showed what a workspace does not stop: close those gaps." → `depend_on_referenced_packages` as an error + `tool/source_rules`. |
| Rules | "No lint knows Dart's locale-less `toUpperCase()` or `left`/`right` in layouts. Write a small checker with tests; no ignore comments; comments and strings must not trigger it." |
| Proof | "Break each rule once, in every layer, capture the real output for the guide, then remove the violations." |
| CI | "Fast checks first (format, analyze with fatal infos, source rules, every package's tests), then the Android and iOS builds without signing. Reuse the React Native repo's annotation script. Pin the Flutter version." |
