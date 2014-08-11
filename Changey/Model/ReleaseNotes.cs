namespace Changey.Model
{
    public class ReleaseNotes
    {
        public string Tag { get; set; }

        public string Title { get; set; }

        public string Body { get; set; }

        public ReleaseNotes(string tag, string title, string body)
        {
            Tag = tag;
            Title = title;
            Body = body;
        }
    }
}