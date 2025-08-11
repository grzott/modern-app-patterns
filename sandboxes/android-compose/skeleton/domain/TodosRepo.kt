package sandbox.domain

interface TodosRepo { suspend fun list(): List<String> }
class FakeTodosRepo : TodosRepo { override suspend fun list() = listOf("Milk", "Bread", "Eggs") }
