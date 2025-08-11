# Caching with IMemoryCache / IDistributedCache

Cache expensive results for faster responses and fewer calls.

## Example (IMemoryCache)

```csharp
// Services/CachedTodosService.cs
public sealed class CachedTodosService(ITodosRepository repo, IMemoryCache cache)
{
    private static readonly string Key = "todos-v1";
    public async Task<IReadOnlyList<Todo>> GetAsync(TimeSpan ttl, CancellationToken ct)
    {
        if (cache.TryGetValue(Key, out IReadOnlyList<Todo> cached)) return cached;
        var items = await repo.ListAsync(ct);
        cache.Set(Key, items, ttl);
        return items;
    }
}
```

## Example (IDistributedCache)

```csharp
public static class DistributedCacheExtensions
{
    public static async Task SetJsonAsync<T>(this IDistributedCache cache, string key, T value, DistributedCacheEntryOptions? options = null, CancellationToken ct = default)
    {
        var json = JsonSerializer.Serialize(value);
        await cache.SetStringAsync(key, json, options ?? new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(5) }, ct);
    }
    public static async Task<T?> GetJsonAsync<T>(this IDistributedCache cache, string key, CancellationToken ct = default)
    {
        var json = await cache.GetStringAsync(key, ct);
        return json is null ? default : JsonSerializer.Deserialize<T>(json);
    }
}
```

## Why it works

- Simple TTL policies improve perceived performance without complexity.

---

## Live end-to-end example (copy/paste)

Register caching, wrap a repository/service, and expose endpoints using the cache.

```csharp
// Program.cs
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Caching.StackExchangeRedis;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMemoryCache();
builder.Services.AddStackExchangeRedisCache(opt =>
{
    opt.Configuration = builder.Configuration.GetConnectionString("redis") ?? "localhost:6379";
    opt.InstanceName = "app:";
});

builder.Services.AddScoped<CachedTodosService>();

var app = builder.Build();

app.MapGet("/todos", async (CachedTodosService svc, CancellationToken ct)
    => await svc.GetAsync(TimeSpan.FromMinutes(1), ct));

// Distributed cache example
app.MapGet("/flags/{key}", async (string key, IDistributedCache cache, CancellationToken ct) =>
{
    var value = await cache.GetStringAsync($"flags:{key}", ct);
    return value ?? "off";
});

app.MapPost("/flags/{key}", async (string key, string value, IDistributedCache cache, CancellationToken ct) =>
{
    await cache.SetStringAsync($"flags:{key}", value,
        new DistributedCacheEntryOptions { AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10) }, ct);
    return Results.Ok();
});

app.Run();
```

Notes

- Prefer short TTLs for dynamic data. For distributed cache, set appropriate expiration and consider cache stampede protection.

## Sandbox copy map

Paste into a Minimal API project (see sandboxes/dotnet-minimal-api):

- Services/CachedTodosService.cs — IMemoryCache wrapper
- Program.cs — AddMemoryCache/AddStackExchangeRedisCache and endpoints
