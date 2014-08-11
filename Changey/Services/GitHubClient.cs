using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Changey.Model;
using Octokit;
using Octokit.Internal;

namespace Changey.Services
{
    public class GitHubClient
    {
        private readonly string _owner;
        private readonly string _repository;
        private readonly Octokit.GitHubClient _client;
        private IReadOnlyList<Reference> _allTagReferences;

        public GitHubClient(string owner, string repository, string token)
        {
            _owner = owner;
            _repository = repository;

            var connection = new Connection(new ProductHeaderValue("Changey", "0.1"),
                new InMemoryCredentialStore(new Credentials(token)));
            _client = new Octokit.GitHubClient(connection);
        }

        public async Task<GitTag> GetTagAsync(string tagName)
        {
            _allTagReferences = _allTagReferences ?? await _client.GitDatabase.Reference
                .GetAllForSubNamespace(_owner, _repository, "tags");

            var targetRef = "refs/tags/" + tagName;
            var desiredTag = _allTagReferences.FirstOrDefault(tag => tag.Ref == targetRef);
            if (desiredTag == null)
                throw new ApplicationException("Tag not found: " + tagName);

            return await _client.GitDatabase.Tag.Get(_owner, _repository, desiredTag.Object.Sha);
        }

        public async Task<Release> GetPreviousReleaseAsync(bool isPrerelease)
        {
            return (await _client.Release.GetAll(_owner, _repository))
                .OrderByDescending(release => release.CreatedAt)
                .FirstOrDefault(release => release.Prerelease == isPrerelease);
        }

        public async Task<IEnumerable<Issue>> GetIssuesClosedAsync(DateTimeOffset since, DateTimeOffset until)
        {
            var issues = await _client.Issue.GetForRepository(_owner, _repository, new RepositoryIssueRequest
            {
                State = ItemState.Closed,
                SortProperty = IssueSort.Updated,
                SortDirection = SortDirection.Ascending,
                Since = since
            });
            return issues.Where(issue => issue.ClosedAt > since && issue.ClosedAt <= until && issue.PullRequest == null);
        }

        public async Task<Release> SaveReleaseNotesAsync(ReleaseNotes notes, bool preRelease, bool dryRun)
        {
            return dryRun
                ? new Release { TagName = notes.Tag, Name = notes.Title, Body = notes.Body, Prerelease = preRelease}
                : await this.CreateReleaseAsync(notes.Tag, notes.Title, notes.Body, preRelease);
        }

        private async Task<Release> CreateReleaseAsync(string tagName, string title, string body, bool prerelease)
        {
            return await _client.Release.Create(_owner, _repository, new ReleaseUpdate(tagName)
            {
                Name = title,
                Body = body,
                Draft = false,
                Prerelease = prerelease
            });
        }
    }
}