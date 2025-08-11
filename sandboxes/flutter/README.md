# Flutter Sandbox

Drop-in place to run the Flutter pattern pages quickly.

## Files

- pubspec.yaml: minimal deps; add packages as the pattern requires
- lib/main.dart: replace with the page's Live example `main.dart`
- lib/: create folders/files matching the page (e.g., `data/`, `ui/`, `nav/`)

## Dependencies

Start minimal and add as needed:

- dio
- flutter_riverpod
- flutter_bloc
- go_router
- get_it
- shared_preferences
- hive, hive_flutter, hive_generator, build_runner (optional)

## Run

- Ensure Flutter SDK is installed and device/emulator is running.
- From this folder:
  - flutter pub get
  - flutter run

Tip: Update `pubspec.yaml` when you copy a pattern that uses a new package.
