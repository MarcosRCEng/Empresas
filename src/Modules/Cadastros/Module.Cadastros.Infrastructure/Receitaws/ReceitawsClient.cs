using System.Net.Http;
using Module.Cadastros.Application.Interfaces;

namespace Module.Cadastros.Infrastructure.Receitaws
{
    public class ReceitawsClient : IReceitawsClient
    {
        private readonly IHttpClientFactory _httpClientFactory;

        public ReceitawsClient(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        public string ConsultarCnpj(string cnpj)
        {
            return $"Consulta simulada para CNPJ: {cnpj}";
        }
    }
}
