# modern-app-patterns

Practical, copy‑pasteable patterns for modern app development. Every guide has a live, end‑to‑end example you can drop into a project (modder’s approach: copy, paste, tweak).

## Features

- Live, minimal examples for each pattern—ready to copy and run
- Covers multiple platforms: React Native, Android, iOS, .NET, Flutter
- Sandboxes for each tech to try patterns instantly
- Consistent structure: pattern intro, focused code, live end-to-end, copy map
- Modern best practices: typed navigation, pluggable adapters, testable flows

## What’s inside

- Architecture: MVVM, MVI, Clean Architecture, UDF, Coordinator
- State: Redux Toolkit, Zustand, React Query, StateFlow/Flow, Bloc, Riverpod, ObservableObject
- Data: Repository + DTO/Codable/Retrofit/Room/HttpClient/Dio; caching (AsyncStorage/MMKV, IMemoryCache/IDistributedCache, SharedPreferences, Hive)
- Dependency Injection: Hilt, get_it, protocol-based DI, built-in DI
- Navigation: React Navigation, Expo Router, Jetpack, go_router, Coordinators
- UI: Compound components/widgets, state hoisting, SwiftUI state
- Live examples: Copy/paste flows for each pattern

## How to use

1. Pick a pattern from the platform index (see below).
2. Open the matching sandbox in `sandboxes/` or use your own app.
3. Copy the “Live end-to-end example” into your app, following the copy map.
4. Add any required dependencies (see pattern or sandbox README).
5. Run and tweak for your needs.

## Supported platforms & patterns

| Platform          | Language(s) | Patterns & Features                                                                |
| ----------------- | ----------- | ---------------------------------------------------------------------------------- |
| React Native      | TypeScript  | MVVM+UDF, Redux Toolkit, Zustand, React Query, Repository+DTO, DI, Caching, Nav    |
| Android (Compose) | Kotlin      | MVVM, MVI, Clean, Repository+Retrofit+Room, Hilt, Flow, Navigation, State Hoisting |
| iOS (SwiftUI)     | Swift       | MVVM, Clean, Repository+Codable, DI, Coordinator, Concurrency, SwiftUI State       |
| .NET (API/MAUI)   | C#          | MVVM, Clean, Repository+DTO+HttpClient, Caching, DI, MediatR, Minimal API, MAUI    |
| Flutter           | Dart        | MVVM+UDF, Bloc, Riverpod, Repository+Dio+DTO, get_it, Caching, go_router, Widgets  |

## Browse by platform

- [React Native](react-native/README.md)
- [Android (Kotlin)](android-kotlin/README.md)
- [iOS (Swift)](ios-swift/README.md)
- [.NET (C#)](dotnet/README.md)
- [Flutter (Dart)](flutter/README.md)

## Sandboxes

Tiny starter projects for each platform:

- [React Native (Expo)](sandboxes/react-native-expo/)
- [.NET Minimal API](sandboxes/dotnet-minimal-api/)
- [.NET MAUI](sandboxes/dotnet-maui/)
- [Android (Compose)](sandboxes/android-compose/)
- [iOS (SwiftUI)](sandboxes/ios-swiftui/)
- [Flutter](sandboxes/flutter/)

See [sandboxes/README.md](sandboxes/README.md) for setup and run instructions.

## Contributing

Contributions are welcome! To add a new pattern, fix an example, or support a new platform:

- Keep examples short, idiomatic, and ready to paste into a sandbox or real app.
- Add a “Live end-to-end example” and a “Sandbox copy map” section to new pages.
- Update the relevant README and sandbox if you add a new pattern or tech.
- Open a PR with a clear description and sample usage if possible.

## License

MIT License. See [LICENSE](LICENSE) for details.
