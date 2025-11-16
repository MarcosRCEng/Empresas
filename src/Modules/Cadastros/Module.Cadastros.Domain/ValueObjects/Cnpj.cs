using System;
using System.Text.RegularExpressions;

namespace Module.Cadastros.Domain.ValueObjects
{
    public sealed class Cnpj
    {
        public string Value { get; }

        private Cnpj(string value) => Value = value;

        public static Cnpj Normalize(string input)
        {
            if (input is null) throw new ArgumentNullException(nameof(input));
            var cleaned = Regex.Replace(input, @"\D", "");
            if (!IsValid(cleaned)) throw new ArgumentException("CNPJ inválido", nameof(input));
            return new Cnpj(cleaned);
        }

        public static bool IsValid(string input)
        {
            if (string.IsNullOrWhiteSpace(input)) return false;
            var v = Regex.Replace(input, @"\D", "");
            if (v.Length != 14) return false;

            var invalids = new[]
            {
                "00000000000000", "11111111111111", "22222222222222", "33333333333333",
                "44444444444444", "55555555555555", "66666666666666", "77777777777777",
                "88888888888888", "99999999999999"
            };

            foreach (var inv in invalids)
            {
                if (inv == v) return false;
            }

            var baseDigits = v.Substring(0, 12);
            var calc = CalculateDigits(baseDigits);
            return v.EndsWith(calc);
        }

        private static string CalculateDigits(string baseDigits)
        {
            int[] mult1 = { 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };
            int[] mult2 = { 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 };

            int sum = 0;
            for (int i = 0; i < 12; i++)
            {
                sum += (baseDigits[i] - '0') * mult1[i];
            }

            int rem = sum % 11;
            int d1 = rem < 2 ? 0 : 11 - rem;

            var temp = baseDigits + d1.ToString();
            sum = 0;
            for (int i = 0; i < 13; i++)
            {
                sum += (temp[i] - '0') * mult2[i];
            }

            rem = sum % 11;
            int d2 = rem < 2 ? 0 : 11 - rem;

            return string.Concat(d1, d2);
        }

        public override string ToString() => Value;
    }
}

