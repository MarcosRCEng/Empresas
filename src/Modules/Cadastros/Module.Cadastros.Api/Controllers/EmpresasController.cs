using Microsoft.AspNetCore.Mvc;

namespace Module.Cadastros.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmpresasController : ControllerBase
    {
        [HttpGet]
        public IActionResult Get()
        {
            return Ok("API Empresas funcionando");
        }
    }
}
