# Mediator requests with MediatR

Decouple senders from handlers using IRequest/IRequestHandler and optional pipeline behaviors.

## Install

- dotnet add package MediatR

## Example

```csharp
// Application/Ping.cs
using MediatR;

public sealed record PingQuery(string Message) : IRequest<string>;

public sealed class PingHandler : IRequestHandler<PingQuery, string>
{
    public Task<string> Handle(PingQuery request, CancellationToken ct)
        => Task.FromResult($"Pong: {request.Message}");
}
```

## Why it works

- Promotes vertical feature slices (request + handler + validation). Easy to test.

---

## Live end-to-end example (copy/paste)

Minimal API wiring with one query and one command.

```csharp
// Program.cs
using MediatR;

var builder = WebApplication.CreateBuilder(args);

// Registers all IRequestHandler<> in this assembly
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(PingHandler).Assembly));

var app = builder.Build();

app.MapGet("/ping/{msg}", async (string msg, IMediator mediator, CancellationToken ct)
    => await mediator.Send(new PingQuery(msg), ct));

// Command example
public sealed record CreateTodoCommand(string Title) : IRequest<Todo>;
public sealed record Todo(Guid Id, string Title);

public sealed class CreateTodoHandler : IRequestHandler<CreateTodoCommand, Todo>
{
    public Task<Todo> Handle(CreateTodoCommand request, CancellationToken ct)
        => Task.FromResult(new Todo(Guid.NewGuid(), request.Title));
}

app.MapPost("/todos", async (CreateTodoCommand cmd, IMediator mediator, CancellationToken ct)
    => Results.Created("/todos", await mediator.Send(cmd, ct)));

app.Run();
```

Notes

- Add behaviors (logging/validation) by implementing IPipelineBehavior<TRequest, TResponse> and registering them.

## Sandbox copy map

Paste into a Minimal API project (see sandboxes/dotnet-minimal-api):

- Program.cs — register MediatR and map endpoints that send requests
- Application/ — place request and handler classes (PingQuery, CreateTodoCommand)
