using Changey.Model;

namespace Changey.Model
{
    public class CategoryRequest
    {
        public string Id { get; set; }

        public string Title { get; set; }

        public string[] Labels { get; set; }

        public Category CreateCategory()
        {
            return new Category(Id, Title, Labels);
        }
    }
}