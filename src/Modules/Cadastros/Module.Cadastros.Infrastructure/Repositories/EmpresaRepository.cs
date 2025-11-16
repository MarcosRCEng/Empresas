using Module.Cadastros.Infrastructure.Persistence;

namespace Module.Cadastros.Infrastructure.Repositories
{
    public class EmpresaRepository
    {
        private readonly CadastrosDbContext _context;

        public EmpresaRepository(CadastrosDbContext context)
        {
            _context = context;
        }

        public int ContarEmpresas()
        {
            return 0;
        }
    }
}
