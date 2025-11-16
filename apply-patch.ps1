# apply-patch.ps1
# Execute na raiz do repositório onde está o arquivo 'cadastros.patch'
$patchFile = ".\cadastros.patch"
if (-not (Test-Path $patchFile)) { Write-Error "Arquivo $patchFile não encontrado. Coloque cadastros.patch na pasta atual." ; exit 1 }

$patch = Get-Content $patchFile -Raw
$blocks = $patch -split '\*\*\* Begin Patch'
foreach ($b in $blocks) {
    if ($b.Trim() -eq '') { continue }
    if ($b -match '\*\*\* Add File: (.+?)\r?\n') {
        $path = $matches[1].Trim()
        if ($b -match '(?s)\r?\n(.+?)\r?\n\*\*\* End Patch') { $contentBlock = $matches[1] } else { $contentBlock = $b }
        $lines = $contentBlock -split "`r?`n"
        $outLines = foreach ($ln in $lines) { if ($ln.StartsWith('+')) { $ln.Substring(1) } else { $ln } }
        $dir = Split-Path $path -Parent
        if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $outLines | Set-Content -LiteralPath $path -Encoding UTF8
        Write-Host "Criado: $path"
    }
}
Write-Host "Patch aplicado com sucesso."
