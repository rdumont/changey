Q = require 'q'
assert = require 'assert'
changey = require '../lib/changey.coffee'

describe 'Changey', ->
  describe '#hasLabel(issue, names)', ->
    describe 'should accept', ->
      it 'when there are no labels nor names', ->
        result = changey._hasLabel {}, []
        assert result

      it 'when there are some labels and no names', ->
        issue = labels: ['blue', 'red'].map (name) -> name: name

        result = changey._hasLabel issue, []
        assert result

      it 'when one of the labels meet one of the names', ->
        issue = labels: ['blue', 'red'].map (name) -> name: name
        
        result = changey._hasLabel issue, [ 'red', 'green' ]
        assert result

    describe 'should reject', ->
      it 'when there are no labels but names are passed', ->
        result = changey._hasLabel {}, ['blue', 'red']
        assert not result

      it 'when none of the labels meet any of the names', ->
        issue = labels: ['blue', 'red'].map (name) -> name: name
        
        result = changey._hasLabel issue, [ 'yellow', 'green' ]
        assert not result

  describe '#writeIssues(title, issues)', ->
    it 'should return empty string when there are no issues', ->
      body = changey._writeIssues '', []
      assert.equal body, ''

    it 'result should start with level 3 heading with the group title', ->
      body = changey._writeIssues 'Features', [{}]
      assert /^### Features/.test(body)

    it 'result should end in two line breaks', ->
      body = changey._writeIssues '', [{}]
      assert /\n\n$/.test(body)

    it 'result should contain each formatted issue in its own line', ->
      issues = [
        (number: 123, title: 'one two three')
        (number: 456, title: 'four five six')
      ]
      body = changey._writeIssues '', issues

      assert body.indexOf("#123 - one two three\n") > 0
      assert body.indexOf("#456 - four five six\n") > 0

  describe '#meetsConditions(issue, conditions)', ->
    describe 'should succeed', ->
      it 'when the issue\'s user is one of the specified users', ->
        condition = users: ['grey', 'blue']
        issue = user: login: 'blue'
        result = changey._meetsConditions issue, condition
        assert result

    describe 'should fail', ->
      it 'when conditions include no users', ->
        result = changey._meetsConditions {}, {}
        assert not result

      it 'when the issue\'s user isn\'t any of the specified users', ->
        condition = users: ['grey', 'orange']
        issue = user: login: 'blue'
        result = changey._meetsConditions issue, condition
        assert not result
