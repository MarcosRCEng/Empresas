using EmpresasIntegration.Data;
using EmpresasIntegration.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// HttpClient registrations
builder.Services.AddHttpClient(); // client genérico disponível via IHttpClientFactory

// Named client para a API da Receita (configurar BaseAddress e Timeout)
builder.Services.AddHttpClient("ReceitaWs", client =>
{
    client.BaseAddress = new Uri("https://www.receitaws.com.br/");
    client.Timeout = TimeSpan.FromSeconds(15);
});

// Registrando o ReceitawsService (usa IHttpClientFactory internamente)
builder.Services.AddScoped<ReceitawsService>();

// Opcional: registrar ReceitawsService como typed client (se preferir injetar HttpClient diretamente)
// builder.Services.AddHttpClient<ReceitawsService>(client =>
// {
//     client.BaseAddress = new Uri("https://www.receitaws.com.br/");
//     client.Timeout = TimeSpan.FromSeconds(15);
// });

var app = builder.Build();

// Habilitar Swagger em qualquer ambiente
app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();

// Serve arquivos estáticos (wwwroot) e permite index.html como padrão
app.UseDefaultFiles();
app.UseStaticFiles();

app.MapControllers();
app.Run();