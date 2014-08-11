using System;
using System.Collections.Generic;
using System.Linq;
using DotLiquid;
using Octokit;

namespace Changey.Services
{
    public class IssueDrop : Drop
    {
        public int Number { get; set; }

        public string Title { get; set; }

        public Uri Url { get; set; }

        public string[] Labels { get; set; }

        public IssueDrop(Issue issue, IEnumerable<string> excludedLabels)
        {
            Number = issue.Number;
            Title = issue.Title;
            Url = issue.HtmlUrl;
            Labels = issue.Labels.Where(label => !label.MatchesAny(excludedLabels))
                .Select(label => label.Name).ToArray();
        }
    }
}