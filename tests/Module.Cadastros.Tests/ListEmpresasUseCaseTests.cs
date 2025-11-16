*** Add File: tests/Module.Cadastros.Tests/ListEmpresasUseCaseTests.cs
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Moq;
using Xunit;
using Module.Cadastros.Domain.Repositories;
using Module.Cadastros.Domain.Entities;
using Module.Cadastros.Application.UseCases;
using Module.Cadastros.Application.DTOs;

namespace Module.Cadastros.Tests
{
    public class ListEmpresasUseCaseTests
    {
        [Fact]
        public async Task ExecuteAsync_ReturnsPagedResult_WithFilters()
        {
            var repoMock = new Mock<IEmpresaRepository>();
            var sample = new List<Empresa> { new Empresa("62934252000145", "Yamaha") };
            repoMock.Setup(r => r.QueryAsync(It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), 1, 20))
                    .ReturnsAsync((sample.AsEnumerable(), 1L));

            var useCase = new ListEmpresasUseCase(repoMock.Object);
            var result = await useCase.ExecuteAsync(new EmpresaQuery { Nome = "Yamaha", Page = 1, PageSize = 20 });

            Assert.Equal(1, result.Total);
            Assert.Single(result.Items);
            Assert.Equal("Yamaha", result.Items.First().Nome);
        }
    }
}
