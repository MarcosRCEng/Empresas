using System.Linq;

namespace Shared.Helpers
{
    public static class CnpjHelper
    {
        public static string Normalize(string? cnpj)
        {
            if (string.IsNullOrWhiteSpace(cnpj)) return string.Empty;
            return new string(cnpj.Where(char.IsDigit).ToArray());
        }

        public static bool IsValidBasic(string? cnpj)
        {
            var d = Normalize(cnpj);
            return d.Length == 14;
        }

        public static string Format(string? cnpjDigits)
        {
            var d = Normalize(cnpjDigits);
            if (d.Length != 14) return cnpjDigits ?? string.Empty;
            return $"{d.Substring(0, 2)}.{d.Substring(2, 3)}.{d.Substring(5, 3)}/{d.Substring(8, 4)}-{d.Substring(12, 2)}";
        }
    }
}