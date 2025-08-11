using MediatR;
using Microsoft.Extensions.Caching.Distributed;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));

var app = builder.Build();

// MediatR sample
public sealed record PingQuery(string Message) : IRequest<string>;
public sealed class PingHandler : IRequestHandler<PingQuery, string>
{
    public Task<string> Handle(PingQuery request, CancellationToken ct) => Task.FromResult($"Pong: {request.Message}");
}

app.MapGet("/ping/{msg}", async (string msg, IMediator mediator, CancellationToken ct) => await mediator.Send(new PingQuery(msg), ct));

// DistributedCache sample (in-memory fallback)
app.MapGet("/flags/{key}", async (string key, IDistributedCache cache, CancellationToken ct) => await cache.GetStringAsync($"flags:{key}", ct) ?? "off");
app.MapPost("/flags/{key}", async (string key, string value, IDistributedCache cache, CancellationToken ct) => { await cache.SetStringAsync($"flags:{key}", value, cancellationToken: ct); return Results.Ok(); });

app.Run();
