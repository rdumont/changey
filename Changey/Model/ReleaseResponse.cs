using Octokit;

namespace Changey.Model
{
    public class ReleaseResponse
    {
        public int Id { get; set; }

        public string TagName { get; set; }

        public string Title { get; set; }

        public string Body { get; set; }

        public string Url { get; set; }

        public ReleaseResponse(string tag, string title, string body)
        {
            TagName = tag;
            Title = title;
            Body = body;
        }

        public ReleaseResponse(Release release)
        {
            Id = release.Id;
            TagName = release.TagName;
            Title = release.Name;
            Body = release.Body;
            Url = release.HtmlUrl;
        }
    }
}