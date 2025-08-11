# Compose State Hoisting

State lives at the lowest common owner; pass state + events down.

## Example

```kotlin
@Composable
fun TodoList(items: List<String>, onAdd: (String) -> Unit) {
  var text by remember { mutableStateOf("") }
  Column {
    Row { TextField(text, onValueChange = { text = it }); Button({ onAdd(text); text = "" }) { Text("Add") } }
    LazyColumn { items(items) { Text(it) } }
  }
}
```

## Notes

- Pure, previewable components; business logic stays in ViewModel.

---

## Live end-to-end example (copy/paste)

Hoisted `TodoList` used by a screen that delegates to a ViewModel.

```kotlin
// ui/TodoList.kt (stateless)
@Composable
fun TodoList(items: List<String>, onAdd: (String) -> Unit, modifier: Modifier = Modifier) {
  var text by remember { mutableStateOf("") }
  Column(modifier) {
    Row { TextField(text, onValueChange = { text = it }); Button({ onAdd(text); text = "" }) { Text("Add") } }
    LazyColumn { items(items) { Text(it) } }
  }
}
```

```kotlin
// ui/TodoVm.kt
@HiltViewModel
class TodoVm @Inject constructor(): ViewModel() {
  private val _items = MutableStateFlow(listOf<String>())
  val items: StateFlow<List<String>> = _items.asStateFlow()
  fun add(s: String) { if (s.isNotBlank()) _items.value = _items.value + s }
}
```

```kotlin
// ui/TodoScreen.kt
@Composable
fun TodoScreen(vm: TodoVm = hiltViewModel()) {
  val items by vm.items.collectAsStateWithLifecycle()
  TodoList(items = items, onAdd = vm::add, modifier = Modifier.padding(16.dp))
}
```

Notes

- The composable is stateless and reusable; logic lives in the VM.

## Sandbox copy map

Paste into Android Studio project (see sandboxes/android-compose):

- ui/TodoList.kt — stateless composable
- ui/TodoVm.kt — ViewModel hosting state
- ui/TodoScreen.kt — screen that wires them together
