# Android (Compose) Sandbox

Instructions for trying Compose/Hilt/Retrofit patterns in a fresh project.

## Setup

- Create a new project in Android Studio: Empty Activity with Jetpack Compose.
- Ensure Kotlin, Compose, and Hilt plugins are enabled.

## Paste from guides

- ui/: composables and view models (MVVM, MVI, state hoisting)
- data/: Api.kt, DTOs, Room entities, repositories
- di/: Hilt modules
- navigation/: NavHost and screens

## Tips

- Add Hilt dependencies and annotate Application with @HiltAndroidApp.
- Use `collectAsStateWithLifecycle()` from lifecycle-runtime-compose.
- Point Retrofit base URL to jsonplaceholder for quick tests.

### Gradle wrapper & keystores

- Generate a wrapper in your project root if missing:

```powershell
# In your Android project root
gradle wrapper
```

- Keep release keystores out of source control. This sandbox ships a `.gitignore` that excludes `*.jks`, `*.keystore`, and `keystore/`.
