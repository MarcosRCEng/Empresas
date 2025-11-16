# Script de Inicializacao - EmpresasIntegration
# Este script verifica pre-requisitos, configura o banco e inicia a aplicacao

param(
    [switch]$SkipDbCheck,
    [switch]$SkipMigrations
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  EmpresasIntegration - Inicializacao" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Funcao para verificar se um comando existe
function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# 1. Verificar .NET SDK
Write-Host "[1/6] Verificando .NET SDK..." -ForegroundColor Yellow
if (-not (Test-Command "dotnet")) {
    Write-Host "  [ERRO] .NET SDK nao encontrado!" -ForegroundColor Red
    Write-Host "  [INFO] Instale o .NET 10.0 SDK: https://dotnet.microsoft.com/download/dotnet/10.0" -ForegroundColor Yellow
    exit 1
}

$dotnetVersion = dotnet --version
Write-Host "  [OK] .NET SDK encontrado: $dotnetVersion" -ForegroundColor Green

# Verificar se e .NET 10.0
if (-not ($dotnetVersion -like "10.*")) {
    Write-Host "  [AVISO] Projeto requer .NET 10.0, mas encontrado $dotnetVersion" -ForegroundColor Yellow
}

# 2. Verificar EF Core Tools
Write-Host "[2/6] Verificando EF Core Tools..." -ForegroundColor Yellow
if (-not (Test-Command "dotnet-ef")) {
    Write-Host "  [AVISO] EF Core Tools nao encontrado. Instalando..." -ForegroundColor Yellow
    dotnet tool install --global dotnet-ef
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERRO] Falha ao instalar EF Core Tools" -ForegroundColor Red
        exit 1
    }
}
Write-Host "  [OK] EF Core Tools disponivel" -ForegroundColor Green

# 3. Verificar conexao com PostgreSQL
if (-not $SkipDbCheck) {
    Write-Host "[3/6] Verificando conexao com PostgreSQL..." -ForegroundColor Yellow
    
    # Tentar ler a string de conexao do appsettings.json
    $appsettingsPath = "EmpresasIntegration\appsettings.json"
    if (Test-Path $appsettingsPath) {
        $appsettings = Get-Content $appsettingsPath | ConvertFrom-Json
        $connString = $appsettings.ConnectionStrings.DefaultConnection
        
        # Extrair informacoes da string de conexao usando Split
        $dbHost = "127.0.0.1"
        $dbPort = "5432"
        $dbDatabase = "erp"
        $dbUsername = "postgres"
        $dbPassword = "postgres"
        
        $parts = $connString -split ';'
        foreach ($part in $parts) {
            $part = $part.Trim()
            if ($part.StartsWith("Host=")) {
                $dbHost = $part.Substring(5).Trim()
            }
            elseif ($part.StartsWith("Port=")) {
                $dbPort = $part.Substring(5).Trim()
            }
            elseif ($part.StartsWith("Database=")) {
                $dbDatabase = $part.Substring(9).Trim()
            }
            elseif ($part.StartsWith("Username=")) {
                $dbUsername = $part.Substring(9).Trim()
            }
            elseif ($part.StartsWith("Password=")) {
                $dbPassword = $part.Substring(9).Trim()
            }
        }
        
        Write-Host "  [INFO] Configuracao do banco:" -ForegroundColor Cyan
        Write-Host "     Host: $dbHost" -ForegroundColor Gray
        Write-Host "     Port: $dbPort" -ForegroundColor Gray
        Write-Host "     Database: $dbDatabase" -ForegroundColor Gray
        Write-Host "     Username: $dbUsername" -ForegroundColor Gray
        
        # Verificar se psql esta disponivel para testar conexao
        if (Test-Command "psql") {
            $env:PGPASSWORD = $dbPassword
            $testQuery = "SELECT 1;"
            $testConn = psql -h $dbHost -p $dbPort -U $dbUsername -d postgres -c $testQuery 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] Conexao com PostgreSQL OK" -ForegroundColor Green
                
                # Verificar se o banco existe
                $query = "SELECT 1 FROM pg_database WHERE datname='$dbDatabase'"
                $dbExists = psql -h $dbHost -p $dbPort -U $dbUsername -d postgres -tAc $query 2>&1
                if ($dbExists -match "1") {
                    Write-Host "  [OK] Banco de dados '$dbDatabase' existe" -ForegroundColor Green
                } else {
                    Write-Host "  [AVISO] Banco de dados '$dbDatabase' nao existe. Criando..." -ForegroundColor Yellow
                    $createDbQuery = "CREATE DATABASE $dbDatabase;"
                    psql -h $dbHost -p $dbPort -U $dbUsername -d postgres -c $createDbQuery 2>&1 | Out-Null
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "  [OK] Banco de dados criado com sucesso" -ForegroundColor Green
                    } else {
                        Write-Host "  [ERRO] Falha ao criar banco de dados" -ForegroundColor Red
                        Write-Host "  [INFO] Crie manualmente: CREATE DATABASE $dbDatabase;" -ForegroundColor Yellow
                    }
                }
            } else {
                Write-Host "  [AVISO] Nao foi possivel testar a conexao (psql nao disponivel ou PostgreSQL nao acessivel)" -ForegroundColor Yellow
                Write-Host "  [INFO] Certifique-se de que o PostgreSQL esta rodando" -ForegroundColor Yellow
            }
            Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
        } else {
            Write-Host "  [AVISO] psql nao encontrado. Pulando verificacao de conexao." -ForegroundColor Yellow
            Write-Host "  [INFO] Certifique-se de que o PostgreSQL esta rodando" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  [AVISO] appsettings.json nao encontrado" -ForegroundColor Yellow
    }
} else {
    Write-Host "[3/6] Verificacao de banco de dados pulada (--SkipDbCheck)" -ForegroundColor Yellow
}

