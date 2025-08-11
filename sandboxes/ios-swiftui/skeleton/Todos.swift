import SwiftUI

protocol TodosRepo { func list() async throws -> [String] }
struct FakeTodosRepo: TodosRepo { func list() async throws -> [String] { ["Milk","Bread","Eggs"] } }

@MainActor final class TodosVM: ObservableObject {
    enum State { case loading, data([String]), error(String) }
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
        case .data(let items): List(items, id: \\.self, rowContent: Text.init)
        }
    }
}

@main struct SandboxApp: App {
    var body: some Scene {
        WindowGroup { TodosView(vm: .init(repo: FakeTodosRepo())) }
    }
}
