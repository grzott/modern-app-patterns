# Coordinator Pattern (UIKit/SwiftUI)

Encapsulate navigation flows outside views.

## Example (SwiftUI)

```swift
protocol Coordinator: AnyObject { func start() -> any View }

final class AppCoordinator: ObservableObject, Coordinator {
    @Published var path = NavigationPath()
    private let repo: TodosRepo
    init(repo: TodosRepo) { self.repo = repo }
    func start() -> any View { Root(coordinator: self) }
    func showDetails(id: String) { path.append(id) }

    struct Root: View {
        @ObservedObject var coordinator: AppCoordinator
        var body: some View {
            NavigationStack(path: $coordinator.path) {
                HomeScreen(onSelect: coordinator.showDetails)
                    .navigationDestination(for: String.self) { id in DetailsScreen(id: id) }
            }
        }
    }
}
```

## Notes

- Scales complex flows; test navigation separately.

## Sandbox copy map

Paste into an Xcode SwiftUI app (see sandboxes/ios-swiftui):

- Coordinator protocol + AppCoordinator.swift — navigation state
- HomeScreen/DetailsScreen — simple views to drive navigation
