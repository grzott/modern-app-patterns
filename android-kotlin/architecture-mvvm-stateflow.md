# MVVM with StateFlow (Compose)

Model UI as state; ViewModel exposes immutable StateFlow.

## Example

```kotlin
// TodoViewModel.kt
@HiltViewModel
class TodoViewModel @Inject constructor(
  private val repo: TodosRepo,
) : ViewModel() {
  sealed interface UiState {
    data object Idle: UiState
    data object Loading: UiState
    data class Success(val items: List<String>): UiState
    data class Error(val message: String): UiState
  }

  private val _state = MutableStateFlow<UiState>(UiState.Idle)
  val state: StateFlow<UiState> = _state.asStateFlow()

  fun load() = viewModelScope.launch {
    _state.value = UiState.Loading
    runCatching { repo.list() }
      .onSuccess { _state.value = UiState.Success(it) }
      .onFailure { _state.value = UiState.Error(it.message ?: "Unknown error") }
  }
}
```

```kotlin
// TodoScreen.kt
@Composable
fun TodoScreen(vm: TodoViewModel = hiltViewModel()) {
  val state by vm.state.collectAsStateWithLifecycle()
  when (state) {
    is TodoViewModel.UiState.Idle -> Button({ vm.load() }) { Text("Load") }
    is TodoViewModel.UiState.Loading -> CircularProgressIndicator()
    is TodoViewModel.UiState.Error -> Text((state as TodoViewModel.UiState.Error).message)
    is TodoViewModel.UiState.Success -> LazyColumn {
      items((state as TodoViewModel.UiState.Success).items) { Text(it) }
    }
  }
}
```

## Notes

- Use `collectAsStateWithLifecycle()` to avoid leaks.
- Keep side effects inside the ViewModel.

---

## Live end-to-end example (copy/paste)

Minimal repo + ViewModel + Compose screen.

```kotlin
// domain/TodosRepo.kt
interface TodosRepo { suspend fun list(): List<String> }

class FakeTodosRepo : TodosRepo { override suspend fun list() = listOf("Milk", "Bread", "Eggs") }
```

```kotlin
// ui/TodoViewModel.kt
@HiltViewModel
class TodoViewModel @Inject constructor(private val repo: TodosRepo) : ViewModel() {
  sealed interface UiState { data object Loading: UiState; data class Data(val items: List<String>): UiState; data class Error(val msg: String): UiState }
  private val _state = MutableStateFlow<UiState>(UiState.Loading)
  val state: StateFlow<UiState> = _state.asStateFlow()
  init { load() }
  fun load() = viewModelScope.launch { runCatching { repo.list() }.onSuccess { _state.value = UiState.Data(it) }.onFailure { _state.value = UiState.Error(it.message ?: "Oops") } }
}
```

```kotlin
// ui/TodoScreen.kt
@Composable
fun TodoScreen(vm: TodoViewModel = hiltViewModel()) {
  val state by vm.state.collectAsStateWithLifecycle()
  when (val s = state) {
    is TodoViewModel.UiState.Loading -> CircularProgressIndicator()
    is TodoViewModel.UiState.Error -> Column { Text(s.msg); Button({ vm.load() }) { Text("Retry") } }
    is TodoViewModel.UiState.Data -> LazyColumn { items(s.items) { Text(it) } }
  }
}
```

```kotlin
// di/RepoModule.kt
@Module @InstallIn(SingletonComponent::class)
object RepoModule { @Provides @Singleton fun repo(): TodosRepo = FakeTodosRepo() }
```

Notes

- Swap `FakeTodosRepo` with a real Retrofit-based repo without changing UI.
