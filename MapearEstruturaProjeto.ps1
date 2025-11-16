# Script: MapearEstruturaProjeto.ps1
# Descrição: Mapeia estrutura de arquivos, portas, rotas e configurações de conexão

param (
    [string]$CaminhoRaiz = ".",
    [string]$ArquivoSaida = "estrutura_projeto.txt"
)

function ListarEstrutura {
    param (
        [string]$Caminho,
        [int]$Nivel = 0,
        [System.IO.StreamWriter]$Writer
    )

    $indentacao = " " * ($Nivel * 4)
    $nome = Split-Path $Caminho -Leaf
    $Writer.WriteLine("$indentacao$nome")

    Get-ChildItem -Path $Caminho -Force | ForEach-Object {
        if ($_.PSIsContainer) {
            ListarEstrutura -Caminho $_.FullName -Nivel ($Nivel + 1) -Writer $Writer
        } else {
            $indentacaoArquivo = " " * (($Nivel + 1) * 4)
            $Writer.WriteLine("$indentacaoArquivo$($_.Name)")
        }
    }
}

function MapearConfiguracoes {
    param (
        [string]$Caminho,
        [System.IO.StreamWriter]$Writer
    )

    $arquivos = Get-ChildItem -Path $Caminho -Recurse -Include *.json,*.config,*.cs,*.sql -ErrorAction SilentlyContinue

    foreach ($arquivo in $arquivos) {
        $conteudo = Get-Content $arquivo.FullName -ErrorAction SilentlyContinue
        $linhasRelevantes = $conteudo | Where-Object {
            $_ -match "port" -or $_ -match "porta" -or $_ -match "route" -or $_ -match "rota" -or $_ -match "connection" -or $_ -match "Data Source" -or $_ -match "Server=" -or $_ -match "Host="
        }

        if ($linhasRelevantes.Count -gt 0) {
            $Writer.WriteLine("")
            $Writer.WriteLine("Arquivo: $($arquivo.FullName)")
            foreach ($linha in $linhasRelevantes) {
                $Writer.WriteLine("    $linha")
            }
        }
    }
}

# Cria o arquivo de saída
$writer = New-Object System.IO.StreamWriter($ArquivoSaida, $false)

$writer.WriteLine("MAPEAMENTO DE ESTRUTURA DE PROJETO")
$writer.WriteLine("===================================")
$writer.WriteLine("")
$writer.WriteLine("ESTRUTURA DE ARQUIVOS:")
$writer.WriteLine("")

ListarEstrutura -Caminho $CaminhoRaiz -Nivel 0 -Writer $writer

$writer.WriteLine("")
$writer.WriteLine("CONFIGURAÇÕES DETECTADAS:")
$writer.WriteLine("")

MapearConfiguracoes -Caminho $CaminhoRaiz -Writer $writer

$writer.Close()

Write-Output "Mapeamento concluído. Arquivo gerado: $ArquivoSaida"
