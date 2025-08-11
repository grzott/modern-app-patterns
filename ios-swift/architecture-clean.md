# Clean Architecture (iOS)

Divide into domain, data, and presentation for testability and reuse.

## Example

```swift
// Domain
protocol TodosRepo { func list() async throws -> [String] }
struct GetTodosUseCase { let repo: TodosRepo; func callAsFunction() async throws -> [String] { try await repo.list() } }

// Data
struct TodoDTO: Codable { let id: String; let name: String }
final class HttpTodosRepo: TodosRepo {
    let baseURL: URL
    init(baseURL: URL) { self.baseURL = baseURL }
    func list() async throws -> [String] {
        let (data, _) = try await URLSession.shared.data(from: baseURL.appendingPathComponent("todos"))
        return try JSONDecoder().decode([TodoDTO].self, from: data).map { $0.name }
    }
}
```

## Notes

- Keep UIKit/SwiftUI out of domain.
- Use protocols to invert dependencies.

---

## Live end-to-end example (copy/paste)

Domain → Data → UseCase → SwiftUI view.

```swift
// Domain
struct Todo: Identifiable { let id: String; let title: String }
protocol TodosRepo { func list() async throws -> [Todo] }
struct GetTodos { let repo: TodosRepo; func callAsFunction() async throws -> [Todo] { try await repo.list() } }

// Data
struct TodoDTO: Codable { let id: Int; let title: String; let completed: Bool }
extension Todo { init(dto: TodoDTO) { self.init(id: String(dto.id), title: dto.title) } }
final class HttpTodosRepo: TodosRepo {
    let baseURL: URL
    init(baseURL: URL) { self.baseURL = baseURL }
    func list() async throws -> [Todo] {
        let (data, _) = try await URLSession.shared.data(from: baseURL.appendingPathComponent("todos"))
        return try JSONDecoder().decode([TodoDTO].self, from: data).map(Todo.init)
    }
}

// Presentation
@MainActor final class TodosVM: ObservableObject {
    enum State { case loading, data([Todo]), error(String) }
    @Published private(set) var state: State = .loading
    private let getTodos: GetTodos
    init(getTodos: GetTodos) { self.getTodos = getTodos }
    func load() async { state = .loading; do { state = .data(try await getTodos()) } catch { state = .error(error.localizedDescription) } }
}

struct TodosView: View {
    @StateObject var vm: TodosVM
    var body: some View { content.task { await vm.load() } }
    @ViewBuilder private var content: some View {
        switch vm.state {
        case .loading: ProgressView()
        case .error(let msg): VStack{ Text(msg); Button("Retry"){ Task { await vm.load() } } }
        case .data(let items): List(items) { Text($0.title) }
        }
    }
}
```

Notes

- Swap `HttpTodosRepo` for a fake in previews/tests.

## Sandbox copy map

Paste into an Xcode SwiftUI app (see sandboxes/ios-swiftui):

- Domain files: Todo, TodosRepo, GetTodos
- Data files: TodoDTO, HttpTodosRepo (+ mapper)
- UI files: TodosVM, TodosView; set as root in @main
