namespace Sandbox.Views;

public partial class TodoPage : ContentPage
{
    private readonly Sandbox.ViewModels.TodoViewModel _vm;
    public TodoPage(Sandbox.ViewModels.TodoViewModel vm)
    {
        InitializeComponent();
        BindingContext = _vm = vm;
    }

    protected override async void OnAppearing()
    {
        base.OnAppearing();
        await _vm.LoadAsync();
    }
}
