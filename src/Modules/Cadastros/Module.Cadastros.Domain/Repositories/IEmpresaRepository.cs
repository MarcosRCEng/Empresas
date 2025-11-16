using System.Collections.Generic;
using System.Threading.Tasks;
using Module.Cadastros.Domain.Entities;

namespace Module.Cadastros.Domain.Repositories
{
    public interface IEmpresaRepository
    {
        Task<Empresa?> GetByCnpjAsync(string cnpj);
        Task UpsertAsync(Empresa empresa);
        Task<(IEnumerable<Empresa> Items, long Total)> QueryAsync(string? cnpj, string? uf, string? municipio, string? nome, int page, int pageSize);
    }
}

