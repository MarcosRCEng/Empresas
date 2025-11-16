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

        public string? AtividadePrincipalJson { get; set; }

        public string? AtividadesSecundariasJson { get; set; }

        public string? QsaJson { get; set; }

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
        public string? UltimaAtualizacao { get; set; }

        public decimal? CapitalSocial { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
