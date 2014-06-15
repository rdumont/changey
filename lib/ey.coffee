fs = require 'fs'
_ = require 'lodash'
path = require 'path'
yaml = require 'js-yaml'

hasLabel = (issue, names) ->
  _.some issue.labels, (label) ->
    _.some names, (name) -> name.toLowerCase() is label.name.toLowerCase()

writeIssues = (title, issues) ->
  return "" if issues.length == 0

  "### #{title}\n" +
    issues.map (issue) -> "##{issue.number} - #{issue.title}"
    .join('\n') + '\n\n'

createReleaseBody = (issues, groups) ->
  body = for group in groups
    writeIssues group.heading,
      issues.filter((issue) -> hasLabel(issue, group.labels))
  body.join('')

meetsConditions = (issue, conditions) ->
  return true if conditions.users and _.some conditions.users, (user) ->
    user is issue.user.login

filter = (issues, include, exclude) ->
  if exclude
    issues.filter (issue) -> !meetsConditions issue, exclude
  else if include
    issues.filter (issue) -> meetsConditions issue, include
  else
    issues

readConfiguration = (filePath) ->
  filePath = filePath or '_changey.yaml'
  filePath = path.resolve filePath
  return yaml.safeLoad(fs.readFileSync filePath, 'utf8') if fs.existsSync filePath
  {}

module.exports =
  readConfiguration: readConfiguration
  filter: filter
  createReleaseBody: createReleaseBody
