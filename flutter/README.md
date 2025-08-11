# Flutter (Dart) Patterns

Quick, modder-friendly recipes for common Flutter patterns. Copy, paste, tweak.

- Architecture & State
  - [MVVM + UDF with ValueNotifier/StateNotifier](./architecture-mvvm-udf.md)
  - [App State with Bloc](./state-app-bloc.md)
  - [App/Feature State with Riverpod](./state-app-riverpod.md)
  - [Server State with Riverpod + Dio](./state-server-riverpod-dio.md)
- Data & DI
  - [Repository + DTO mapping (Dio)](./repository-dio-dto.md)
  - [DI with get_it](./di-with-get_it.md)
  - [Local caching (SharedPreferences/Hive)](./caching-sharedprefs-hive.md)
- UI & Navigation
  - [Navigation with go_router](./navigation-go_router.md)
  - [Compound Widgets](./component-compound-widgets.md)

Tip: keep examples in a `/sandbox` app and promote stable pieces into `core/`.

## Try it

- Use the Flutter sandbox in `sandboxes/flutter/` to run any example quickly.
- Copy the “Live end-to-end example” from a page into the sandbox `lib/` and update `main.dart` as shown.

See `sandboxes/flutter/README.md` for dependency hints and run steps.
