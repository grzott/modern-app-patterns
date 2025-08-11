# DI with Hilt

Use Hilt for constructor injection and module-provided dependencies.

## Example

```kotlin
// App.kt
@HiltAndroidApp
class App: Application()
```

```kotlin
// NetworkModule.kt
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
  @Provides @Singleton fun okHttp(): OkHttpClient = OkHttpClient.Builder().build()
  @Provides @Singleton fun retrofit(client: OkHttpClient): Retrofit =
    Retrofit.Builder().baseUrl("https://example.com").client(client).addConverterFactory(MoshiConverterFactory.create()).build()
  @Provides @Singleton fun api(retrofit: Retrofit): Api = retrofit.create(Api::class.java)
}
```

```kotlin
// RepoModule.kt
@Module
@InstallIn(SingletonComponent::class)
object RepoModule {
  @Provides fun todosRepo(api: Api, dao: TodoDao): TodosRepo = TodosRepoImpl(api, dao)
}
```

## Notes

- Keep bindings in feature modules when possible.
