# Caminhos dos arquivos
$apiControllerPath = "C:\Fontes\Empresas\EmpresasIntegration\Controllers\EmpresasController.cs"
$razorPagePath = "C:\Fontes\Empresas\EmpresasWeb\Pages\EditEmpresa.razor"
$listPagePath = "C:\Fontes\Empresas\EmpresasWeb\Pages\ListEmpresas.razor"

# 1. Adicionar endpoint PUT /api/empresas/{id}
if (Test-Path $apiControllerPath) {
    $controller = Get-Content $apiControllerPath -Raw

    if ($controller -notmatch "UpdateEmpresa\(int id") {
        $putEndpoint = @"
        [HttpPut(""{id}"")]
        public async Task<IActionResult> UpdateEmpresa(int id, [FromBody] EmpresaDto dto)
        {
            var empresa = await _db.Empresas.FindAsync(id);
            if (empresa == null) return NotFound();

            empresa.Nome = dto.Nome;
            empresa.Endereco = dto.Endereco;
            empresa.AtividadePrincipal = dto.AtividadePrincipal;

            await _db.SaveChangesAsync();
            return NoContent();
        }

        public class EmpresaDto
        {
            public string? Nome { get; set; }
            public string? Endereco { get; set; }
            public string? AtividadePrincipal { get; set; }
        }
"@
        $controller = $controller -replace "(public class EmpresasController[^{]+{)", "`$1`n$putEndpoint"
        Set-Content -Path $apiControllerPath -Value $controller
        Write-Host "✅ Endpoint PUT /api/empresas/{id} adicionado ao EmpresasController.cs"
    } else {
        Write-Host "ℹ️ Endpoint já existe em EmpresasController.cs"
    }
} else {
    Write-Host "❌ Arquivo não encontrado: $apiControllerPath"
}

# 2. Criar EditEmpresa.razor
if (-not (Test-Path $razorPagePath)) {
    $razorContent = @'
@page "/empresas/edit/{id:int}"
@inject IHttpClientFactory ClientFactory
@using System.Net.Http.Json
@using Microsoft.AspNetCore.Components.Forms

<h3>Editar Empresa</h3>

@if (Empresa == null)
{
    <p>Carregando...</p>
}
else
{
    <EditForm Model="@Empresa" OnValidSubmit="Salvar">
        <DataAnnotationsValidator />
        <ValidationSummary />

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

        <button class="btn btn-primary" type="submit">Salvar</button>
    </EditForm>
}

@code {
    [Parameter] public int id { get; set; }

    private HttpClient Http => ClientFactory.CreateClient("ApiClient");
    private EmpresaDto? Empresa;

    protected override async Task OnInitializedAsync()
    {
        Empresa = await Http.GetFromJsonAsync<EmpresaDto>($"api/empresas/{id}");
    }

    private async Task Salvar()
    {
        await Http.PutAsJsonAsync($"api/empresas/{id}", Empresa);
    }

    public class EmpresaDto
    {
        public string? Nome { get; set; }
        public string? Endereco { get; set; }
        public string? AtividadePrincipal { get; set; }
    }
}
'@
    Set-Content -Path $razorPagePath -Value $razorContent
    Write-Host "✅ Página EditEmpresa.razor criada com sucesso"
} else {
    Write-Host "ℹ️ Página EditEmpresa.razor já existe"
}

# 3. Atualizar ListEmpresas.razor com link de edição
if (Test-Path $listPagePath) {
    $listContent = Get-Content $listPagePath -Raw
    if ($listContent -match "<td>@empresa\.Nome</td>") {
        $listContent = $listContent -replace "<td>@empresa\.Nome</td>", "<td><a href=""/empresas/@empresa.Id"">@empresa.Nome</a> | <a href=""/empresas/edit/@empresa.Id"">Editar</a></td>"
        Set-Content -Path $listPagePath -Value $listContent
        Write-Host "✅ Link de edição adicionado em ListEmpresas.razor"
    } else {
        Write-Host "ℹ️ Link de edição já parece estar presente"
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
Write-Host "http://localhost:5155/empresas/edit/1   - Editar empresa com ID 1"
