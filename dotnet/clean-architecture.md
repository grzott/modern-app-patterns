# Clean Architecture (.NET)

Separate concerns into API, Application, Domain, Infrastructure projects.

## Example structure

- Domain: entities, value objects, repository interfaces
- Application: use cases (handlers), DTOs, validation
- Infrastructure: EF Core, HttpClient, implementations
- API: controllers, DI wiring

## Example

```csharp
// Domain/Entities/Todo.cs
public sealed record Todo(Guid Id, string Title, bool Done);

// Domain/Abstractions/ITodoRepository.cs
public interface ITodoRepository { Task<IReadOnlyList<Todo>> ListAsync(CancellationToken ct); }
```

```csharp
// Application/Todos/Queries/ListTodos.cs
public sealed record ListTodosQuery() : IRequest<IReadOnlyList<Todo>>;
public sealed class ListTodosHandler(ITodoRepository repo) : IRequestHandler<ListTodosQuery, IReadOnlyList<Todo>>
{
    public Task<IReadOnlyList<Todo>> Handle(ListTodosQuery request, CancellationToken ct) => repo.ListAsync(ct);
}
```

```csharp
// Infrastructure/Data/TodoRepository.cs
public sealed class TodoRepository(AppDbContext db) : ITodoRepository
{
    public async Task<IReadOnlyList<Todo>> ListAsync(CancellationToken ct) =>
        await db.Todos.AsNoTracking().Select(e => new Todo(e.Id, e.Title, e.Done)).ToListAsync(ct);
}
```

```csharp
// API/Program.cs
builder.Services.AddDbContext<AppDbContext>(...);
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(ListTodosHandler).Assembly));
builder.Services.AddScoped<ITodoRepository, TodoRepository>();
```

## Why it works

- Domain independent of frameworks; easy to test and evolve.

---

## Live end-to-end example (copy/paste)

Minimal four-project setup: Domain, Application (with MediatR), Infrastructure (EF Core), and API.

```csharp
// Domain/Entities/Todo.cs
namespace Domain.Entities;
public sealed record Todo(Guid Id, string Title, bool Done);

// Domain/Abstractions/ITodoRepository.cs
namespace Domain.Abstractions;
public interface ITodoRepository { Task<IReadOnlyList<Todo>> ListAsync(CancellationToken ct); }
```

```csharp
// Application/Todos/Queries/ListTodos.cs
using Domain.Abstractions;
using Domain.Entities;
using MediatR;

public sealed record ListTodosQuery() : IRequest<IReadOnlyList<Todo>>;

public sealed class ListTodosHandler(ITodoRepository repo)
    : IRequestHandler<ListTodosQuery, IReadOnlyList<Todo>>
{
    public Task<IReadOnlyList<Todo>> Handle(ListTodosQuery request, CancellationToken ct)
        => repo.ListAsync(ct);
}
```

```csharp
// Infrastructure/Data/AppDbContext.cs
using Domain.Entities;
using Microsoft.EntityFrameworkCore;

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Todo> Todos => Set<Todo>();
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Todo>().HasKey(t => t.Id);
        base.OnModelCreating(modelBuilder);
    }
}

// Infrastructure/Data/TodoRepository.cs
using Domain.Abstractions;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;

public sealed class TodoRepository(AppDbContext db) : ITodoRepository
{
    public async Task<IReadOnlyList<Todo>> ListAsync(CancellationToken ct)
        => await db.Todos.AsNoTracking().ToListAsync(ct);
}
```

```csharp
// API/Program.cs
using MediatR;
using Microsoft.EntityFrameworkCore;
using Domain.Abstractions;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDbContext<AppDbContext>(opt =>
    opt.UseInMemoryDatabase("app"));

builder.Services.AddMediatR(cfg =>
    cfg.RegisterServicesFromAssembly(typeof(ListTodosHandler).Assembly));

builder.Services.AddScoped<ITodoRepository, TodoRepository>();

var app = builder.Build();

app.MapGet("/todos", async (IMediator mediator, CancellationToken ct)
    => await mediator.Send(new ListTodosQuery(), ct));

app.Run();
```

Notes

- Swap InMemory for SQL Server or PostgreSQL in `UseDbContext` as needed. The handler remains unchanged.
