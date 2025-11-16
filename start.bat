@echo off
REM Script de Inicialização Simples - EmpresasIntegration
REM Executa o script PowerShell de inicialização

echo ========================================
echo   EmpresasIntegration - Inicializacao
echo ========================================
echo.

REM Verificar se o PowerShell está disponível
powershell -Command "exit 0" >nul 2>&1
if errorlevel 1 (
    echo Erro: PowerShell nao encontrado!
    pause
    exit /b 1
)

REM Executar o script PowerShell
powershell -ExecutionPolicy Bypass -File "%~dp0start.ps1" %*

if errorlevel 1 (
    echo.
    echo Erro ao executar o script!
    pause
    exit /b 1
)

pause

