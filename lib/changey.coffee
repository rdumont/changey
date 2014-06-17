fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'

hasLabel = (issue, names) ->
  return true if names.length == 0
  (issue.labels or []).some (label) ->
    names.some (name) -> name.toLowerCase() is label.name.toLowerCase()

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
  conditions.users and conditions.users.some (user) ->
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
  _hasLabel: hasLabel
  _writeIssues: writeIssues
  _meetsConditions: meetsConditions
  readConfiguration: readConfiguration
  filter: filter
  createReleaseBody: createReleaseBody
