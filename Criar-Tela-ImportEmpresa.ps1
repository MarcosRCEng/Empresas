# Caminho base do projeto Blazor Server
$blazorPath = "C:\Fontes\Empresas\EmpresasIntegration"

# 1. Criar pasta Pages se não existir
$pagesPath = Join-Path $blazorPath "Pages"
if (-not (Test-Path $pagesPath)) {
    New-Item -ItemType Directory -Path $pagesPath | Out-Null
    Write-Host "Pasta 'Pages' criada."
}

# 2. Criar arquivo ImportEmpresa.razor
$razorPath = Join-Path $pagesPath "ImportEmpresa.razor"
Set-Content -LiteralPath $razorPath -Value @'
@page "/empresas/import"
@inject HttpClient Http

<h3>Importar Empresa por CNPJ</h3>

<div class="form-group">
    <label for="cnpj">CNPJ:</label>
    <input type="text" id="cnpj" @bind="Cnpj" class="form-control" />
</div>

<button class="btn btn-primary" @onclick="ImportarEmpresa">Importar</button>

@if (Empresa != null)
{
    <div class="mt-4">
        <h5>Empresa Importada:</h5>
        <p><strong>ID:</strong> @Empresa.Id</p>
        <p><strong>CNPJ:</strong> @Empresa.Cnpj</p>
        <p><strong>Nome:</strong> @Empresa.Nome</p>
    </div>
}

@code {
    private string Cnpj;
    private EmpresaDto Empresa;

    private async Task ImportarEmpresa()
    {
        try
        {
            var response = await Http.PostAsync($"api/empresas/import/{Cnpj}", null);
            if (response.IsSuccessStatusCode)
            {
                Empresa = await response.Content.ReadFromJsonAsync<EmpresaDto>();
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Erro: {ex.Message}");
        }
    }

    public class EmpresaDto
    {
        public int Id { get; set; }
        public string Cnpj { get; set; }
        public string Nome { get; set; }
    }
}
'@ -Encoding UTF8
Write-Host "Tela 'ImportEmpresa.razor' criada com sucesso."

# 3. Verificar se HttpClient está registrado no Program.cs
$programPath = Join-Path $blazorPath "Program.cs"
$programContent = Get-Content $programPath -Raw
if ($programContent -notmatch "AddHttpClient") {
    Add-Content -Path $programPath -Value "`r`nbuilder.Services.AddHttpClient();"
    Write-Host "'AddHttpClient' adicionado ao Program.cs"
} else {
    Write-Host "'AddHttpClient' já está presente no Program.cs"
}

# 4. Instruções finais
Write-Host ""
Write-Host "Para testar a tela, execute:"
Write-Host "dotnet run --project $blazorPath"
Write-Host "E acesse: http://localhost:5000/empresas/import"