# 4. Navegar para a pasta do projeto
Write-Host "[4/6] Navegando para pasta do projeto..." -ForegroundColor Yellow
if (-not (Test-Path "EmpresasIntegration")) {
    Write-Host "  [ERRO] Pasta EmpresasIntegration nao encontrada!" -ForegroundColor Red
    exit 1
}

Push-Location "EmpresasIntegration"
Write-Host "  [OK] Na pasta do projeto" -ForegroundColor Green

# 5. Restaurar dependencias
Write-Host "[5/6] Restaurando dependencias do NuGet..." -ForegroundColor Yellow
dotnet restore
if ($LASTEXITCODE -ne 0) {
    Write-Host "  [ERRO] Falha ao restaurar dependencias" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "  [OK] Dependencias restauradas" -ForegroundColor Green

# 6. Aplicar migracoes
if (-not $SkipMigrations) {
    Write-Host "[6/6] Aplicando migracoes do banco de dados..." -ForegroundColor Yellow
    dotnet ef database update
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [ERRO] Falha ao aplicar migracoes" -ForegroundColor Red
        Write-Host "  [INFO] Verifique a conexao com o banco de dados" -ForegroundColor Yellow
        Pop-Location
        exit 1
    }
    Write-Host "  [OK] Migracoes aplicadas" -ForegroundColor Green
} else {
    Write-Host "[6/6] Migracoes puladas (--SkipMigrations)" -ForegroundColor Yellow
}

Pop-Location

# 7. Iniciar aplicacao
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Iniciando aplicacao..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[INFO] A aplicacao estara disponivel em:" -ForegroundColor Green
Write-Host "   - HTTP:  http://localhost:5000" -ForegroundColor Cyan
Write-Host "   - HTTPS: https://localhost:5001 (se disponivel)" -ForegroundColor Cyan
Write-Host ""
Write-Host "[INFO] Swagger UI:" -ForegroundColor Green
Write-Host "   http://localhost:5000/swagger" -ForegroundColor Cyan
Write-Host "   https://localhost:5001/swagger (se HTTPS disponivel)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para parar a aplicacao, pressione Ctrl+C" -ForegroundColor Yellow
Write-Host ""

Push-Location "EmpresasIntegration"
$env:ASPNETCORE_ENVIRONMENT = "Development"
dotnet run
Pop-Location
