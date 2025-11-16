# Ajuste a raiz da solution se necessário

$root = Resolve-Path "."

Write-Host "Root: $root"



# Paths dos projetos

$domainProj = "src/Modules/Cadastros/Module.Cadastros.Domain/Module.Cadastros.Domain.csproj"

$appProj = "src/Modules/Cadastros/Module.Cadastros.Application/Module.Cadastros.Application.csproj"

$infraProj = "src/Modules/Cadastros/Module.Cadastros.Infrastructure/Module.Cadastros.Infrastructure.csproj"

$apiProj = "src/Modules/Cadastros/Module.Cadastros.Api/Module.Cadastros.Api.csproj"

$slnFile = Get-ChildItem -Path $root -Filter "*.sln" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1



if (-not $slnFile) {

    Write-Error "Nenhuma .sln encontrada na raiz. Execute em uma pasta que contenha a solution ou crie uma com 'dotnet new sln'."

    exit 1

}



$sln = $slnFile.FullName

Write-Host "Solution detectada: $sln"



# Função auxiliar para rodar comandos dotnet com saída controlada

function Run-Dotnet {

    param([string]$commandArgs)

    Write-Host "`n> dotnet $commandArgs"

    $output = cmd /c "dotnet $commandArgs" 2>&1

    $output | ForEach-Object { Write-Host $_ }

    if ($LASTEXITCODE) { return $LASTEXITCODE } else { return 0 }

}



# 1) Criar projetos que faltam (será ignorado se já existirem)

$projectsToEnsure = @(

    @{ Path = $domainProj;   Template = "classlib" },

    @{ Path = $appProj;      Template = "classlib" },

    @{ Path = $infraProj;    Template = "classlib" },

    @{ Path = $apiProj;      Template = "webapi" }

)



foreach ($p in $projectsToEnsure) {

    $projPath = Join-Path $root $p.Path

    $projDir = Split-Path $projPath -Parent

    if (-not (Test-Path $projPath)) {

        if (-not (Test-Path $projDir)) { New-Item -ItemType Directory -Path $projDir -Force | Out-Null }

        Write-Host "Criando projeto [$($p.Template)] em $projDir"

        Run-Dotnet "new $($p.Template) -o `"$projDir`" --no-restore"

    } else {

        Write-Host "Projeto ja existe: ${projPath}"

    }

}



# 2) Adicionar projetos à solution

$projs = @($domainProj, $appProj, $infraProj, $apiProj)

foreach ($p in $projs) {

    $full = Join-Path $root $p

    if (Test-Path $full) {

        # checar se ja esta na sln

        $slnList = (dotnet sln $sln list) -join "`n"

        if ($slnList -notmatch [regex]::Escape($p)) {

            Write-Host "Adicionando $p à solution"

            Run-Dotnet "sln `"$sln`" add `"$full`""

        } else {

            Write-Host "Já está presente na solution: $p"

        }

    } else {

        Write-Host "Ignorando adição à solution; projeto não existe: $p" -ForegroundColor Yellow

    }

}



# 3) Adicionar referências entre projetos (idempotente)

function Add-ProjectReferenceIfMissing($targetProj, $refProj) {

    $targetFull = Join-Path $root $targetProj

    $refFull = Join-Path $root $refProj

    if (-not (Test-Path $targetFull) -or -not (Test-Path $refFull)) { return }

    $check = dotnet msbuild -nologo -t:Evaluate -p:TargetPath="$targetFull" 2>$null

    # Simples verificação via dotnet list package (não exato) — usaremos tentativa de add que falha se já existe

    Write-Host "Adicionando referência: $refProj -> $targetProj"

    Run-Dotnet "add `"$targetFull`" reference `"$refFull`""

}



# Application depende de Domain

Add-ProjectReferenceIfMissing $appProj $domainProj



# Infrastructure depende de Domain e Application

Add-ProjectReferenceIfMissing $infraProj $domainProj

Add-ProjectReferenceIfMissing $infraProj $appProj



# Api depende de Application

Add-ProjectReferenceIfMissing $apiProj $appProj



# 4) Instalar pacotes NuGet essenciais (idempotente)

