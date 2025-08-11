package sandbox.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import sandbox.ui.TodoScreen
import sandbox.ui.TodoViewModel

@Composable
fun NavGraph(vm: TodoViewModel) {
  val nav = rememberNavController()
  NavHost(navController = nav, startDestination = "home") {
    composable("home") { TodoScreen(vm) }
  }
}
