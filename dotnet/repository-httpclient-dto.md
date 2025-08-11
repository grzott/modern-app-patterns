# Repository + HttpClient + DTO Mapping (.NET)

Map transport DTOs to domain models behind a repository abstraction.

## Example

```csharp
// Domain/Models/Todo.cs
public sealed record Todo(string Id, string Title, bool Done);

// Domain/Abstractions/ITodosRepository.cs
public interface ITodosRepository { Task<IReadOnlyList<Todo>> ListAsync(CancellationToken ct); }
```

```csharp
// Infrastructure/Http/TodoDto.cs
public sealed class TodoDto { public string Id { get; set; } = default!; public string Title { get; set; } = default!; public bool Completed { get; set; } }
```

```csharp
// Infrastructure/Http/HttpTodosRepository.cs
public sealed class HttpTodosRepository(HttpClient http) : ITodosRepository
{
    public async Task<IReadOnlyList<Todo>> ListAsync(CancellationToken ct)
    {
        using var res = await http.GetAsync("/todos", ct);
        res.EnsureSuccessStatusCode();
        var stream = await res.Content.ReadAsStreamAsync(ct);
        var dtos = await JsonSerializer.DeserializeAsync<List<TodoDto>>(stream, cancellationToken: ct) ?? [];
        return dtos.Select(d => new Todo(d.Id, d.Title, d.Completed)).ToList();
    }
}
```

```csharp
// API/Program.cs
builder.Services.AddHttpClient<ITodosRepository, HttpTodosRepository>(c => c.BaseAddress = new Uri("https://example.com"));
```

## Why it works

- Keeps HTTP and mapping out of the UI; swap implementations easily.

---

## Live end-to-end example (copy/paste)

Register a typed HttpClient for the repository and expose a minimal API endpoint.

```csharp
// Program.cs (Minimal API)
using Domain.Abstractions; // your interface namespace

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient<ITodosRepository, HttpTodosRepository>(c =>
{
    c.BaseAddress = new Uri("https://jsonplaceholder.typicode.com");
});

var app = builder.Build();

app.MapGet("/todos", async (ITodosRepository repo, CancellationToken ct)
    => await repo.ListAsync(ct));

app.Run();
```

```csharp
// Infrastructure/Http/HttpTodosRepository.cs (mapping example)
public sealed class HttpTodosRepository(HttpClient http) : ITodosRepository
{
    public async Task<IReadOnlyList<Todo>> ListAsync(CancellationToken ct)
    {
        using var res = await http.GetAsync("/todos?_limit=10", ct);
        res.EnsureSuccessStatusCode();
        var stream = await res.Content.ReadAsStreamAsync(ct);
        var dtos = await JsonSerializer.DeserializeAsync<List<TodoDto>>(stream, cancellationToken: ct) ?? [];
        return dtos.Select(d => new Todo(d.Id, d.Title, d.Completed)).ToList();
    }
}
```

Notes

- Use Polly handlers on the typed HttpClient for retries/timeouts. Keep DTOs internal to Infrastructure.

## Sandbox copy map

Paste into a Minimal API project (see sandboxes/dotnet-minimal-api):

- Domain/: models + interfaces
- Infrastructure/Http/: DTO + repository
- Program.cs — typed HttpClient registration and endpoints
