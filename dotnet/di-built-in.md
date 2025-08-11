# Dependency Injection (Microsoft.Extensions.DependencyInjection)

Use the built-in container for constructor injection and lifetime management.

## Basics

```csharp
// Service contracts
public interface IClock { DateTime UtcNow { get; } }
public sealed class SystemClock : IClock { public DateTime UtcNow => DateTime.UtcNow; }

// Register
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<IClock, SystemClock>();

var app = builder.Build();

// Resolve
app.MapGet("/time", (IClock clock) => new { now = clock.UtcNow });
app.Run();
```

## Lifetimes

- Singleton: one instance for app lifetime.
- Scoped: one per request (web).
- Transient: new per resolve.

## Why it works

- Simple, fast, integrated; fits clean architecture layering.

---

## Live end-to-end example (copy/paste)

Register multiple services and consume them via Minimal API endpoints.

```csharp
// Program.cs
public interface ITodos { Task<IReadOnlyList<string>> ListAsync(CancellationToken ct); }
public sealed class FakeTodos : ITodos
{
    public Task<IReadOnlyList<string>> ListAsync(CancellationToken ct)
        => Task.FromResult<IReadOnlyList<string>>(new[] { "Milk", "Bread" });
}

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<ITodos, FakeTodos>();
builder.Services.AddHttpClient("json", c => c.BaseAddress = new Uri("https://jsonplaceholder.typicode.com"));

var app = builder.Build();

app.MapGet("/todos", async (ITodos svc, CancellationToken ct) => await svc.ListAsync(ct));
app.MapGet("/external", async (IHttpClientFactory f, CancellationToken ct) =>
{
    var http = f.CreateClient("json");
    using var res = await http.GetAsync("/todos?_limit=2", ct);
    res.EnsureSuccessStatusCode();
    return Results.Stream(await res.Content.ReadAsStreamAsync(ct), "application/json");
});

app.Run();
```

Notes

- Prefer interfaces at boundaries; keep concrete types internal to their layer.

## Sandbox copy map

Paste into a Minimal API project (see sandboxes/dotnet-minimal-api):

- Program.cs — register services and map endpoints
- Services/ — optional folder for concrete service implementations (e.g., SystemClock)
