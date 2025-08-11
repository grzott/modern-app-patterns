# .NET Patterns (C#)

Practical patterns for ASP.NET Core and .NET MAUI. Each guide includes a live end-to-end example you can copy/paste.

- Architecture
  - [MVVM with CommunityToolkit](./maui-mvvm-toolkit.md)
  - [Clean Architecture (API + Application + Domain + Infrastructure)](./clean-architecture.md)
- Data & HTTP
  - [Repository + DTO mapping with HttpClient](./repository-httpclient-dto.md)
  - [Caching with IMemoryCache/IDistributedCache](./caching-imemorycache.md)
- DI & Messaging
  - [Dependency Injection with Microsoft.Extensions.DependencyInjection](./di-built-in.md)
  - [Mediator pattern with MediatR](./mediatr-requests.md)

Tip: start from these in a sandbox project, then extract stable pieces into your layers (Domain, Application, Infrastructure).

## Try it

Minimal API (ASP.NET Core)

```powershell
# 1) Create and run a sandbox Minimal API
dotnet new web -n api-sandbox
cd api-sandbox

# 2) Add packages as needed
dotnet add package MediatR
dotnet add package Microsoft.Extensions.Caching.StackExchangeRedis

# 3) Paste Program.cs snippets from the guides (repository, caching, MediatR)
# 4) Run
dotnet run
```

.NET MAUI (Windows)

```powershell
# 1) Install workloads if needed
dotnet workload install maui

# 2) Create a MAUI app
dotnet new maui -n MauiSandbox
cd MauiSandbox

# 3) Add CommunityToolkit.Mvvm
dotnet add package CommunityToolkit.Mvvm

# 4) Paste ViewModel, XAML, and DI snippets from the MAUI guide

# 5) Build/Run (targets vary; use VS or dotnet)
dotnet build
```

See also: `../sandboxes/dotnet-minimal-api` and `../sandboxes/dotnet-maui` for skeletons and Program.cs/App wiring you can paste.
