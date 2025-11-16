# Script: EstruturaSimplificada.ps1
# Descrição: Lista estrutura de arquivos e salva em estrutura_projeto.txt

$arquivoSaida = "estrutura_projeto.txt"
$caminhoRaiz = Get-Location

# Cria ou sobrescreve o arquivo
Set-Content -Path $arquivoSaida -Value "MAPEAMENTO DE ESTRUTURA DE PROJETO`n`n"

# Lista estrutura de arquivos e diretórios
Get-ChildItem -Path $caminhoRaiz -Recurse | ForEach-Object {
    $linha = if ($_.PSIsContainer) { "[DIR]  $($_.FullName)" } else { "       $($_.FullName)" }
    Add-Content -Path $arquivoSaida -Value $linha
}

Write-Output "Arquivo gerado: $arquivoSaida"
