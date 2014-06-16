require 'colors'
GitHubClient = require '../lib/GitHubClient'
changey = require '../lib/changey'

args = require('yargs')
  .usage 'Usage: changey <repo> <version> [options]'
  .demand 2, "You should specify <repo> and <version>"
  .describe 'token', 'GitHub access token'
  .alias 'token', 't'
  .demand 'token'
  .describe 'config', 'Configuration file path'
  .alias 'config', 'c'
  .describe 'dry-run', "Simulate the creation of a release instead of actually creating it"
  .argv

configuration = changey.readConfiguration args.config

options =
  repository: args._[0]
  version: args._[1]
  dryRun: args.dryRun
  credentials:
    accessToken: args.token
  groups: configuration.groups or [
      heading: 'Features'
      labels: ['feature', 'enhancement']
    ,
      heading: 'Bugs'
      labels: ['bug']
    ,
      heading: 'Chores'
      labels: ['chore', 'task']
  ],
  exclude: configuration.exclude
  include: configuration.include

console.log "Build changelog for v#{options.version} of #{options.repository}"

client = new GitHubClient(options)

if client.prerelease
  console.log ". getting latest release marked as prerelease"
else
  console.log ". getting latest stable release"

client.getLastRelease()
.then (release) ->
  console.log ". found release #{release.name}"
  console.log ". getting issues closed since #{release.created_at}"
  client.getIssuesClosedSince release.created_at

.then (issues) ->
  issues = changey.filter issues, options.include, options.exclude
  console.log ". found #{issues.length} issues"

  body = changey.createReleaseBody issues, options.groups

  console.log ". creating GitHub release for v#{options.version}"
  client.createRelease "v#{options.version}", options.version, body, options.dryRun

.then (release) ->
  if !options.dryRun
    console.log ". release created: #{release.html_url}"
  else
    console.log '. the following release would have been created'
    console.log "tag_name: #{release.tag_name.grey}".bold.white
    console.log "name: #{release.name.grey}".bold.white
    console.log "prerelease: #{release.prerelease.toString().grey}".bold.white
    console.log "body: |".bold.white
    console.log release.body.grey.replace(/^(.)/mg, '  $1')

.fail (error, body) ->
  console.error error
