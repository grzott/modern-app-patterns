# .NET Minimal API Sandbox

Starter for trying the .NET guides (Repository, Caching, MediatR).

## Setup

```powershell
# Create a minimal API and add packages
mkdir api-sandbox; cd api-sandbox
 dotnet new web
 dotnet add package MediatR
 dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis

# Replace Program.cs with snippets from the guides
notepad Program.cs

# Run
 dotnet run
```

## Endpoints ideas

- GET /todos — via repository (HttpClient+DTO mapping)
- GET /ping/{msg} — via MediatR PingQuery
- GET/POST /flags/{key} — via IDistributedCache
