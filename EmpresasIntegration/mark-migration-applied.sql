-- Script para marcar a migração como aplicada no banco de dados
-- Execute este script se a tabela empresas já existe mas a migração não está registrada

-- Verificar se a tabela de histórico existe
CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" VARCHAR(150) NOT NULL PRIMARY KEY,
    "ProductVersion" VARCHAR(32) NOT NULL
);

-- Marcar a migração InitialCreate como aplicada
INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20251104000628_InitialCreate', '7.0.0')
ON CONFLICT ("MigrationId") DO NOTHING;

