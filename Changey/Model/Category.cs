namespace Changey.Model
{
    public class Category
    {
        public string Id { get; set; }

        public string Title { get; set; }

        public string[] Labels { get; set; }

        public Category(string id, string title, string[] labels)
        {
            Id = id;
            Title = title;
            Labels = labels;
        }
    }
}