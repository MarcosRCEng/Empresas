# Script para marcar a migracao como aplicada no banco de dados
$connectionString = "Host=127.0.0.1;Port=5435;Database=erp;Username=postgres;Password=postgres"

# SQL para criar a tabela de historico se nao existir e marcar a migracao
$sql = @"
CREATE TABLE IF NOT EXISTS ""__EFMigrationsHistory"" (
    ""MigrationId"" VARCHAR(150) NOT NULL PRIMARY KEY,
    ""ProductVersion"" VARCHAR(32) NOT NULL
);

INSERT INTO ""__EFMigrationsHistory"" (""MigrationId"", ""ProductVersion"")
VALUES ('20251104000628_InitialCreate', '7.0.0')
ON CONFLICT (""MigrationId"") DO NOTHING;
"@

try {
    # Tentar usar Npgsql via dotnet
    $tempScript = [System.IO.Path]::GetTempFileName() + ".sql"
    $sql | Out-File -FilePath $tempScript -Encoding UTF8
    
    Write-Host "Executando script SQL para marcar migracao como aplicada..." -ForegroundColor Yellow
    
    # Usar dotnet ef para executar SQL (alternativa)
    # Ou usar uma conexao direta via .NET
    Write-Host "[INFO] Execute manualmente o seguinte SQL no seu cliente PostgreSQL:" -ForegroundColor Cyan
    Write-Host $sql -ForegroundColor Gray
    Write-Host ""
    Write-Host "Ou execute o arquivo mark-migration-applied.sql" -ForegroundColor Yellow
    
    Remove-Item $tempScript -ErrorAction SilentlyContinue
} catch {
    Write-Host "Erro: $_" -ForegroundColor Red
}

