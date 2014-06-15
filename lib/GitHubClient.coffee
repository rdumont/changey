request = require 'request'
Q = require 'q'
_ = require 'lodash'

class GitHubClient
  defaultHeaders = null
  constructor: (options) ->
    @repository = options.repository
    @version = options.version
    @prerelease = @version.indexOf('-') > 1
    @credentials = options.credentials
    defaultHeaders = 
      Authorization: "token #{@credentials.accessToken}"
      'User-Agent': "VTEX Release Manager"

  apiEndpoint = 'https://api.github.com/'
  isSuccessStatusCode = (statusCode) ->
    statusCode >= 200 and statusCode < 300

  get = (path, qs) ->
    deferred = Q.defer()
    options =
      url: apiEndpoint + path
      qs: qs
      headers: defaultHeaders

    request options, (error, response, body) ->
      if isSuccessStatusCode response.statusCode
        deferred.resolve JSON.parse(body)
      else
        deferred.reject JSON.parse(body)

    deferred.promise

  post = (path, json) ->
    deferred = Q.defer()
    options =
      url: apiEndpoint + path
      method: 'POST'
      json: json
      headers: defaultHeaders
  
    request options, (error, response, body) ->
      if isSuccessStatusCode response.statusCode
        deferred.resolve body
      else
        deferred.reject body

    deferred.promise

  getLastRelease: =>
    get "repos/#{@repository}/releases"
    .then (releases) =>
      _.find releases, prerelease: @prerelease

  getIssuesClosedSince: (isoDate) =>
    get "repos/#{@repository}/issues",
      state: 'closed'
      since: isoDate
      per_page: 100
      sort: 'updated'
    .then (issues) ->
      date = Date.parse isoDate
      issues = _.filter issues, (issue) ->
        not issue.pull_request and Date.parse(issue.closed_at) > date
      issues.reverse()

  createRelease: (tagName, name, body, dryRun) =>
    release = 
      tag_name: tagName
      name: name
      body: body
      prerelease: @prerelease

    return Q(release) if dryRun
    post "repos/#{@repository}/releasesNOOOO", release

module.exports = GitHubClient