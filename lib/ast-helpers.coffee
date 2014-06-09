# Defines a call expression
exports.callExpression = (name, args...) ->
  type      : 'CallExpression'
  callee    :
    type    : 'Identifier'
    name    : name
  arguments : args

exports.identifier = (name) ->
  type: 'Identifier'
  name: name

exports.nullLiteral = () ->
  type: 'Literal'
  value: null
  raw: 'null'

exports.binaryExpression = (operator, left, right) ->
  type: 'BinaryExpression'
  operator: operator
  left: left
  right: right

exports.ifStatement = (test, conseq, alt) ->
  type: 'IfStatement'
  test: test
  consequent: conseq
  alternate: alt

exports.blockStatement = (body) ->
  type: 'BlockStatement'
  body: body

exports.returnStatement = (argument) ->
  type: 'ReturnStatement'
  argument: argument


exports.functionName = (ast, name) ->
  if name?
    ast.callee.name = name
    ast
  else
    ast.callee.name
