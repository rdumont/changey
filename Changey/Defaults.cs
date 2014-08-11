using System.Collections.Generic;
using Changey.Model;
using DotLiquid;

namespace Changey
{
    public static class Defaults
    {
        private const string DefaultTitleSource = @"{{ tag  | strip_leading_v }}";
        private const string DefaultBodySource = @"{% for category in categories -%}
{% if category.has_issues -%}
### {{ category.title }}

{% for issue in issues[category.id] -%}
* #{{ issue.number}} - {{ issue.title }}
{% endfor -%}

{% endif -%}
{% endfor -%}";

        public static Template TitleTemplate { get; private set; }

        public static Template BodyTemplate { get; private set; }

        public static IReadOnlyList<Category> Categories { get; private set; }

        static Defaults()
        {
            Template.RegisterFilter(typeof(CustomFilters));
            TitleTemplate = Template.Parse(DefaultTitleSource);
            BodyTemplate = Template.Parse(DefaultBodySource);
            Categories = new[]
            {
                new Category("features", "Features", new[] {"feature", "enhancement"}),
                new Category("bugs", "Bugs", new[] {"bug"}),
                new Category("chores", "Chores", new[] {"chore", "task"})
            };
        }
    }
}