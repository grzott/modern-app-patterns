# modern-app-patterns

Practical, copy‑pasteable patterns for modern app development. Every guide has a live, end‑to‑end example you can drop into a project (modder’s approach: copy, paste, tweak).

Currently covers React Native (TypeScript), Android (Kotlin/Compose), iOS (Swift/SwiftUI), .NET (Minimal API/MAUI), and Flutter (Dart). More tech can be added later.

## What’s inside

- Architecture: MVVM, MVI, Clean Architecture
- State: Redux Toolkit, Zustand, React Query, StateFlow/Flow, ObservableObject
- Data: Repository + DTO/Codable/Retrofit/Room/HttpClient; caching (AsyncStorage/MMKV, IMemoryCache/IDistributedCache)
- DI & Navigation: Hilt, protocol-based DI, React Navigation, Expo Router, Jetpack, Coordinators, MediatR
- Live examples: Copy/paste flows for each pattern

## Browse by platform

- React Native: see `react-native/README.md`
- Android (Kotlin): see `android-kotlin/README.md`
- iOS (Swift): see `ios-swift/README.md`
- .NET (C#): see `dotnet/README.md`
- Flutter (Dart): see `flutter/README.md`

## Quick start

1. Pick a pattern from the platform index (for example, React Query in RN).
2. Use a sandbox starter from `sandboxes/` to run quickly, or your own app.
3. Copy the live end‑to‑end example into your app and tweak names/URLs/types.

## How to navigate

- Each page starts with the pattern idea, then a focused example.
- “Live end-to-end example” sections provide minimal, runnable flows.
- Notes call out trade‑offs, tips, and when to use the pattern.

## Sandboxes

- See `sandboxes/README.md` for tiny starters: Expo (RN), Minimal API/.NET, MAUI, Android Compose, SwiftUI, and Flutter.

## Contributing

- PRs for new patterns, fixes, or additional platforms are welcome.
- Keep examples short, idiomatic, and ready to paste.
