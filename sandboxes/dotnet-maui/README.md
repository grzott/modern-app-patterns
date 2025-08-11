# .NET MAUI Sandbox

Use this as a checklist when creating a new MAUI app to try the MVVM Toolkit guide.

## Setup

```powershell
# Install workloads if needed
 dotnet workload install maui

# Create app
 dotnet new maui -n MauiSandbox
 cd MauiSandbox

# Add MVVM Toolkit
 dotnet add package CommunityToolkit.Mvvm
```

## Paste from guide

- ViewModels/TodoViewModel.cs
- Views/TodoPage.xaml and TodoPage.xaml.cs
- Register DI in MauiProgram.cs: services for ViewModel and Page
- App.xaml.cs: inject TodoPage and set as MainPage

## Build/Run

Use Visual Studio for Windows or run:

```powershell
 dotnet build
```
