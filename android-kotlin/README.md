# Android (Kotlin) Patterns

Battle-tested patterns for modern Android apps.

- Architecture
  - [MVVM with StateFlow](./architecture-mvvm-stateflow.md)
  - [MVI with sealed intents](./architecture-mvi.md)
  - [Clean Architecture (UseCases/Repo)](./architecture-clean.md)
- Data & Concurrency
  - [Repository + Retrofit + Room](./repository-retrofit-room.md)
  - [Coroutines + Flow basics](./coroutines-flow.md)
- DI & Navigation
  - [DI with Hilt](./di-hilt.md)
  - [Navigation with Jetpack](./navigation-jetpack.md)
- UI
  - [Compose state hoisting](./ui-compose-state-hoisting.md)

## Try it

Quickstart a new Compose project in Android Studio (recommended). Or via CLI:

```powershell
# Using Gradle init (Kotlin/JVM project; then add Android bits in Studio)
gradle init --type kotlin-application

# Or create in Android Studio: New Project → Empty Activity → Jetpack Compose
# Then paste files from the guides into appropriate packages (ui/, data/, di/).
```

Tips

- For Hilt, add the Gradle plugins and dependencies, annotate `@HiltAndroidApp` on your Application, and use `hiltViewModel()` in composables.
- For Retrofit/Moshi/Room, add dependencies and DI modules from the guides, and point base URLs to jsonplaceholder for quick tests.

See also: `../sandboxes/android-compose` for a minimal Gradle/Compose skeleton you can open in Android Studio.
