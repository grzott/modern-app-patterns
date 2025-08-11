# Repository with Retrofit + Room

Network + cache with a single source of truth.

## Example

```kotlin
// NetworkBoundResource.kt (simplified)
suspend fun <T> networkBoundResource(
  query: suspend () -> T?,
  fetch: suspend () -> T,
  saveFetchResult: suspend (T) -> Unit,
): T {
  val cached = query()
  return if (cached != null) cached else fetch().also { saveFetchResult(it) }
}
```

```kotlin
// TodosRepoImpl.kt
class TodosRepoImpl @Inject constructor(
  private val api: Api,
  private val dao: TodoDao,
) : TodosRepo {
  override suspend fun list(): List<String> = networkBoundResource(
    query = { dao.getAll()?.map { it.title } },
    fetch = { api.getTodos().map { it.name } },
    saveFetchResult = { items -> dao.insertAll(items.map { TodoEntity(title = it) }) },
  )
}
```

## Notes

- Add freshness (timestamps) and invalidation for real apps.

---

## Live end-to-end example (copy/paste)

Retrofit API + Room DAO + Repository + Compose UI.

```kotlin
// data/Api.kt
interface Api { @GET("/todos") suspend fun getTodos(): List<TodoDto> }
data class TodoDto(val id: String, val name: String)
```

```kotlin
// data/db/TodoEntity.kt
@Entity tableName = "todos"
data class TodoEntity(@PrimaryKey val id: String, val title: String)

@Dao interface TodoDao {
  @Query("SELECT * FROM todos") suspend fun getAll(): List<TodoEntity>
  @Insert(onConflict = OnConflictStrategy.REPLACE) suspend fun insertAll(items: List<TodoEntity>)
}
```

```kotlin
// data/TodosRepoImpl.kt
class TodosRepoImpl @Inject constructor(private val api: Api, private val dao: TodoDao): TodosRepo {
  override suspend fun list(): List<String> = networkBoundResource(
    query = { dao.getAll().takeIf { it.isNotEmpty() }?.map { it.title } },
    fetch = { api.getTodos().map { it.name } },
    saveFetchResult = { items -> dao.insertAll(items.map { TodoEntity(id = it, title = it) }) },
  )
}
```

```kotlin
// ui/TodosScreen.kt
@Composable
fun TodosScreen(vm: TodoViewModel = hiltViewModel()) {
  val state by vm.state.collectAsStateWithLifecycle()
  when (state) {
    is TodoViewModel.UiState.Loading -> CircularProgressIndicator()
    is TodoViewModel.UiState.Error -> Text((state as TodoViewModel.UiState.Error).message)
    is TodoViewModel.UiState.Success -> LazyColumn { items((state as TodoViewModel.UiState.Success).items) { Text(it) } }
    is TodoViewModel.UiState.Idle -> Button({ vm.load() }) { Text("Load") }
  }
}
```

Notes

- Replace `TodoDto` and `TodoEntity` with your schema; add Paging 3 for long lists.
