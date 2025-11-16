# Caminho das páginas Razor
$pagesPath = "C:\Fontes\Empresas\EmpresasWeb\Pages"
$listPage = "$pagesPath\ListEmpresas.razor"
$importPage = "$pagesPath\ImportEmpresa.razor"

# Função para corrigir um arquivo Razor
function Corrigir-Razor {
    param (
        [string]$filePath
    )

    if (-not (Test-Path $filePath)) {
        Write-Host "Arquivo não encontrado: $filePath"
        return
    }

    $content = Get-Content $filePath -Raw

    # 1. Injetar IHttpClientFactory
    if ($content -notmatch "@inject IHttpClientFactory ClientFactory") {
        $content = "@inject IHttpClientFactory ClientFactory`n" + $content
    }

    # 2. Adicionar propriedade Http
    if ($content -notmatch "private HttpClient Http => ClientFactory.CreateClient") {
        $content = $content -replace "@code\s*{", "@code {`n    private HttpClient Http => ClientFactory.CreateClient(""ApiClient"");"
    }

    # 3. Tornar campos anuláveis
    $content = $content -replace "List<EmpresaDto> Empresas;", "List<EmpresaDto>? Empresas;"
    $content = $content -replace "string Cnpj;", "string? Cnpj;"
    $content = $content -replace "EmpresaDto Empresa;", "EmpresaDto? Empresa;"
    $content = $content -replace "public string Cnpj { get; set; }", "public string? Cnpj { get; set; }"
    $content = $content -replace "public string Nome { get; set; }", "public string? Nome { get; set; }"

    # 4. Salvar alterações
    Set-Content -Path $filePath -Value $content
    Write-Host "Corrigido: $filePath"
}

# Corrigir os dois arquivos
Corrigir-Razor -filePath $listPage
Corrigir-Razor -filePath $importPage

Write-Host "`nCorreções aplicadas. Execute novamente:"
Write-Host "dotnet run --project C:\Fontes\Empresas\EmpresasWeb"
Write-Host "E acesse: http://localhost:5001/empresas"
