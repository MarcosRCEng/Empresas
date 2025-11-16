using EmpresasIntegration.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;

namespace EmpresasIntegration.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                return;
            }
            
            // Suprimir aviso de mudanças pendentes no modelo durante migrações
            optionsBuilder.ConfigureWarnings(warnings =>
                warnings.Ignore(RelationalEventId.PendingModelChangesWarning));
        }

        public DbSet<Empresa> Empresas { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configurar a entidade Empresa
            var empresaEntity = modelBuilder.Entity<Empresa>();
            
            // Nome da tabela em minúscula
            empresaEntity.ToTable("empresas");
            
            // Mapear propriedades para colunas existentes na tabela
            empresaEntity.Property(e => e.Id).HasColumnName("id");
            empresaEntity.Property(e => e.Cnpj).HasColumnName("cnpj");
            empresaEntity.Property(e => e.Nome).HasColumnName("nome");
            empresaEntity.Property(e => e.Fantasia).HasColumnName("fantasia");
            empresaEntity.Property(e => e.Situacao).HasColumnName("situacao");
            empresaEntity.Property(e => e.Tipo).HasColumnName("tipo");
            empresaEntity.Property(e => e.NaturezaJuridica).HasColumnName("natureza_juridica");
            empresaEntity.Property(e => e.Logradouro).HasColumnName("logradouro");
            empresaEntity.Property(e => e.Numero).HasColumnName("numero");
            empresaEntity.Property(e => e.Complemento).HasColumnName("complemento");
            empresaEntity.Property(e => e.Bairro).HasColumnName("bairro");
            empresaEntity.Property(e => e.Municipio).HasColumnName("municipio");
            empresaEntity.Property(e => e.Uf).HasColumnName("uf");
            empresaEntity.Property(e => e.Cep).HasColumnName("cep");
            empresaEntity.Property(e => e.Email).HasColumnName("email");
            empresaEntity.Property(e => e.Telefone).HasColumnName("telefone");
            // Configurar propriedades DateTime para garantir UTC
            empresaEntity.Property(e => e.Abertura).HasColumnName("abertura").HasConversion(v => v.HasValue ? v.Value.ToUniversalTime() : (DateTime?)null,v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null);           
            empresaEntity.Property(e => e.DataSituacao).HasColumnName("data_situacao").HasConversion(v => v.HasValue ? v.Value.ToUniversalTime() : (DateTime?)null,v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null);            
            empresaEntity.Property(e => e.CapitalSocial).HasColumnName("capital_social");
            // JSONB columns
            empresaEntity.Property(e => e.AtividadePrincipalJson).HasColumnName("atividade_principal").HasColumnType("jsonb");
            empresaEntity.Property(e => e.AtividadesSecundariasJson).HasColumnName("atividades_secundarias").HasColumnType("jsonb");
            empresaEntity.Property(e => e.QsaJson).HasColumnName("qsa").HasColumnType("jsonb");
            empresaEntity.Property(e => e.SimplesJson).HasColumnName("simples").HasColumnType("jsonb");
            empresaEntity.Property(e => e.SimeiJson).HasColumnName("simei").HasColumnType("jsonb");
            empresaEntity.Property(e => e.ExtraJson).HasColumnName("extra").HasColumnType("jsonb");
            empresaEntity.Property(e => e.BillingJson).HasColumnName("billing").HasColumnType("jsonb");
            // Metadata columns
            empresaEntity.Property(e => e.Status).HasColumnName("status");
            empresaEntity.Property(e => e.Porte).HasColumnName("porte");
            empresaEntity.Property(e => e.MotivoSituacao).HasColumnName("motivo_situacao");
            empresaEntity.Property(e => e.SituacaoEspecial).HasColumnName("situacao_especial");
            empresaEntity.Property(e => e.DataSituacaoEspecial).HasColumnName("data_situacao_especial");
            //empresaEntity.Property(e => e.UltimaAtualizacao).HasColumnName("ultima_atualizacao").HasConversion(v => v.HasValue ? v.Value.ToUniversalTime() : (DateTime?)null,v => v.HasValue ? DateTime.SpecifyKind(v.Value, DateTimeKind.Utc) : (DateTime?)null);
            empresaEntity.Property(e => e.UltimaAtualizacao).HasColumnName("ultima_atualizacao").HasColumnType("timestamp with time zone");
            // CnpjNormalized shadow/explicit property
            empresaEntity.Property(e => e.CnpjNormalized).HasColumnName("cnpj_normalized").HasMaxLength(14).IsRequired(false);
            empresaEntity.HasIndex(e => e.CnpjNormalized).HasDatabaseName("IX_empresas_cnpj_normalized");

            // Ignorar propriedades que não existem na tabela
            //empresaEntity.Ignore(e => e.UltimaAtualizacao);
            //empresaEntity.Ignore(e => e.AtividadePrincipalJson);
            //empresaEntity.Ignore(e => e.AtividadesSecundariasJson);
            //empresaEntity.Ignore(e => e.QsaJson);
            //empresaEntity.Ignore(e => e.CreatedAt);
            //empresaEntity.Ignore(e => e.UpdatedAt);
            
            // Configurar índice único no CNPJ
            empresaEntity.HasIndex(e => e.Cnpj).IsUnique();
        }
    }
}
