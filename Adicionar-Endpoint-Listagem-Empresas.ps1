# Caminho do controller
$controllerPath = "C:\Fontes\Empresas\EmpresasIntegration\Controllers\EmpresasController.cs"

# 1. Verificar se o arquivo existe
if (-not (Test-Path $controllerPath)) {
    Write-Host "Arquivo EmpresasController.cs não encontrado."
    exit
}

# 2. Ler conteúdo original
$content = Get-Content $controllerPath -Raw

# 3. Adicionar using para AppDbContext se necessário
if ($content -notmatch "using EmpresasIntegration.Data;") {
    $content = "using EmpresasIntegration.Data;`n" + $content
}

# 4. Injetar AppDbContext no construtor
if ($content -notmatch "AppDbContext _db") {
    $content = $content -replace "private readonly ReceitawsService _receitaws;", "private readonly ReceitawsService _receitaws;`n        private readonly AppDbContext _db;"
    $content = $content -replace "\(ReceitawsService receitaws\)", "(ReceitawsService receitaws, AppDbContext db)`n        {_receitaws = receitaws;`n        _db = db;"
}

# 5. Adicionar método GetEmpresas
if ($content -notmatch "public async Task<IActionResult> GetEmpresas") {
    $getMethod = @"
        [HttpGet]
        public async Task<IActionResult> GetEmpresas()
        {
            var empresas = await _db.Empresas
                .Select(e => new { e.Id, e.Cnpj, e.Nome })
                .ToListAsync();

            return Ok(empresas);
        }
"@
    $content = $content -replace "(public class EmpresasController[^{]+{)", "`$1`n$getMethod"
}

# 6. Salvar alterações
Set-Content -Path $controllerPath -Value $content
Write-Host "Endpoint GET /api/empresas adicionado com sucesso ao EmpresasController.cs"
