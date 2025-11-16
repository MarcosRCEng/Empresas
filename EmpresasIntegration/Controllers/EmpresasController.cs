using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EmpresasIntegration.Data;
using EmpresasIntegration.Models;

namespace EmpresasIntegration.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmpresasController : ControllerBase
    {
        private readonly AppDbContext _db;

        public EmpresasController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> GetEmpresas()
        {
            var empresas = await _db.Empresas
                .Select(e => new { e.Id, e.Cnpj, e.Nome })
                .ToListAsync();

            return Ok(empresas);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetEmpresa(int id)
        {
            var empresa = await _db.Empresas.FindAsync(id);
            if (empresa == null) return NotFound();

            var endereco = $"{empresa.Logradouro}, {empresa.Numero} {empresa.Complemento}, {empresa.Bairro}, {empresa.Municipio} - {empresa.Uf}, {empresa.Cep}";

            return Ok(new
            {
                empresa.Id,
                empresa.Cnpj,
                empresa.Nome,
                empresa.Fantasia,
                empresa.Situacao,
                empresa.Tipo,
                empresa.NaturezaJuridica,
                empresa.AtividadePrincipalJson,
                Endereco = endereco,
                empresa.Email,
                empresa.Telefone,
                empresa.Abertura,
                empresa.DataSituacao,
                empresa.CapitalSocial,
                empresa.CreatedAt,
                empresa.UpdatedAt
            });
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateEmpresa(int id, [FromBody] EmpresaDto dto)
        {
            var empresa = await _db.Empresas.FindAsync(id);
            if (empresa == null) return NotFound();

            empresa.Nome = dto.Nome;
            empresa.Logradouro = dto.Logradouro;
            empresa.Numero = dto.Numero;
            empresa.Complemento = dto.Complemento;
            empresa.Bairro = dto.Bairro;
            empresa.Municipio = dto.Municipio;
            empresa.Uf = dto.Uf;
            empresa.Cep = dto.Cep;
            empresa.AtividadePrincipalJson = dto.AtividadePrincipalJson;

            await _db.SaveChangesAsync();
            return NoContent();
        }

        [HttpPost]
        public async Task<IActionResult> CreateEmpresa([FromBody] EmpresaDto dto)
        {
            var empresa = new Empresa
            {
                Cnpj = dto.Cnpj,
                Nome = dto.Nome,
                Logradouro = dto.Logradouro,
                Numero = dto.Numero,
                Complemento = dto.Complemento,
                Bairro = dto.Bairro,
                Municipio = dto.Municipio,
                Uf = dto.Uf,
                Cep = dto.Cep,
                AtividadePrincipalJson = dto.AtividadePrincipalJson
            };

            _db.Empresas.Add(empresa);
            await _db.SaveChangesAsync();

            return CreatedAtAction(nameof(GetEmpresa), new { id = empresa.Id }, empresa);
        }

        public class EmpresaDto
        {
            public string? Cnpj { get; set; } = string.Empty;
            public string? Nome { get; set; }
            public string? Logradouro { get; set; }
            public string? Numero { get; set; }
            public string? Complemento { get; set; }
            public string? Bairro { get; set; }
            public string? Municipio { get; set; }
            public string? Uf { get; set; }
            public string? Cep { get; set; }
            public string? AtividadePrincipalJson { get; set; }
        }
    }
}