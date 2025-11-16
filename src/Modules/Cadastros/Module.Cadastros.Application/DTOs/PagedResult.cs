using System.Collections.Generic;

namespace Module.Cadastros.Application.DTOs
{
    public class PagedResult<T>
    {
        public int Page { get; init; }
        public int PageSize { get; init; }
        public long Total { get; init; }
        public IEnumerable<T> Items { get; init; } = new List<T>();
    }
}



