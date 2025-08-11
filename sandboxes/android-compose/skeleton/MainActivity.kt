package sandbox

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.remember
import sandbox.domain.FakeTodosRepo
import sandbox.navigation.NavGraph
import sandbox.ui.TodoViewModel

class MainActivity : ComponentActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContent {
      MaterialTheme {
        Surface {
          val vm = remember { TodoViewModel(FakeTodosRepo()) }
          NavGraph(vm)
        }
      }
    }
  }
}
