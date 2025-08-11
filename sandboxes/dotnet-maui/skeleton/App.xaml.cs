namespace Sandbox;

public partial class App : Application
{
    public App(Sandbox.Views.TodoPage page)
    {
        InitializeComponent();
        MainPage = new NavigationPage(page);
    }
}
