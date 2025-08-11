# Repository + Codable

Map transport DTOs to domain models with `Codable`.

## Example

```swift
struct Todo: Identifiable { let id: String; let title: String }
struct TodoDTO: Codable { let id: String; let name: String }

protocol TodosRepo { func list() async throws -> [Todo] }

final class HttpTodosRepo: TodosRepo {
    let baseURL: URL
    init(baseURL: URL) { self.baseURL = baseURL }
    func list() async throws -> [Todo] {
        let (data, _) = try await URLSession.shared.data(from: baseURL.appendingPathComponent("todos"))
        return try JSONDecoder().decode([TodoDTO].self, from: data).map { Todo(id: $0.id, title: $0.name) }
    }
}
```

## Notes

- Keep mapping in one place; avoid leaking DTOs into UI.

---

## Live end-to-end example (copy/paste)

Domain + DTO mapping + HTTP repo + SwiftUI view.

```swift
// Domain
struct Todo: Identifiable { let id: String; let title: String }
protocol TodosRepo { func list() async throws -> [Todo] }

// DTO + Mapper
struct TodoDTO: Codable { let id: Int; let title: String; let completed: Bool }
extension Todo { init(dto: TodoDTO) { self.init(id: String(dto.id), title: dto.title) } }

// Repo
final class HttpTodosRepo: TodosRepo {
    let baseURL: URL
    init(baseURL: URL) { self.baseURL = baseURL }
    func list() async throws -> [Todo] {
        let (data, _) = try await URLSession.shared.data(from: baseURL.appendingPathComponent("todos"))
        return try JSONDecoder().decode([TodoDTO].self, from: data).map(Todo.init)
    }
}

// VM + View
@MainActor final class TodosVM: ObservableObject {
    enum State { case loading, data([Todo]), error(String) }
    @Published private(set) var state: State = .loading
    private let repo: TodosRepo
    init(repo: TodosRepo) { self.repo = repo }
    func load() async {
        state = .loading
        do { state = .data(try await repo.list()) }
        catch { state = .error(error.localizedDescription) }
    }
}

struct TodosView: View {
    @StateObject var vm: TodosVM
    var body: some View {
        content.task { await vm.load() }
    }
    @ViewBuilder private var content: some View {
        switch vm.state {
        case .loading: ProgressView()
        case .error(let msg): VStack{ Text(msg); Button("Retry"){ Task{ await vm.load() } } }
        case .data(let todos): List(todos) { Text($0.title) }
        }
    }
}
```

Notes

- Point `baseURL` to jsonplaceholder to try quickly.
