# Coroutines + Flow Basics

Use structured concurrency and cold streams for async work.

## Snippets

```kotlin
suspend fun <T> retry(times: Int, block: suspend () -> T): T {
  repeat(times - 1) { runCatching { return block() } }
  return block()
}
```

```kotlin
fun <T> Flow<T>.asState(initial: T): StateFlow<T> =
  this.stateIn(scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate), started = SharingStarted.WhileSubscribed(5_000), initialValue = initial)
```

```kotlin
viewModelScope.launch { withContext(Dispatchers.IO) { repo.sync() } }
```

## Notes

- Prefer `SupervisorJob` for UI scopes.
- Always cancel in `onCleared()` if you create custom scopes.

---

## Live end-to-end example (copy/paste)

Flow from repository → ViewModel StateFlow → Compose UI.

```kotlin
// data/TickerRepo.kt
interface TickerRepo { fun stream(): Flow<Int> }
class FakeTickerRepo : TickerRepo {
  override fun stream(): Flow<Int> = flow {
    var i = 0
    while (true) { emit(i++); delay(1000) }
  }
}
```

```kotlin
// ui/TickerViewModel.kt
@HiltViewModel
class TickerViewModel @Inject constructor(repo: TickerRepo): ViewModel() {
  val count: StateFlow<Int> = repo.stream()
    .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), 0)
}
```

```kotlin
// ui/TickerScreen.kt
@Composable
fun TickerScreen(vm: TickerViewModel = hiltViewModel()) {
  val c by vm.count.collectAsStateWithLifecycle()
  Text("Tick: $c")
}
```

Notes

- `stateIn` converts a cold flow to a hot `StateFlow` bound to the VM scope.
