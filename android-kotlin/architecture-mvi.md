# MVI with Sealed Intents

Single source of truth + unidirectional events → reducer → state.

## Example

```kotlin
// Mvi.kt
sealed interface Intent { data object Load: Intent; data class Retry(val reason: String): Intent }
sealed interface UiState { data object Loading: UiState; data class Data(val items: List<String>): UiState; data class Error(val message: String): UiState }

class MviViewModel @Inject constructor(private val repo: TodosRepo): ViewModel() {
  private val _state = MutableStateFlow<UiState>(UiState.Loading)
  val state: StateFlow<UiState> = _state.asStateFlow()

  fun dispatch(intent: Intent) = viewModelScope.launch {
    when(intent) {
      Intent.Load -> load()
      is Intent.Retry -> load()
    }
  }

  private suspend fun load() {
    _state.value = UiState.Loading
    runCatching { repo.list() }
      .onSuccess { _state.value = UiState.Data(it) }
      .onFailure { _state.value = UiState.Error(it.message ?: "Oops") }
  }
}
```

## Notes

- Keep reducer pure when possible; side effects via VM.

---

## Live end-to-end example (copy/paste)

Simple intents → VM → Compose UI.

```kotlin
// domain/TodosRepo.kt
interface TodosRepo { suspend fun list(): List<String> }
class FakeTodosRepo: TodosRepo { override suspend fun list() = listOf("A","B","C") }
```

```kotlin
// ui/MviViewModel.kt
sealed interface Intent { data object Load: Intent; data object Refresh: Intent }
sealed interface UiState { data object Loading: UiState; data class Data(val items: List<String>): UiState; data class Error(val msg: String): UiState }

@HiltViewModel
class MviViewModel @Inject constructor(private val repo: TodosRepo): ViewModel() {
  private val _state = MutableStateFlow<UiState>(UiState.Loading)
  val state: StateFlow<UiState> = _state.asStateFlow()
  fun dispatch(i: Intent) = viewModelScope.launch { when(i){ Intent.Load, Intent.Refresh -> load() } }
  private suspend fun load(){ runCatching { repo.list() }.onSuccess { _state.value = UiState.Data(it) }.onFailure { _state.value = UiState.Error(it.message ?: "Oops") } }
}
```

```kotlin
// ui/MviScreen.kt
@Composable
fun MviScreen(vm: MviViewModel = hiltViewModel()) {
  val s by vm.state.collectAsStateWithLifecycle()
  when (val st = s) {
    is UiState.Loading -> CircularProgressIndicator()
    is UiState.Error -> Column { Text(st.msg); Button({ vm.dispatch(Intent.Refresh) }) { Text("Retry") } }
    is UiState.Data -> LazyColumn { items(st.items) { Text(it) } }
  }
}
```

```kotlin
// di/RepoModule.kt
@Module @InstallIn(SingletonComponent::class)
object RepoModule { @Provides @Singleton fun repo(): TodosRepo = FakeTodosRepo() }
```

Notes

- Intents model user actions and drive all state changes via the VM.
