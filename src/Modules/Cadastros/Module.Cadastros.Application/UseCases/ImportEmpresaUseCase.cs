using System.Threading.Tasks;
using Module.Cadastros.Application.DTOs;

namespace Module.Cadastros.Application.UseCases
{
    public class ImportEmpresaUseCase
    {
        public Task<EmpresaDto?> ExecuteAsync(string cnpj) => Task.FromResult<EmpresaDto?>(null);
    }
}

