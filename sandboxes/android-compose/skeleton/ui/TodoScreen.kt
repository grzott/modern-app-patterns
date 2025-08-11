package sandbox.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue

@Composable
fun TodoScreen(vm: TodoViewModel) {
  val s by vm.state.collectAsState()
  LaunchedEffect(Unit) { vm.load() }
  when(val st = s) {
    is TodoViewModel.UiState.Loading -> CircularProgressIndicator()
    is TodoViewModel.UiState.Error -> Column { Text(st.msg); Button({ vm.load() }) { Text("Retry") } }
    is TodoViewModel.UiState.Data -> LazyColumn { items(st.items) { Text(it) } }
  }
}
