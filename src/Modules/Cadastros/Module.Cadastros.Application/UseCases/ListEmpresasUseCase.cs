using System.Linq;
using System.Threading.Tasks;
using Module.Cadastros.Application.DTOs;
using Module.Cadastros.Domain.Repositories;

namespace Module.Cadastros.Application.UseCases
{
    public class ListEmpresasUseCase
    {
        private readonly IEmpresaRepository _repo;

        public ListEmpresasUseCase(IEmpresaRepository repo) => _repo = repo;

        public async Task<PagedResult<Module.Cadastros.Application.DTOs.EmpresaDto>> ExecuteAsync(EmpresaQuery query)
        {
            var (items, total) = await _repo.QueryAsync(query.Cnpj, query.Uf, query.Municipio, query.Nome, query.Page, query.PageSize);

            var dtos = items.Select(e => new Module.Cadastros.Application.DTOs.EmpresaDto
            {
                Id = e.Id,
                Cnpj = e.Cnpj,
                Nome = e.Nome,
                Fantasia = e.Fantasia,
                Situacao = e.Situacao,
                Municipio = e.Municipio,
                Uf = e.Uf,
                Abertura = e.Abertura,
                AtividadePrincipalJson = e.AtividadePrincipalJson
            });

            return new PagedResult<Module.Cadastros.Application.DTOs.EmpresaDto>
            {
                Page = query.Page,
                PageSize = query.PageSize,
                Total = total,
                Items = dtos
            };
        }
    }
}



