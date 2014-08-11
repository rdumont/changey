using System.Text.RegularExpressions;

namespace Changey
{
    public static class CustomFilters
    {
        public static string StripLeadingV(string original)
        {
            return original == null ? null : Regex.Replace(original, "^(v|V)", string.Empty);
        }
    }
}
