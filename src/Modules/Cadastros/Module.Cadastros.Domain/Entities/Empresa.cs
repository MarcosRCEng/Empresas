using System;
using System.ComponentModel.DataAnnotations;

namespace Module.Cadastros.Domain.Entities
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

        [MaxLength(100)]
        public string? Municipio { get; set; }

        [MaxLength(2)]
        public string? Uf { get; set; }

        public DateTime? Abertura { get; set; }

        public string? AtividadePrincipalJson { get; set; }

        public string? AtividadesSecundariasJson { get; set; }

        public string? QsaJson { get; set; }
    }
}

