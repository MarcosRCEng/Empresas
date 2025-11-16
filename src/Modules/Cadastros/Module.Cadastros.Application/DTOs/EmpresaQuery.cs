namespace Module.Cadastros.Application.DTOs
{
    public class EmpresaQuery
    {
        public string? Cnpj { get; set; }
        public string? Uf { get; set; }
        public string? Municipio { get; set; }
        public string? Nome { get; set; }
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;
    }
}



