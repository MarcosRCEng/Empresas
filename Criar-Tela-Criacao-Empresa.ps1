# Caminhos dos arquivos
$apiControllerPath = "C:\Fontes\Empresas\EmpresasIntegration\Controllers\EmpresasController.cs"
$razorPagePath = "C:\Fontes\Empresas\EmpresasWeb\Pages\CreateEmpresa.razor"
$listPagePath = "C:\Fontes\Empresas\EmpresasWeb\Pages\ListEmpresas.razor"

# 1. Adicionar endpoint POST /api/empresas
if (Test-Path $apiControllerPath) {
    $controller = Get-Content $apiControllerPath -Raw

    if ($controller -notmatch "CreateEmpresa") {
        $postEndpoint = @"
        [HttpPost]
        public async Task<IActionResult> CreateEmpresa([FromBody] EmpresaDto dto)
        {
            var empresa = new Empresa
            {
                Cnpj = dto.Cnpj,
                Nome = dto.Nome,
                Endereco = dto.Endereco,
                AtividadePrincipal = dto.AtividadePrincipal
            };

            _db.Empresas.Add(empresa);
            await _db.SaveChangesAsync();

            return CreatedAtAction(nameof(GetEmpresa), new { id = empresa.Id }, empresa);
        }

        public class EmpresaDto
        {
            public string? Cnpj { get; set; }
            public string? Nome { get; set; }
            public string? Endereco { get; set; }
            public string? AtividadePrincipal { get; set; }
        }
"@
        $controller = $controller -replace "(public class EmpresasController[^{]+{)", "`$1`n$postEndpoint"
        Set-Content -Path $apiControllerPath -Value $controller
        Write-Host "✅ Endpoint POST /api/empresas adicionado ao EmpresasController.cs"
    } else {
        Write-Host "ℹ️ Endpoint já existe em EmpresasController.cs"
    }
} else {
    Write-Host "❌ Arquivo não encontrado: $apiControllerPath"
}

# 2. Criar CreateEmpresa.razor
if (-not (Test-Path $razorPagePath)) {
    $razorContent = @'
@page "/empresas/create"
@inject IHttpClientFactory ClientFactory
@using System.Net.Http.Json
@using Microsoft.AspNetCore.Components.Forms

<h3>Criar Nova Empresa</h3>

<EditForm Model="@Empresa" OnValidSubmit="Salvar">
    <DataAnnotationsValidator />
    <ValidationSummary />

    <div class="mb-3">
        <label class="form-label">CNPJ</label>
        <InputText class="form-control" @bind-Value="Empresa.Cnpj" />
    </div>

    <div class="mb-3">
        <label class="form-label">Nome</label>
        <InputText class="form-control" @bind-Value="Empresa.Nome" />
    </div>

    <div class="mb-3">
        <label class="form-label">Endereço</label>
        <InputText class="form-control" @bind-Value="Empresa.Endereco" />
    </div>

    <div class="mb-3">
        <label class="form-label">Atividade Principal</label>
        <InputText class="form-control" @bind-Value="Empresa.AtividadePrincipal" />
    </div>

    <button class="btn btn-success" type="submit">Salvar</button>
</EditForm>

@code {
    private HttpClient Http => ClientFactory.CreateClient("ApiClient");
    private EmpresaDto Empresa = new EmpresaDto();

    private async Task Salvar()
    {
        await Http.PostAsJsonAsync("api/empresas", Empresa);
    }

    public class EmpresaDto
    {
        public string? Cnpj { get; set; }
        public string? Nome { get; set; }
        public string? Endereco { get; set; }
        public string? AtividadePrincipal { get; set; }
    }
}
'@
    Set-Content -Path $razorPagePath -Value $razorContent
    Write-Host "✅ Página CreateEmpresa.razor criada com sucesso"
} else {
    Write-Host "ℹ️ Página CreateEmpresa.razor já existe"
}

# 3. Adicionar link de criação em ListEmpresas.razor
if (Test-Path $listPagePath) {
    $listContent = Get-Content $listPagePath -Raw
    if ($listContent -notmatch "/empresas/create") {
        $linkHtml = '<p><a class="btn btn-success" href="/empresas/create">Nova Empresa</a></p>'
        $listContent = $listContent -replace "<h3>Empresas</h3>", "<h3>Empresas</h3>`n$linkHtml"
        Set-Content -Path $listPagePath -Value $listContent
        Write-Host "✅ Link de criação adicionado em ListEmpresas.razor"
    } else {
        Write-Host "ℹ️ Link de criação já parece estar presente"
    }
} else {
    Write-Host "❌ Arquivo não encontrado: $listPagePath"
}

# Final
Write-Host ""
Write-Host "🚀 Tudo pronto! Rode novamente os projetos:"
Write-Host "→ API: dotnet run --project C:\Fontes\Empresas\EmpresasIntegration"
Write-Host "→ Web: dotnet run --project C:\Fontes\Empresas\EmpresasWeb"
Write-Host ""
Write-Host "Acesse:"
Write-Host "http://localhost:5155/empresas           - Lista de empresas"
Write-Host "http://localhost:5155/empresas/create   - Criar nova empresa"
