using System;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using EmpresasIntegration.Data;
using EmpresasIntegration.Models;
using Microsoft.EntityFrameworkCore;

namespace EmpresasIntegration.Services
{
    public class ReceitawsService
    {
        private readonly IHttpClientFactory _httpFactory;
        private readonly AppDbContext _db;

        public ReceitawsService(IHttpClientFactory httpFactory, AppDbContext db)
        {
            _httpFactory = httpFactory;
            _db = db;
        }

        public async Task<Empresa> FetchAndSaveAsync(string cnpj)
        {
            // Limpar o CNPJ do parâmetro (remover formatação)
            var cnpjLimpo = CleanCnpj(cnpj);
            
            var client = _httpFactory.CreateClient();
            var url = $"https://www.receitaws.com.br/v1/cnpj/{cnpjLimpo}";
            using var resp = await client.GetAsync(url);
            resp.EnsureSuccessStatusCode();
            var json = await resp.Content.ReadAsStringAsync();

            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;

            var cnpjRaw = TryGet(root, "cnpj");
            if (string.IsNullOrWhiteSpace(cnpjRaw))
                throw new InvalidOperationException("Resposta da API nÃ£o contÃ©m CNPJ.");

            // Limpar o CNPJ recebido da API antes de salvar
            var cnpjParaSalvar = CleanCnpj(cnpjRaw);

            var empresa = await _db.Empresas.SingleOrDefaultAsync(e => e.Cnpj == cnpjParaSalvar);
            var now = DateTime.UtcNow;
            if (empresa == null)
            {
                empresa = new Empresa { Cnpj = cnpjParaSalvar, CreatedAt = now };
                _db.Empresas.Add(empresa);
            }
            
            // Atualizar o CNPJ para garantir que está limpo
            empresa.Cnpj = cnpjParaSalvar;

            empresa.Nome = TryGet(root, "nome");
            empresa.Fantasia = TryGet(root, "fantasia");
            empresa.Situacao = TryGet(root, "situacao");
            empresa.Tipo = TryGet(root, "tipo");
            empresa.NaturezaJuridica = TryGet(root, "natureza_juridica");
            empresa.Logradouro = TryGet(root, "logradouro");
            empresa.Numero = TryGet(root, "numero");
            empresa.Complemento = TryGet(root, "complemento");
            empresa.Bairro = TryGet(root, "bairro");
            empresa.Municipio = TryGet(root, "municipio");
            empresa.Uf = TryGet(root, "uf");
            empresa.Cep = TryGet(root, "cep");
            empresa.Email = TryGet(root, "email");
            empresa.Telefone = TryGet(root, "telefone");
            empresa.UltimaAtualizacao = TryGet(root, "ultima_atualizacao");
            empresa.Abertura = ParseDate(TryGet(root, "abertura"));
            empresa.DataSituacao = ParseDate(TryGet(root, "data_situacao"));
            empresa.CapitalSocial = ParseDecimal(TryGet(root, "capital_social"));

            if (root.TryGetProperty("atividade_principal", out var ap)) empresa.AtividadePrincipalJson = ap.GetRawText();
            if (root.TryGetProperty("atividades_secundarias", out var asd)) empresa.AtividadesSecundariasJson = asd.GetRawText();
            if (root.TryGetProperty("qsa", out var qsa)) empresa.QsaJson = qsa.GetRawText();

            empresa.UpdatedAt = now;

            await _db.SaveChangesAsync();

            return empresa;
        }

        private static string? TryGet(JsonElement root, string prop)
        {
            return root.TryGetProperty(prop, out var p) && p.ValueKind != JsonValueKind.Null ? p.GetString() : null;
        }

        private static DateTime? ParseDate(string? s)
        {
            if (string.IsNullOrWhiteSpace(s)) return null;
            
            DateTime dt;
            if (DateTime.TryParse(s, out dt))
            {
                // Garantir que a data seja UTC para PostgreSQL
                if (dt.Kind == DateTimeKind.Unspecified)
                {
                    dt = DateTime.SpecifyKind(dt, DateTimeKind.Utc);
                }
                else if (dt.Kind == DateTimeKind.Local)
                {
                    dt = dt.ToUniversalTime();
                }
                return dt;
            }
            
            if (DateTime.TryParseExact(s, "dd/MM/yyyy", null, System.Globalization.DateTimeStyles.None, out dt))
            {
                // Datas parseadas como "dd/MM/yyyy" são consideradas como meia-noite UTC
                dt = DateTime.SpecifyKind(dt, DateTimeKind.Utc);
                return dt;
            }
            
            return null;
        }

        private static decimal? ParseDecimal(string? s)
        {
            if (string.IsNullOrWhiteSpace(s)) return null;
            if (decimal.TryParse(s, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out var d)) return d;
            var t = s.Replace(".", "").Replace(",", ".");
            if (decimal.TryParse(t, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out d)) return d;
            return null;
        }
        
        /// <summary>
        /// Remove caracteres de formatação do CNPJ, deixando apenas números
        /// </summary>
        private static string CleanCnpj(string? cnpj)
        {
            if (string.IsNullOrWhiteSpace(cnpj))
                return string.Empty;
            
            // Remove pontos, barras e hífens, mantendo apenas números
            return new string(cnpj.Where(char.IsDigit).ToArray());
        }
    }
}
