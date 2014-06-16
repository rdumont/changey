Q = require 'q'
assert = require 'assert'
GitHubClient = require '../lib/GitHubClient.coffee'


createClient = (repo, version) ->
  new GitHubClient
    repository: repo or ''
    version: version or ''
    credentials: {}

describe 'GitHubClient', ->
  describe '#getLastRelease()', ->
    it 'should call GitHub to retrieve releases', (done) ->
      client = createClient 'some/repo'

      getPath = undefined
      getQueryString = {}
      client._get = (path, qs) ->
        getPath = path
        getQueryString = qs
        Q []

      client.getLastRelease().then (release) ->
        assert.equal getPath, 'repos/some/repo/releases'
        assert.equal getQueryString, undefined
        done()
      .fail (err) ->
        done(err)

    it 'should select single release when version is prerelease', (done) ->
      client = createClient()
      client.prerelease = true
      client._get = () ->
        Q [ name: 'only one', prerelease: true ]

      client.getLastRelease().then (release) ->
        assert.equal release.name, 'only one'
        done()
      .fail (err) ->
        done(err)

    it 'should select single release when version is not prerelease', (done) ->
      client = createClient()
      client.prerelease = false
      client._get = () ->
        Q [ name: 'only one', prerelease: false ]

      client.getLastRelease().then (release) ->
        assert.equal release.name, 'only one'
        done()
      .fail (err) ->
        done(err)

    it 'should select first release when version is prerelease', (done) ->
      client = createClient()
      client.prerelease = true
      client._get = () ->
        Q [
          name: 'wrong release', prerelease: false
        , name: 'correct release', prerelease: true
        ]

      client.getLastRelease().then (release) ->
        assert.equal release.name, 'correct release'
        done()
      .fail (err) ->
        done(err)

    it 'should select first release when version is not prerelease', (done) ->
      client = createClient()
      client.prerelease = false
      client._get = () ->
        Q [
          name: 'correct release', prerelease: false
        , name: 'wrong release', prerelease: true
        ]

      client.getLastRelease().then (release) ->
        assert.equal release.name, 'correct release'
        done()
      .fail (err) ->
        done(err)

    it 'should return undefined when there are no releases', (done) ->
      client = createClient()
      client._get = () ->
        Q []

      client.getLastRelease().then (release) ->
        assert.equal release, undefined
        done()
      .fail (err) ->
        done(err)

    it 'should return undefined when there are no prerelease releases', (done) ->
      client = createClient()
      client.prerelease = true
      client._get = () ->
        Q [ name: 'correct release', prerelease: false ]

      client.getLastRelease().then (release) ->
        assert.equal release, undefined
        done()
      .fail (err) ->
        done(err)

    it 'should return undefined when there are no non-prerelease releases', (done) ->
      client = createClient()
      client.prerelease = false
      client._get = () ->
        Q [ name: 'correct release', prerelease: true ]

      client.getLastRelease().then (release) ->
        assert.equal release, undefined
        done()
      .fail (err) ->
        done(err)

  describe '#getIssuesClosedSince(isoDate)', ->
    it 'should ask GitHub for the list of issues', (done) ->
      client = createClient 'some/repo'

      calledPath = ''
      calledQueryString = {}
      client._get = (path, qs) ->
        calledPath = path
        calledQueryString = qs
        Q []

      client.getIssuesClosedSince '2014-06-21T14:00Z'
      .then (issues) ->
        assert.equal calledPath, 'repos/some/repo/issues'
        assert.equal calledQueryString.state, 'closed'
        assert.equal calledQueryString.since, '2014-06-21T14:00Z'
        assert.equal calledQueryString.per_page, 100
        assert.equal calledQueryString.sort, 'updated'
        done()

      .fail (err) -> done(err)

    it 'should ignore pull requests', (done) ->
      client = createClient()
      client._get = ->
        Q [
          (name: 'one', closed_at: '2014-01-01', pull_request: undefined)
          (name: 'is a PR', closed_at: '2014-01-01', pull_request: { })
          (name: 'two', closed_at: '2014-01-01', pull_request: undefined)
          (name: 'is also PR', closed_at: '2014-01-01', pull_request: { })
        ]

      client.getIssuesClosedSince '2010-01-01'
      .then (issues) ->
        assert.equal issues.length, 2
        assert.deepEqual issues.map((issue) -> issue.name), [ 'two', 'one' ]
        done()

      .fail (err) -> done(err)

    it 'should ignore issues closed before the given date', (done) ->
      client = createClient()
      client._get = ->
        Q [
          (name: 'wrong one', closed_at: '2000-01-01')
          (name: 'ok one', closed_at: '2020-12-31')
          (name: 'wrong two', closed_at: '2000-01-01')
          (name: 'ok two', closed_at: '2020-12-31')
        ]

      client.getIssuesClosedSince '2010-01-01'
      .then (issues) ->
        assert.equal issues.length, 2
        assert.deepEqual issues.map((issue) -> issue.name), [ 'ok two', 'ok one' ]
        done()

      .fail (err) -> done(err)

    it 'should return empty when no issues are found', (done) ->
      client = createClient()
      client._get = ->
        Q []

      client.getIssuesClosedSince '2010-01-01'
      .then (issues) ->
        assert.equal issues.length, 0
        done()

      .fail (err) -> done(err)

  describe '#createRelease(tagName, name, body, dryRun)', ->
    it 'should create release when not dry running', (done) ->
      client = createClient 'some/repo'

      callPath = ''
      callJson = {}
      client._post = (path, json) ->
        callPath = path
        callJson = json
        Q {}

      client.createRelease 'sometag', 'bla bla bla', no
      .then () ->
        assert.equal callPath, 'repos/some/repo/releases'
        assert.equal callJson.tag_name, 'sometag'
        done()

      .fail (err) -> done(err)

    it 'should not create release when dry running', (done) ->
      client = createClient()

      postWasCalled = no
      client._post = (path, json) ->
        postWasCalled = yes
        Q {}

      client.createRelease 'sometag', 'bla bla bla', yes
      .then () ->
        assert.equal postWasCalled, no, '_post should not have been called'
        done()

      .fail (err) -> done(err)

    it 'should create a prerelease when version is prerelease', (done) ->
      client = createClient()
      client.prerelease = yes
      client._post = (path, json) -> Q json

      client.createRelease 'sometag', 'bla bla bla'
      .then (release) ->
        assert.equal release.prerelease, yes, 'should be prerelease'
        done()

      .fail (err) -> done err

    it 'should create a stable release version is not prerelease', (done) ->
      client = createClient()
      client.prerelease = no
      client._post = (path, json) -> Q json

      client.createRelease 'sometag', 'bla bla bla'
      .then (release) ->
        assert.equal release.prerelease, no, 'should be prerelease'
        done()

      .fail (err) -> done err

    it 'release should have name equal to tag name', (done) ->
      client = createClient()
      client._post = (path, json) -> Q json

      client.createRelease 'sometag', 'bla bla bla'
      .then (release) ->
        assert.equal release.name, 'sometag'
        done()

      .fail (err) -> done err

    it 'release should have leading "v" removed from its name', (done) ->
      client = createClient()
      client._post = (path, json) -> Q json

      client.createRelease 'v1.2.3', 'bla bla bla'
      .then (release) ->
        assert.equal release.name, '1.2.3'
        done()

      .fail (err) -> done err

    it 'release should keep leading "v" in its tag name', (done) ->
      client = createClient()
      client._post = (path, json) -> Q json

      client.createRelease 'v1.2.3', 'bla bla bla'
      .then (release) ->
        assert.equal release.tag_name, 'v1.2.3'
        done()

      .fail (err) -> done err

    it 'release should have the given body', (done) ->
      client = createClient()
      client._post = (path, json) -> Q json

      client.createRelease 'sometag', 'bla bla bla'
      .then (release) ->
        assert.equal release.body, 'bla bla bla'
        done()

      .fail (err) -> done err

