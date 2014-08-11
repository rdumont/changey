using System;
using System.Linq;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.Http;
using Changey.Model;
using Changey.Services;

namespace Changey.Controllers
{
    public class ReleaseNotesController : ApiController
    {
        [HttpPost, Route("repos/{owner}/{repo}/releases/{tag}")]
        public async Task<IHttpActionResult> CreateReleaseNotes(string owner, string repo, string tag,
            ReleaseNotesRequest payload, bool dryRun = false)
        {
            var authorizationToken = GetAuthorizationToken();
            if (string.IsNullOrWhiteSpace(authorizationToken))
                return Unauthorized(new AuthenticationHeaderValue("token"));

            payload = payload ?? new ReleaseNotesRequest();

            var client = new GitHubClient(owner, repo, authorizationToken);
            var composer = new ReleaseNotesComposer(client);

            var preRelease = tag.Contains("-");
            var timeRange = await composer.GetIssuesTimeRangeAsync(tag, payload.ReferenceTag, preRelease);

            var releaseNotes = await composer.ComposeAsync(tag, timeRange.Item1, timeRange.Item2,
                payload.CreateCategories(), payload.TitleTemplate, payload.BodyTemplate);

            var release = await client.SaveReleaseNotesAsync(releaseNotes, preRelease, dryRun);
            return Json(new ReleaseResponse(release));
        }

        private string GetAuthorizationToken()
        {
            var header = this.Request.Headers.Authorization;
            return header == null || header.Scheme != "token" || string.IsNullOrWhiteSpace(header.Parameter)
                ? null
                : header.Parameter;
        }
    }
}