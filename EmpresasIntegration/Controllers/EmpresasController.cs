using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using EmpresasIntegration.Data;
using EmpresasIntegration.Models;
using EmpresasIntegration.Services;
using Shared.Helpers;

namespace EmpresasIntegration.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmpresasController : ControllerBase
    {
        private readonly AppDbContext _db;
        private readonly ReceitawsService _receita;

        public EmpresasController(AppDbContext db, ReceitawsService receitawsService)
        {
            _db = db;
            _receita = receitawsService;
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

        // Novo endpoint: busca por CNPJ (normalizado ou formatado)
        // GET api/empresas/cnpj/{cnpj}
        [HttpGet("cnpj/{cnpj}")]
        public async Task<IActionResult> GetByCnpj(string cnpj)
        {
            if (string.IsNullOrWhiteSpace(cnpj))
                return BadRequest("CNPJ obrigatório.");

            var normalized = CnpjHelper.Normalize(cnpj);
            if (!CnpjHelper.IsValidBasic(normalized))
                return BadRequest("CNPJ inválido. Deve conter 14 dígitos.");

            Empresa? empresa = null;

            // 1) Tentar buscar pela coluna shadow/explicit CnpjNormalized (eficiente se mapeada e populada)
            try
            {
                empresa = await _db.Empresas
                    .Where(e => EF.Property<string>(e, "CnpjNormalized") == normalized)
                    .FirstOrDefaultAsync();
            }
            catch
            {
                // Se EF.Property lançar (coluna não mapeada), ignoramos e vamos para fallback
                empresa = null;
            }

            // 2) Fallback: buscar comparando dígitos do campo Cnpj (ineficiente em tabelas grandes)
            if (empresa == null)
            {
                empresa = await Task.Run(() =>
                    _db.Empresas
                       .AsEnumerable()
                       .FirstOrDefault(e => CnpjHelper.Normalize(e.Cnpj) == normalized)
                );
            }

            if (empresa != null)
            {
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

            // 3) Não encontrado localmente: consultar a Receita e persistir
            try
            {
                var fetched = await _receita.FetchAndSaveAsync(normalized);
                if (fetched == null) return NotFound();

                var endereco = $"{fetched.Logradouro}, {fetched.Numero} {fetched.Complemento}, {fetched.Bairro}, {fetched.Municipio} - {fetched.Uf}, {fetched.Cep}";
                return Ok(new
                {
                    fetched.Id,
                    fetched.Cnpj,
                    fetched.Nome,
                    fetched.Fantasia,
                    fetched.Situacao,
                    fetched.Tipo,
                    fetched.NaturezaJuridica,
                    fetched.AtividadePrincipalJson,
                    Endereco = endereco,
                    fetched.Email,
                    fetched.Telefone,
                    fetched.Abertura,
                    fetched.DataSituacao,
                    fetched.CapitalSocial,
                    fetched.CreatedAt,
                    fetched.UpdatedAt
                });
            }
            catch (HttpRequestException ex)
            {
                return StatusCode(502, $"Erro ao consultar serviço externo: {ex.Message}");
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(502, $"Resposta inválida do serviço externo: {ex.Message}");
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Erro interno: {ex.Message}");
            }
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
                AtividadePrincipalJson = dto.AtividadePrincipalJson,
                CreatedAt = DateTime.UtcNow
            };

            _db.Empresas.Add(empresa);
            await _db.SaveChangesAsync();

            return CreatedAtAction(nameof(GetEmpresa), new { id = empresa.Id }, empresa);
        }

        public class EmpresaDto
        {
            public string? Cnpj { get; set; }
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