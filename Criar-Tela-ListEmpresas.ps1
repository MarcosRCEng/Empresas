# Caminho base do projeto Blazor Server
$blazorPath = "C:\Fontes\Empresas\EmpresasIntegration"
$pagesPath = Join-Path $blazorPath "Pages"

# 1. Criar arquivo ListEmpresas.razor
$razorPath = Join-Path $pagesPath "ListEmpresas.razor"
Set-Content -LiteralPath $razorPath -Value @'
@page "/empresas"
@inject HttpClient Http
@using System.Net.Http.Json

<h3>Lista de Empresas</h3>

@if (Empresas == null)
{
    <p>Carregando...</p>
}
else if (Empresas.Count == 0)
{
    <p>Nenhuma empresa encontrada.</p>
}
else
{
    <table class="table">
        <thead>
            <tr>
                <th>ID</th>
                <th>CNPJ</th>
                <th>Nome</th>
            </tr>
        </thead>
        <tbody>
            @foreach (var empresa in Empresas)
            {
                <tr>
                    <td>@empresa.Id</td>
                    <td>@empresa.Cnpj</td>
                    <td>@empresa.Nome</td>
                </tr>
            }
        </tbody>
    </table>
}

<a class="btn btn-primary" href="/empresas/import">Importar nova empresa</a>

@code {
    private List<EmpresaDto> Empresas;

    protected override async Task OnInitializedAsync()
    {
        try
        {
            Empresas = await Http.GetFromJsonAsync<List<EmpresaDto>>("api/empresas");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Erro ao carregar empresas: {ex.Message}");
            Empresas = new List<EmpresaDto>();
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
Write-Host "Tela 'ListEmpresas.razor' criada com sucesso."

# 2. Instruções finais
Write-Host ""
Write-Host "Para testar a tela, execute:"
Write-Host "dotnet run --project $blazorPath"
Write-Host "E acesse: http://localhost:5000/empresas"