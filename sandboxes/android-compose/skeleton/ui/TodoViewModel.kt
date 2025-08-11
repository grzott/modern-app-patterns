package sandbox.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import sandbox.domain.TodosRepo

class TodoViewModel(private val repo: TodosRepo) : ViewModel() {
  sealed interface UiState { object Loading: UiState; data class Data(val items: List<String>): UiState; data class Error(val msg: String): UiState }
  private val _state = MutableStateFlow<UiState>(UiState.Loading)
  val state: StateFlow<UiState> = _state.asStateFlow()
  fun load() = viewModelScope.launch {
    runCatching { repo.list() }.onSuccess { _state.value = UiState.Data(it) }.onFailure { _state.value = UiState.Error(it.message ?: "Oops") }
  }
}
