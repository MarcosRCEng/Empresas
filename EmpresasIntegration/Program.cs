using EmpresasIntegration.Data;
using EmpresasIntegration.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddHttpClient();
builder.Services.AddScoped<ReceitawsService>();

var app = builder.Build();

// Habilitar Swagger em qualquer ambiente
app.UseSwagger();
app.UseSwaggerUI();

app.UseHttpsRedirection();    // Serve arquivos estáticos (wwwroot) e permite index.html como padrão
    app.UseDefaultFiles();
    app.UseStaticFiles();

app.MapControllers();
app.Run();

