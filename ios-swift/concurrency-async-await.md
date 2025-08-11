# Concurrency with async/await

Prefer Swift Concurrency; isolate side effects; use `@MainActor` for UI.

## Snippets

```swift
func retry<T>(_ times: Int, _ op: @escaping () async throws -> T) async throws -> T {
    precondition(times > 0)
    do { return try await op() } catch {
        guard times > 1 else { throw error }
        return try await retry(times - 1, op)
    }
}
```

```swift
actor Counter { private(set) var value = 0; func inc() { value += 1 } }
```

```swift
@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    func load(url: URL) async {
        let (data, _) = try? await URLSession.shared.data(from: url)
        if let data { image = UIImage(data: data) }
    }
}
```

## Notes

- Actors protect mutable state.
- Use `Task {}` sparingly; prefer structured tasks.
