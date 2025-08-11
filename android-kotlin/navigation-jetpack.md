# Navigation with Jetpack

Type-safe navigation with a single source of truth.

## Example

```kotlin
// NavGraph.kt
@Composable
fun NavGraph(startDestination: String = "home") {
  val nav = rememberNavController()
  NavHost(navController = nav, startDestination = startDestination) {
    composable("home") { HomeScreen(onDetails = { id -> nav.navigate("details/$id") }) }
    composable("details/{id}", arguments = listOf(navArgument("id") { type = NavType.StringType })) { backStack ->
      val id = backStack.arguments?.getString("id")!!
      DetailsScreen(id)
    }
  }
}
```

## Notes

- Use typed routes or `@Serializable` with `kotlinx.serialization` and helpers for safer args.

---

## Live end-to-end example (copy/paste)

Two screens + NavHost + typed argument extraction.

```kotlin
// ui/NavGraph.kt
@Composable
fun NavGraph() {
  val nav = rememberNavController()
  NavHost(navController = nav, startDestination = "home") {
    composable("home") { HomeScreen(onOpen = { id -> nav.navigate("details/$id") }) }
    composable("details/{id}", arguments = listOf(navArgument("id") { type = NavType.StringType })) { backStack ->
      val id = requireNotNull(backStack.arguments?.getString("id"))
      DetailsScreen(id)
    }
  }
}
```

```kotlin
// ui/HomeScreen.kt
@Composable
fun HomeScreen(onOpen: (String) -> Unit) { Column { Text("Home"); Button({ onOpen("42") }) { Text("Open 42") } } }
```

```kotlin
// ui/DetailsScreen.kt
@Composable
fun DetailsScreen(id: String) { Text("Details for $id") }
```

Notes

- For complex args, create a `Route` object with `build(id)` and `parse(backStackEntry)` helpers.

## Sandbox copy map

Paste into Android Studio project (see sandboxes/android-compose):

- ui/NavGraph.kt — NavHost
- ui/HomeScreen.kt and ui/DetailsScreen.kt — screens
- MainActivity.kt — setContent { NavGraph(...) }
