# Script: ListarEstruturaProjeto.ps1
# Descrição: Lista a estrutura de diretórios e arquivos a partir da raiz do projeto

param (
    [string]$CaminhoRaiz = "."
)

function ListarEstrutura {
    param (
        [string]$Caminho,
        [int]$Nivel = 0
    )

    $indentacao = " " * ($Nivel * 4)
    $nome = Split-Path $Caminho -Leaf
    Write-Output "$indentacao$nome"

    Get-ChildItem -Path $Caminho -Force | ForEach-Object {
        if ($_.PSIsContainer) {
            ListarEstrutura -Caminho $_.FullName -Nivel ($Nivel + 1)
        } else {
            $indentacaoArquivo = " " * (($Nivel + 1) * 4)
            Write-Output "$indentacaoArquivo$($_.Name)"
        }
    }
}

# Executa a listagem
ListarEstrutura -Caminho $CaminhoRaiz