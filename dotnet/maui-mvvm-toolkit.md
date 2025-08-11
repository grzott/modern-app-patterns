# MVVM with CommunityToolkit (.NET MAUI)

Use `CommunityToolkit.Mvvm` to reduce boilerplate and model UI as state + commands.

## Install

- dotnet add package CommunityToolkit.Mvvm

## Example

```csharp
// ViewModels/TodoViewModel.cs
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

public partial class TodoViewModel : ObservableObject
{
    [ObservableProperty] private bool isLoading;
    [ObservableProperty] private string? error;
    public ObservableCollection<string> Items { get; } = new();

    [RelayCommand]
    public async Task LoadAsync()
    {
        try {
            IsLoading = true; Error = null; await Task.Delay(200);
            Items.Clear(); Items.Add("Milk"); Items.Add("Bread");
        } catch (Exception ex) { Error = ex.Message; }
        finally { IsLoading = false; }
    }
}
```

```xml
<!-- Views/TodoPage.xaml -->
<ContentPage xmlns="http://schemas.microsoft.com/dotnet/2021/maui"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             xmlns:vm="clr-namespace:MyApp.ViewModels"
             x:Class="MyApp.Views.TodoPage">
  <ContentPage.BindingContext>
    <vm:TodoViewModel />
  </ContentPage.BindingContext>
  <VerticalStackLayout Padding="16">
    <ActivityIndicator IsRunning="{Binding IsLoading}"/>
    <Label Text="{Binding Error}" TextColor="Red"/>
    <Button Text="Load" Command="{Binding LoadCommand}"/>
    <CollectionView ItemsSource="{Binding Items}">
      <CollectionView.ItemTemplate>
        <DataTemplate><Label Text="{Binding .}"/></DataTemplate>
      </CollectionView.ItemTemplate>
    </CollectionView>
  </VerticalStackLayout>
</ContentPage>
```

## Why it works

- Source generators remove boilerplate for INotifyPropertyChanged and Commands.

---

## Live end-to-end example (copy/paste)

Wire up DI in `MauiProgram`, inject the ViewModel into a Page, and auto-load on appearing.

```csharp
// MauiProgram.cs
using CommunityToolkit.Mvvm; // only needed if you use toolkit source generators here

public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .ConfigureFonts(fonts => { fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular"); });

        // DI
        builder.Services.AddSingleton<TodoViewModel>();
        builder.Services.AddSingleton<TodoPage>();

        return builder.Build();
    }
}
```

```csharp
// App.xaml.cs
public partial class App : Application
{
    public App(TodoPage page)
    {
        InitializeComponent();
        MainPage = new NavigationPage(page);
    }
}
```

```xml
<!-- Views/TodoPage.xaml -->
<ContentPage xmlns="http://schemas.microsoft.com/dotnet/2021/maui"
             xmlns:x="http://schemas.microsoft.com/winfx/2009/xaml"
             x:Class="MyApp.Views.TodoPage"
             Title="Todos">
  <VerticalStackLayout Padding="16" Spacing="12">
    <ActivityIndicator IsRunning="{Binding IsLoading}" IsVisible="{Binding IsLoading}"/>
    <Label Text="{Binding Error}" TextColor="Red"/>
    <Button Text="Load" Command="{Binding LoadCommand}"/>
    <CollectionView ItemsSource="{Binding Items}">
      <CollectionView.ItemTemplate>
        <DataTemplate>
          <Label Text="{Binding .}"/>
        </DataTemplate>
      </CollectionView.ItemTemplate>
    </CollectionView>
  </VerticalStackLayout>
  </ContentPage>
```

```csharp
// Views/TodoPage.xaml.cs
namespace MyApp.Views;

public partial class TodoPage : ContentPage
{
    private readonly TodoViewModel _vm;
    public TodoPage(TodoViewModel vm)
    {
        InitializeComponent();
        BindingContext = _vm = vm;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        // Kick off initial load (alternatively rely on XAML Button)
        await _vm.LoadAsync();
    }
}
```

Notes

- Register your real services in DI and inject them into the ViewModel. The above uses the ViewModel alone for brevity.

## Sandbox copy map

Paste into a new MAUI app (see sandboxes/dotnet-maui):

- ViewModels/TodoViewModel.cs — VM
- Views/TodoPage.xaml and .xaml.cs — page
- App.xaml(.cs), MauiProgram.cs — DI and shell wiring
