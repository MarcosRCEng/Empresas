# Caminhos dos arquivos
$apiControllerPath = "C:\Fontes\Empresas\EmpresasIntegration\Controllers\EmpresasController.cs"
$razorPagePath = "C:\Fontes\Empresas\EmpresasWeb\Pages\EmpresaDetails.razor"
$listPagePath = "C:\Fontes\Empresas\EmpresasWeb\Pages\ListEmpresas.razor"

# 1. Adicionar endpoint GET /api/empresas/{id}
if (Test-Path $apiControllerPath) {
    $controller = Get-Content $apiControllerPath -Raw

    if ($controller -notmatch "GetEmpresa\(int id\)") {
        $getById = @"
        [HttpGet(""{id}"")]
        public async Task<IActionResult> GetEmpresa(int id)
        {
            var empresa = await _db.Empresas.FindAsync(id);
            if (empresa == null) return NotFound();

            return Ok(new {
                empresa.Id,
                empresa.Cnpj,
                empresa.Nome,
                empresa.Endereco,
                empresa.AtividadePrincipal
            });
        }
"@
        $controller = $controller -replace "(public class EmpresasController[^{]+{)", "`$1`n$getById"
        Set-Content -Path $apiControllerPath -Value $controller
        Write-Host "✅ Endpoint GET /api/empresas/{id} adicionado ao EmpresasController.cs"
    } else {
        Write-Host "ℹ️ Endpoint já existe em EmpresasController.cs"
    }
} else {
    Write-Host "❌ Arquivo não encontrado: $apiControllerPath"
}

# 2. Criar EmpresaDetails.razor com conteúdo literal
if (-not (Test-Path $razorPagePath)) {
    $razorContent = @'
@page "/empresas/{id:int}"
@inject IHttpClientFactory ClientFactory
@using System.Net.Http.Json

<h3>Detalhes da Empresa</h3>

@if (Empresa == null)
{
    <p>Carregando...</p>
}
else
{
    <div class="card">
        <div class="card-body">
            <h5 class="card-title">@Empresa.Nome</h5>
            <p><strong>CNPJ:</strong> @Empresa.Cnpj</p>
            <p><strong>Endereço:</strong> @Empresa.Endereco</p>
            <p><strong>Atividade Principal:</strong> @Empresa.AtividadePrincipal</p>
        </div>
    </div>
}

@code {
    [Parameter] public int id { get; set; }

    private HttpClient Http => ClientFactory.CreateClient("ApiClient");
    private EmpresaDto? Empresa;

    protected override async Task OnInitializedAsync()
    {
        Empresa = await Http.GetFromJsonAsync<EmpresaDto>($"api/empresas/{id}");
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
    Write-Host "✅ Página EmpresaDetails.razor criada com sucesso"
} else {
    Write-Host "ℹ️ Página EmpresaDetails.razor já existe"
}

# 3. Atualizar ListEmpresas.razor para incluir link
if (Test-Path $listPagePath) {
    $listContent = Get-Content $listPagePath -Raw
    if ($listContent -match "<td>@empresa\.Nome</td>") {
        $listContent = $listContent -replace "<td>@empresa\.Nome</td>", "<td><a href=""/empresas/@empresa.Id"">@empresa.Nome</a></td>"
        Set-Content -Path $listPagePath -Value $listContent
        Write-Host "✅ Link para detalhes adicionado em ListEmpresas.razor"
    } else {
        Write-Host "ℹ️ Link já parece estar presente em ListEmpresas.razor"
    }
} else {
    Write-Host "❌ Arquivo não encontrado: $listPagePath"
}

# Mensagem final
Write-Host ""
Write-Host "🚀 Tudo pronto! Rode novamente os projetos:"
Write-Host "→ API: dotnet run --project C:\Fontes\Empresas\EmpresasIntegration"
Write-Host "→ Web: dotnet run --project C:\Fontes\Empresas\EmpresasWeb"
Write-Host ""
Write-Host "Acesse:"
Write-Host "http://localhost:5155/empresas       - Lista de empresas"
Write-Host "http://localhost:5155/empresas/1     - Detalhes da empresa com ID 1"
