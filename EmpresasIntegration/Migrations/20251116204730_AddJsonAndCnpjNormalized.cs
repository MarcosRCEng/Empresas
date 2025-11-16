using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace EmpresasIntegration.Migrations
{
    /// <inheritdoc />
    public partial class AddJsonAndCnpjNormalized : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "empresas",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "UpdatedAt",
                table: "empresas",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "atividade_principal",
                table: "empresas",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "atividades_secundarias",
                table: "empresas",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "billing",
                table: "empresas",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "cnpj_normalized",
                table: "empresas",
                type: "character varying(14)",
                maxLength: 14,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "data_situacao_especial",
                table: "empresas",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "extra",
                table: "empresas",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "motivo_situacao",
                table: "empresas",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "porte",
                table: "empresas",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "qsa",
                table: "empresas",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "simei",
                table: "empresas",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "simples",
                table: "empresas",
                type: "jsonb",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "situacao_especial",
                table: "empresas",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "status",
                table: "empresas",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ultima_atualizacao",
                table: "empresas",
                type: "timestamp with time zone",
                maxLength: 50,
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_empresas_cnpj_normalized",
                table: "empresas",
                column: "cnpj_normalized");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_empresas_cnpj_normalized",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "atividade_principal",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "atividades_secundarias",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "billing",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "cnpj_normalized",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "data_situacao_especial",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "extra",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "motivo_situacao",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "porte",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "qsa",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "simei",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "simples",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "situacao_especial",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "status",
                table: "empresas");

            migrationBuilder.DropColumn(
                name: "ultima_atualizacao",
                table: "empresas");
        }
    }
}
