@echo off
echo Limpando e compilando a solução...
dotnet clean
dotnet build

echo.
echo Iniciando API (EmpresasIntegration)...
start "API EmpresasIntegration" cmd /k dotnet run --project "C:\Fontes\Empresas\EmpresasIntegration"

echo.
echo Iniciando Frontend Blazor (EmpresasWeb)...
start "Frontend EmpresasWeb" cmd /k dotnet run --project "C:\Fontes\Empresas\EmpresasWeb"

echo.
echo ✅ Ambos os projetos foram iniciados em janelas separadas.
pause
