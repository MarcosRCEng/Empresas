using System;
using System.ComponentModel.DataAnnotations;

namespace EmpresasIntegration.Models
{
    public class Empresa
    {
        [Key]
        public int Id { get; set; }

        [Required]
        [MaxLength(18)]
        public string Cnpj { get; set; } = string.Empty;

        [MaxLength(250)]
        public string? Nome { get; set; }

        [MaxLength(250)]
        public string? Fantasia { get; set; }

        [MaxLength(50)]
        public string? Situacao { get; set; }

        [MaxLength(50)]
        public string? Tipo { get; set; }

        public string? NaturezaJuridica { get; set; }
        // Propriedades novas para compatibilizar com ReceitaWS
        public string? CnpjNormalized { get; set; }         // 14 dígitos

        public string? AtividadePrincipalJson { get; set; } // jsonb

        public string? AtividadesSecundariasJson { get; set; } // jsonb

        public string? QsaJson { get; set; }                // jsonb

        public string? SimplesJson { get; set; }            // jsonb

        public string? SimeiJson { get; set; }              // jsonb

        public string? ExtraJson { get; set; }              // jsonb

        public string? BillingJson { get; set; }            // jsonb

        public string? Status { get; set; }

        public string? Porte { get; set; }

        public string? MotivoSituacao { get; set; }

        public string? SituacaoEspecial { get; set; }

        public DateTime? DataSituacaoEspecial { get; set; }

        [MaxLength(100)]
        public string? Logradouro { get; set; }

        [MaxLength(20)]
        public string? Numero { get; set; }

        [MaxLength(100)]
        public string? Complemento { get; set; }

        [MaxLength(100)]
        public string? Bairro { get; set; }

        [MaxLength(100)]
        public string? Municipio { get; set; }

        [MaxLength(2)]
        public string? Uf { get; set; }

        [MaxLength(20)]
        public string? Cep { get; set; }

        [MaxLength(100)]
        public string? Email { get; set; }

        [MaxLength(100)]
        public string? Telefone { get; set; }

        public DateTime? Abertura { get; set; }
        public DateTime? DataSituacao { get; set; }

        [MaxLength(50)]
        public DateTime? UltimaAtualizacao { get; set; }

        public decimal? CapitalSocial { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
