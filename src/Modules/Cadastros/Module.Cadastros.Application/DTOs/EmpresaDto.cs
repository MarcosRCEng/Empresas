using System;

namespace Module.Cadastros.Application.DTOs
{
    public class EmpresaDto
    {
        public int Id { get; init; }
        public string Cnpj { get; init; } = string.Empty;
        public string? Tipo { get; init; }
        public DateTime? Abertura { get; init; }
        public string Nome { get; init; } = string.Empty;
        public string? Fantasia { get; init; }
        public string? NaturezaJuridica { get; init; }
        public string? Logradouro { get; init; }
        public string? Numero { get; init; }
        public string? Complemento { get; init; }
        public string? Cep { get; init; }
        public string? Bairro { get; init; }
        public string? Municipio { get; init; }
        public string? Uf { get; init; }
        public string? Email { get; init; }
        public string? Telefone { get; init; }
        public string? Efr { get; init; }
        public string? Situacao { get; init; }
        public DateTime? DataSituacao { get; init; }
        public string? MotivoSituacao { get; init; }
        public string? SituacaoEspecial { get; init; }
        public DateTime? DataSituacaoEspecial { get; init; }
        public decimal? CapitalSocial { get; init; }
        public DateTime? DataConsulta { get; init; }
        public DateTime? DataAtualizacao { get; init; }

        public string? AtividadePrincipalJson { get; init; }
        public string? AtividadesSecundariasJson { get; init; }
        public string? QsaJson { get; init; }
    }
}
