using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);

// Adiciona serviços para Blazor Server
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

// Configura leitura de configuração fortemente tipada
builder.Services.Configure<ApiOptions>(builder.Configuration.GetSection("Api"));

// Registra HttpClient nomeado usando a configuração (fallback para http://localhost:5000/)
builder.Services.AddHttpClient("ApiClient", (sp, client) =>
{
    var opts = sp.GetRequiredService<IOptions<ApiOptions>>().Value;
    var baseUrl = string.IsNullOrWhiteSpace(opts.BaseUrl) ? "http://localhost:5000/" : opts.BaseUrl;
    client.BaseAddress = new Uri(baseUrl);
});

// Expor o HttpClient nomeado como o HttpClient "padrão" para @inject HttpClient Http
builder.Services.AddScoped(sp => sp.GetRequiredService<IHttpClientFactory>().CreateClient("ApiClient"));

// (Opcional) Typed client para encapsular chamadas da API — facilita testes e organização
builder.Services.AddHttpClient<ApiHttpClient>((sp, client) =>
{
    var opts = sp.GetRequiredService<IOptions<ApiOptions>>().Value;
    var baseUrl = string.IsNullOrWhiteSpace(opts.BaseUrl) ? "http://localhost:5000/" : opts.BaseUrl;
    client.BaseAddress = new Uri(baseUrl);
});

var app = builder.Build();

// Configura pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}

app.UseStaticFiles();
app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();

// ---- helpers / DTOs usados na configuração (coloque abaixo ou em arquivos separados) ----

public class ApiOptions
{
    public string? BaseUrl { get; set; }
}

/// <summary>
/// Exemplo simples de typed client. Remova ou estenda conforme necessário.
/// </summary>
public class ApiHttpClient
{
    private readonly HttpClient _client;
    public ApiHttpClient(HttpClient client) => _client = client;

    public Task<List<EmpresaDto>?> GetEmpresasAsync() =>
        _client.GetFromJsonAsync<List<EmpresaDto>>("api/empresas");

    public record EmpresaDto(int Id, string? Cnpj, string? Nome);
}