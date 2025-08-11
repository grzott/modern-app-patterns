# Protocol-based DI

Inject dependencies via protocols; assemble at the composition root.

## Example

```swift
protocol Analytics { func log(event: String) }
final class ConsoleAnalytics: Analytics { func log(event: String) { print("[A] \(event)") } }

struct Services { let analytics: Analytics; let repo: TodosRepo }

final class AppContainer {
    let services: Services
    init(baseURL: URL) {
        let repo = HttpTodosRepo(baseURL: baseURL)
        let analytics = ConsoleAnalytics()
        self.services = Services(analytics: analytics, repo: repo)
    }
}
```

## Notes

- Test by swapping protocol-conforming fakes.

---

## Live end-to-end example (copy/paste)

Inject a repo via a container and build the SwiftUI tree.

```swift
// AppContainer.swift
protocol TodosRepo { func list() async throws -> [String] }
struct FakeTodosRepo: TodosRepo { func list() async throws -> [String] { ["A","B"] } }

struct Services { let repo: TodosRepo; let analytics: Analytics }
final class AppContainer { let services: Services; init() { self.services = .init(repo: FakeTodosRepo(), analytics: ConsoleAnalytics()) } }
```

```swift
// RootView.swift
struct RootView: View {
    let services: Services
    @State private var items: [String] = []
    var body: some View {
        List(items, id: \.self, rowContent: Text.init)
            .task { items = (try? await services.repo.list()) ?? [] }
    }
}
```

Notes

- Replace `FakeTodosRepo` with a real implementation in production.
