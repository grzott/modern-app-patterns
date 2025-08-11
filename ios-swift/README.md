# iOS (Swift) Patterns

Concise guides for modern Swift/SwiftUI apps.

- Architecture
  - [MVVM with ObservableObject](./architecture-mvvm-observableobject.md)
  - [Coordinator Navigation](./navigation-coordinator.md)
  - [Clean Architecture](./architecture-clean.md)
- Concurrency & Data
  - [Async/Await + Result](./concurrency-async-await.md)
  - [Repository + Codable](./repository-codable.md)
- DI & UI
  - [Protocol-based DI](./di-protocols.md)
  - [SwiftUI State management](./ui-swiftui-state.md)

## Try it

Create a new Xcode project: iOS App → SwiftUI + Swift. Then paste the minimal files from a guide into your project:

- Add a new Swift file for the ViewModel (e.g., `TodosVM.swift`).
- Add a new Swift file for the repository protocol/impl (e.g., `TodosRepo.swift`).
- Wire the view in `ContentView.swift` or a new view, and set it in `@main` App.

Optional CLI helpers

```bash
# Open the current folder in Xcode (macOS)
open .

# Format with swift-format if installed
swift-format -i -r .
```

Tips

- For quick HTTP tests, point to https://jsonplaceholder.typicode.com.
- Use `@MainActor` on view models that publish UI state.

See also: `../sandboxes/ios-swiftui` for a minimal SwiftUI skeleton to drop code into.
