using System;
using System.Collections.Generic;
using System.Linq;
using Octokit;

namespace Changey
{
    public static class LabelExtensions
    {
        public static bool MatchesAny(this Label @this, IEnumerable<string> labels)
        {
            return labels.Any(label => string.Equals(@this.Name, label, StringComparison.InvariantCultureIgnoreCase));
        }
    }
}