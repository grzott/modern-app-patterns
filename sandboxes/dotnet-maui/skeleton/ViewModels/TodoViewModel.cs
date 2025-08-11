using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using System.Collections.ObjectModel;

namespace Sandbox.ViewModels;

public partial class TodoViewModel : ObservableObject
{
    [ObservableProperty] private bool isLoading;
    [ObservableProperty] private string? error;
    public ObservableCollection<string> Items { get; } = new();

    [RelayCommand]
    public async Task LoadAsync()
    {
        try
        {
            IsLoading = true; Error = null; await Task.Delay(200);
            Items.Clear(); Items.Add("Milk"); Items.Add("Bread");
        }
        catch (Exception ex) { Error = ex.Message; }
        finally { IsLoading = false; }
    }
}
