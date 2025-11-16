# EmpresasIntegration - Guia de Execução

## 📋 Pré-requisitos

Antes de executar o projeto, certifique-se de ter instalado:

1. **.NET 9.0 SDK** - [Download aqui](https://dotnet.microsoft.com/download/dotnet/9.0)
2. **PostgreSQL** - [Download aqui](https://www.postgresql.org/download/)
   - O projeto está configurado para usar PostgreSQL na porta `5435`
   - Database: `erp`
   - Usuário: `postgres`
   - Senha: `postgres`

## 🚀 Como Executar

### ⚡ Método Rápido: Usando o Script de Inicialização

A forma mais fácil de executar o projeto é usando o script de inicialização automático:

#### Opção 1: Script Batch (Recomendado para Windows)
```batch
start.bat
```
Ou simplesmente dê duplo clique no arquivo `start.bat`.

#### Opção 2: Script PowerShell
```powershell
.\start.ps1
```

O script faz automaticamente:
- ✅ Verifica se o .NET SDK está instalado
- ✅ Instala o EF Core Tools se necessário
- ✅ Verifica conexão com PostgreSQL
- ✅ Cria o banco de dados se não existir
- ✅ Restaura dependências do NuGet
- ✅ Aplica migrações do banco de dados
- ✅ Inicia a aplicação

**Parâmetros opcionais:**
```powershell
# Pular verificação de banco de dados
.\start.ps1 -SkipDbCheck

# Pular aplicação de migrações
.\start.ps1 -SkipMigrations

# Ambos
.\start.ps1 -SkipDbCheck -SkipMigrations
```

---

### 📋 Método Manual: Passo a Passo

Se preferir executar manualmente ou se o script não funcionar:

### Passo 1: Configurar o Banco de Dados

1. Certifique-se de que o PostgreSQL está rodando
2. Crie o banco de dados `erp` (se ainda não existir):
   ```sql
   CREATE DATABASE erp;
   ```

3. Verifique ou ajuste a string de conexão no arquivo `EmpresasIntegration/appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Host=127.0.0.1;Port=5435;Database=erp;Username=postgres;Password=postgres"
     }
   }
   ```
   > **Nota:** Ajuste `Host`, `Port`, `Username` e `Password` conforme sua configuração do PostgreSQL.

### Passo 2: Restaurar Dependências

Abra um terminal na pasta do projeto e execute:

```bash
cd EmpresasIntegration
dotnet restore
```

### Passo 3: Aplicar Migrações do Banco de Dados

Execute as migrações para criar as tabelas no banco:

```bash
dotnet ef database update
```

> **Nota:** Se você não tiver o EF Core Tools instalado globalmente, instale com:
> ```bash
> dotnet tool install --global dotnet-ef
> ```

### Passo 4: Executar a Aplicação

Execute o projeto:

```bash
dotnet run
```

Ou, se preferir executar em modo de desenvolvimento:

```bash
dotnet watch run
```

A aplicação estará disponível em:
- **HTTP:** `http://localhost:5000`
- **HTTPS:** `https://localhost:5001`

### Passo 5: Acessar a Documentação Swagger

Com a aplicação rodando, acesse:
- **Swagger UI:** `https://localhost:5001/swagger` (ou `http://localhost:5000/swagger`)

## 📝 Como Usar a API

### Importar Dados de uma Empresa

**Endpoint:** `POST /api/empresas/import/{cnpj}`

**Exemplo usando cURL:**
```bash
curl -X POST https://localhost:5001/api/empresas/import/12345678000190
```

**Exemplo usando PowerShell:**
```powershell
Invoke-RestMethod -Uri "https://localhost:5001/api/empresas/import/12345678000190" -Method Post
```

**Exemplo usando o Swagger:**
1. Acesse `https://localhost:5001/swagger`
2. Encontre o endpoint `POST /api/empresas/import/{cnpj}`
3. Clique em "Try it out"
4. Digite um CNPJ válido (ex: `12345678000190`)
5. Clique em "Execute"

**Resposta esperada:**
```json
{
  "id": 1,
  "cnpj": "12.345.678/0001-90",
  "nome": "Empresa Exemplo LTDA"
}
```

## 🔧 Solução de Problemas

### Erro de conexão com o banco de dados

- Verifique se o PostgreSQL está rodando
- Confirme a porta, usuário e senha no `appsettings.json`
- Verifique se o banco `erp` foi criado

### Erro "dotnet-ef: command not found"

Instale o EF Core Tools:
```bash
dotnet tool install --global dotnet-ef
```

### Erro ao executar migrações

Certifique-se de estar na pasta `EmpresasIntegration` e execute:
```bash
dotnet ef database update --project .
```

### Porta já em uso

Se as portas 5000 ou 5001 estiverem ocupadas, você pode alterar no `Program.cs` ou criar um arquivo `launchSettings.json` na pasta `Properties`.

## 📦 Estrutura do Projeto

```
EmpresasIntegration/
├── Controllers/       # Controladores da API
├── Data/             # Contexto do Entity Framework
├── Models/           # Modelos de dados
├── Services/         # Serviços de negócio
├── Migrations/       # Migrações do banco de dados
├── appsettings.json  # Configurações da aplicação
└── Program.cs        # Ponto de entrada da aplicação
```

## 🔍 Verificação Rápida

Para verificar se tudo está funcionando:

1. ✅ PostgreSQL rodando
2. ✅ Banco `erp` criado
3. ✅ String de conexão correta no `appsettings.json`
4. ✅ Migrações aplicadas (`dotnet ef database update`)
5. ✅ Aplicação rodando (`dotnet run`)
6. ✅ Swagger acessível em `/swagger`

