# SwiftUI State Management

Goal: Choose the right SwiftUI model for state: @State, @Binding, @StateObject, @ObservedObject, @EnvironmentObject, and @Published.

## Cheatsheet

- @State: simple, local mutable value in a View.
- @Binding: pass a writable reference down to child Views.
- @StateObject: own a reference-type model with @Published properties (lifecycle tied to View creation).
- @ObservedObject: observe a model owned elsewhere.
- @EnvironmentObject: app/screen-wide shared model via environment.

## Minimal examples

```swift
import SwiftUI

struct CounterLocal: View {
    @State private var count: Int = 0
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") { count += 1 }
        }
    }
}
```

```swift
struct CounterWithBinding: View {
    @State private var count = 0
    var body: some View {
        VStack {
            Text("Parent count: \(count)")
            ChildCounter(count: $count)
        }
    }
}

struct ChildCounter: View {
    @Binding var count: Int
    var body: some View { Button("+1") { count += 1 } }
}
```

```swift
final class TodosVM: ObservableObject {
    @Published var items: [String] = []
    @Published var isLoading = false

    func load() async {
        isLoading = true
        defer { isLoading = false }
        // Simulate fetch
        try? await Task.sleep(nanoseconds: 400_000_000)
        items = ["Milk", "Bread", "Eggs"]
    }
}

struct TodosScreen: View {
    @StateObject private var vm = TodosVM()
    var body: some View {
        Group {
            if vm.isLoading { ProgressView() }
            else { List(vm.items, id: \.self, rowContent: Text.init) }
        }
        .task { await vm.load() }
    }
}
```

## When to use what

- Start with @State for local UI-only values.
- Use @StateObject for owning a ViewModel; @ObservedObject to observe one passed in.
- Use @Binding for two-way child editing.
- Use @EnvironmentObject sparingly for global/shared models.

---

## Live end-to-end example (copy/paste)

```swift
import SwiftUI

final class Repo: ObservableObject {
    func fetchTodos() async throws -> [String] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return ["Milk", "Bread", "Eggs"]
    }
}

@MainActor
final class AppVM: ObservableObject {
    @Published var items: [String] = []
    @Published var error: String? = nil
    @Published var loading = false

    private let repo: Repo
    init(repo: Repo) { self.repo = repo }

    func load() async {
        loading = true
        defer { loading = false }
        do { items = try await repo.fetchTodos() }
        catch { self.error = String(describing: error) }
    }
}

struct ContentView: View {
    @StateObject private var vm = AppVM(repo: Repo())
    var body: some View {
        NavigationView {
            Group {
                if vm.loading { ProgressView() }
                else if let e = vm.error { Text(e) }
                else { List(vm.items, id: \.self, rowContent: Text.init) }
            }
            .navigationTitle("Todos")
        }
        .task { await vm.load() }
    }
}

@main
struct AppStateDemo: App {
    var body: some Scene {
        WindowGroup { ContentView() }
    }
}
```

Notes

- Mark ViewModels with @MainActor when they publish UI state.
- Use Task cancellation for real HTTP calls.

---

## Sandbox copy map

- Drop `TodosVM`, `Repo`, and `ContentView` into `sandboxes/ios-swiftui/skeleton/Todos.swift` or your SwiftUI project.
- Set `AppStateDemo` (or your app) as the entry point in the project.
