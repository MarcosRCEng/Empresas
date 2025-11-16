#!/usr/bin/env bash
set -e

PATCH_FILE="empresas.patch"
WORKDIR="."

awk '
  /^\\*\\*\\* Begin Patch/ { inblock=1; next }
  /^\\*\\*\\* End Patch/ { inblock=0; next }
  inblock && /^\\*\\*\\* Add File: / {
    # extrair caminho do arquivo
    sub(/^\\*\\*\\* Add File: /,"")
    filename=$0
    # criar diretório do arquivo
    dir = filename
    sub(/[^\\/]+$/,"",dir)
    if (dir != "") {
      cmd = "mkdir -p \"" dir "\""
      system(cmd)
    }
    # sinaliza que vamos escrever no arquivo
    out=filename
    next
  }
  inblock && out {
    # linhas iniciadas com + no patch real vinham com +; removemos primeiro sinal + quando presente
    line=$0
    if (substr(line,1,1)=="+") {
      print substr(line,2) >> out
    } else {
      print line >> out
    }
  }
  !inblock { out="" }
' "$PATCH_FILE"

echo "Arquivos criados. Execute dotnet restore / abra no Visual Studio."
