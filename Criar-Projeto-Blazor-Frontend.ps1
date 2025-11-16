# Caminho base
$basePath = "C:\Fontes\Empresas"
$apiPort = 5000
$webPort = 5001
$apiProject = "$basePath\EmpresasIntegration"
$webProject = "$basePath\EmpresasWeb"

# 1. Criar projeto Blazor Server
Write-Host "Criando projeto Blazor Server..."
dotnet new blazorserver -n EmpresasWeb -o $webProject

# 2. Copiar telas Razor
Write-Host "Copiando telas Razor..."
$sourcePages = "$apiProject\Pages"
$targetPages = "$webProject\Pages"
Copy-Item "$sourcePages\*.razor" -Destination $targetPages -Force

# 3. Configurar HttpClient em Program.cs
Write-Host "Configurando HttpClient em Program.cs..."
$programPath = "$webProject\Program.cs"
$programContent = Get-Content $programPath -Raw

if ($programContent -notmatch "AddHttpClient") {
    $injection = @"
builder.Services.AddHttpClient("ApiClient", client =>
{
    client.BaseAddress = new Uri("http://localhost:$apiPort");
});
"@
    $programContent = $programContent -replace "var builder = WebApplication.CreateBuilder\(args\);", "var builder = WebApplication.CreateBuilder(args);\n$injection"
    Set-Content -Path $programPath -Value $programContent
    Write-Host "HttpClient configurado com base na API."
} else {
    Write-Host "HttpClient já está configurado."
}

# 4. Atualizar telas para usar IHttpClientFactory
Write-Host "Atualizando telas para usar IHttpClientFactory..."
Get-ChildItem -Path $targetPages -Filter *.razor | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match "@inject HttpClient Http") {
        $content = $content -replace "@inject HttpClient Http", "@inject IHttpClientFactory ClientFactory"
        $content = $content -replace "Http\.", "ClientFactory.CreateClient(\"ApiClient\")."
        Set-Content -Path $_.FullName -Value $content
    }
}

# 5. Instruções finais
Write-Host "`nProjeto Blazor Server criado com sucesso."
Write-Host "Execute os dois projetos em terminais separados:"
Write-Host "`ndotnet run --project $apiProject"
Write-Host "dotnet run --project $webProject"
Write-Host "`nAcesse o frontend em: http://localhost:$webPort/empresas"