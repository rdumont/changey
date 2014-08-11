using DotLiquid;

namespace Changey.Services
{
    public class CategoryDrop : Drop
    {
        public string Id { get; set; }

        public string Title { get; set; }

        public bool HasIssues { get; set; }

        public CategoryDrop(string id, string title, bool hasIssues)
        {
            Id = id;
            Title = title;
            HasIssues = hasIssues;
        }
    }
}
