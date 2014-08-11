using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Changey.Model;
using Changey.Services;

namespace Changey.Controllers
{
    public class ReleaseNotesComposer
    {
        private readonly GitHubClient _client;

        public ReleaseNotesComposer(GitHubClient client)
        {
            _client = client;
        }

        public async Task<Tuple<DateTimeOffset, DateTime>> GetIssuesTimeRangeAsync(string tag,
            string referenceTag, bool prerelease)
        {
            var targetTag = await _client.GetTagAsync(tag);
            var untilDate = targetTag.Tagger.Date;

            DateTimeOffset sinceDate;
            if (string.IsNullOrWhiteSpace(referenceTag))
            {
                var previousRelease = await _client.GetPreviousReleaseAsync(prerelease);
                sinceDate = previousRelease.CreatedAt;
            }
            else
            {
                var previousTag = await _client.GetTagAsync(referenceTag);
                sinceDate = previousTag.Tagger.Date;
            }

            return Tuple.Create(sinceDate, untilDate);
        }

        public async Task<ReleaseNotes> ComposeAsync(string tag, DateTimeOffset since, DateTime until,
            IReadOnlyList<Category> categories, string titleTemplate, string bodyTemplate)
        {
            var issues = await _client.GetIssuesClosedAsync(since, until);
            var renderer = new LiquidRenderer(tag, categories ?? Defaults.Categories, issues);

            var title = renderer.RenderTitle(titleTemplate);
            var body = renderer.RenderBody(titleTemplate);

            return new ReleaseNotes(tag, title, body);
        }
    }
}