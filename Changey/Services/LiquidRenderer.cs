using System.Collections.Generic;
using System.Linq;
using Changey.Model;
using DotLiquid;
using Octokit;

namespace Changey.Services
{
    public class LiquidRenderer
    {
        private readonly Hash _variables;

        public LiquidRenderer(string tag, IReadOnlyList<Category> categories, IEnumerable<Issue> issues)
        {
            if (categories == null || !categories.Any())
                categories = Defaults.Categories;

            var issuesVariable = categories.ToDictionary(
                cat => cat.Id,
                cat => issues.Where(issue => issue.Labels.Any(label => label.MatchesAny(cat.Labels)))
                    .Select(issue => new IssueDrop(issue, cat.Labels)));
            var categoriesVariable = categories.Select(category => new CategoryDrop(category.Id, category.Title,
                issuesVariable.ContainsKey(category.Id) && issuesVariable[category.Id].Any()));

            _variables = new Hash
            {
                {"tag", tag},
                {"categories", categoriesVariable},
                {"issues", issuesVariable}
            };
        }

        public string RenderTitle(string templateSource)
        {
            var template = string.IsNullOrWhiteSpace(templateSource)
                ? Defaults.TitleTemplate
                : Template.Parse(templateSource);
            return template.Render(_variables);
        }

        public string RenderBody(string templateSource)
        {
            var template = string.IsNullOrWhiteSpace(templateSource)
                ? Defaults.BodyTemplate
                : Template.Parse(templateSource);
            return template.Render(_variables);
        }
    }
}