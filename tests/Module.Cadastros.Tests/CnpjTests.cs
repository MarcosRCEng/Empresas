*** Add File: tests/Module.Cadastros.Tests/CnpjTests.cs
using Xunit;
using Module.Cadastros.Domain.ValueObjects;

namespace Module.Cadastros.Tests
{
    public class CnpjTests
    {
        [Fact]
        public void Normalize_RemovesMask_And_Validates()
        {
            var raw = "62.934.252/0001-45";
            var v = Cnpj.Normalize(raw);
            Assert.Equal("62934252000145", v.Value);
        }

        [Theory]
        [InlineData("00000000000000")]
        [InlineData("11111111111111")]
        public void IsValid_Rejects_InvalidPatterns(string candidate)
        {
            Assert.False(Cnpj.IsValid(candidate));
        }
    }
}
