# MVVM with ObservableObject (SwiftUI)

Expose view state via `@Published`; update via async actions.

## Example

```swift
// TodoViewModel.swift
import Foundation

@MainActor
final class TodoViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case success([String])
        case error(String)
    }

    @Published private(set) var state: State = .idle
    private let repo: TodosRepo

    init(repo: TodosRepo) { self.repo = repo }

    func load() async {
        state = .loading
        do { let items = try await repo.list(); state = .success(items) }
        catch { state = .error(error.localizedDescription) }
    }
}
```

```swift
// TodoView.swift
import SwiftUI

struct TodoView: View {
    @StateObject var vm: TodoViewModel
    var body: some View {
        content
            .task { if case .idle = vm.state { await vm.load() } }
    }
    @ViewBuilder private var content: some View {
        switch vm.state {
        case .idle: Button("Load") { Task { await vm.load() } }
        case .loading: ProgressView()
        case .error(let msg): VStack { Text(msg); Button("Retry") { Task { await vm.load() } } }
        case .success(let items): List(items, id: \.self, rowContent: Text.init)
        }
    }
}
```

## Notes

- State machine matches UI exactly; easy previews and tests.

---

## Live end-to-end example (copy/paste)

Minimal repo + VM + SwiftUI view.

```swift
// TodosRepo.swift (Domain)
protocol TodosRepo { func list() async throws -> [String] }
struct FakeTodosRepo: TodosRepo { func list() async throws -> [String] { ["Milk","Bread","Eggs"] } }
```

```swift
// TodoViewModel.swift (VM)
@MainActor
final class TodoViewModel: ObservableObject {
    enum State { case loading, data([String]), error(String) }
    @Published private(set) var state: State = .loading
    private let repo: TodosRepo
    init(repo: TodosRepo) { self.repo = repo }
    func load() async {
        state = .loading
        do { let items = try await repo.list(); state = .data(items) }
        catch { state = .error(error.localizedDescription) }
    }
}
```

```swift
// TodoView.swift (UI)
struct TodoView: View {
    @StateObject var vm: TodoViewModel
    var body: some View {
        content.task { await vm.load() }
    }
    @ViewBuilder private var content: some View {
        switch vm.state {
        case .loading: ProgressView()
        case .error(let msg): VStack{ Text(msg); Button("Retry"){ Task { await vm.load() } } }
        case .data(let items): List(items, id: \.self, rowContent: Text.init)
        }
    }
}
```

Notes

- Swap `FakeTodosRepo` with a real HTTP/Core Data-backed repo without changing the view.