function Add-PackageIfMissing($proj, $package, $version = $null) {

    $full = Join-Path $root $proj

    if (-not (Test-Path $full)) { Write-Host "Projeto não encontrado para adicionar pacote: $proj" -ForegroundColor Yellow; return }

    $has = dotnet list `"$full`" package --framework net9.0 2>$null | Select-String $package

    if ($has) {

        Write-Host "Pacote ja presente em ${proj}: ${package}"

    } else {

        $arg = if ($version) { "$package --version $version" } else { $package }

        Write-Host "Adicionando pacote ${package} ao ${proj}"

        Run-Dotnet "add `"$full`" package $arg"

    }

}



Add-PackageIfMissing $infraProj "Microsoft.EntityFrameworkCore"

Add-PackageIfMissing $infraProj "Npgsql.EntityFrameworkCore.PostgreSQL"

Add-PackageIfMissing $apiProj   "Swashbuckle.AspNetCore"



# 5) Criar appsettings.json mínimo no projeto Api se não existir

$apiAppSettings = Join-Path $root "src/Modules/Cadastros/Module.Cadastros.Api/appsettings.json"

if (-not (Test-Path $apiAppSettings)) {

    Write-Host "Criando appsettings.json mínimo em Module.Cadastros.Api"

    $json = @'

{

  "ConnectionStrings": {

    "Cadastros": "Host=127.0.0.1;Port=5435;Database=erp;Username=postgres;Password=postgres"

  },

  "Logging": {

    "LogLevel": {

      "Default": "Information",

      "Microsoft": "Warning",

      "Microsoft.Hosting.Lifetime": "Information"

    }

  }

}

'@

    $dir = Split-Path $apiAppSettings -Parent

    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    $json | Out-File -FilePath $apiAppSettings -Encoding UTF8

} else {

    Write-Host "appsettings.json ja existe em Module.Cadastros.Api"

}



# 6) Restaurar e build da solution

Write-Host "`nRestaurando pacotes..."

Run-Dotnet "restore `"$sln`""

Write-Host "`nBuildando solution..."

$rc = Run-Dotnet "build `"$sln`" -c Debug"

if ($rc -ne 0) {

    Write-Error "Build falhou. Corrija os erros antes de prosseguir com migrations."

    exit 1

}



# 7) Instalar dotnet-ef global se não instalado

$efCheck = dotnet ef --version 2>$null

if ($LASTEXITCODE -ne 0) {

    Write-Host "dotnet-ef não encontrado. Instalando dotnet-ef globalmente..."

    Run-Dotnet "tool install --global dotnet-ef"

    $env:PATH += ";" + "$env:USERPROFILE\.dotnet\tools"

} else {

    Write-Host "dotnet-ef ja instalado: ${efCheck}"

}



# 8) Criar e aplicar migration no projeto Infrastructure (se DbContext estiver presente)

$infraFullDir = Join-Path $root "src/Modules/Cadastros/Module.Cadastros.Infrastructure"

$contextName = "CadastrosDbContext"

if (Test-Path $infraFullDir) {

    Push-Location $infraFullDir

    try {

        # Check if there are existing migrations

        if (-not (Test-Path ".\Migrations")) {

            Write-Host "Criando migration InitialCreate no projeto Infrastructure..."

            Run-Dotnet "ef migrations add InitialCreate --context $contextName --output-dir Migrations"

        } else {

            Write-Host "Pasta Migrations ja existe; pulando criacao de migration."

        }



        Write-Host "Aplicando migrations ao banco de dados (usando connection string do appsettings.json da API)."

        Run-Dotnet "ef database update --context $contextName"

    } finally {

        Pop-Location

    }

} else {

    Write-Host "Projeto Infrastructure não encontrado; pulando migrações." -ForegroundColor Yellow

}



Write-Host "`nScript finalizado. Próximos passos recomendados:"

Write-Host "1) Verifique se as classes templates (Domain, Application, Infrastructure, Api) estão coladas corretamente nos projetos."

Write-Host "2) Abra Module.Cadastros.Api/Program.cs e confirme registros de DI: CadastrosDbContext (UseNpgsql), IHttpClientFactory 'receitaws', IReceitawsClient -> ReceitawsClient, IEmpresaRepository -> EmpresaRepository, ImportEmpresaUseCase."

Write-Host "3) Rode a API: dotnet run --project src/Modules/Cadastros/Module.Cadastros.Api"

Write-Host "4) Teste endpoint POST /api/cadastros/empresas/import/{cnpj} via Swagger ou Postman."

