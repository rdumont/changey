using System.Collections.Generic;
using System.Linq;

namespace Changey.Model
{
    public class ReleaseNotesRequest
    {
        public string ReferenceTag { get; set; }

        public CategoryRequest[] Categories { get; set; }

        public string TitleTemplate { get; set; }

        public string BodyTemplate { get; set; }

        public IReadOnlyList<Category> CreateCategories()
        {
            return this.Categories == null
                ? Defaults.Categories
                : this.Categories.Select(cat => cat.CreateCategory()).ToArray();
        }
    }
}