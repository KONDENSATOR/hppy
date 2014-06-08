esprima    = require 'esprima'
escodegen  = require 'escodegen'
_          = require 'underscore'
util       = require 'util'

inspectAst = (tree) ->
  console.log(util.inspect(tree, {colors:true, depth:null}))
  tree

traverse = (ast, fn) ->
  if ast.type == 'Program'
    ast.body = _(ast.body).map((child) ->
      traverse(child, fn))

  else if ast.type == 'MemberExpression'
  else if ast.type == 'Literal'
  else if ast.type == 'Identifier'
  else if ast.type == 'VariableDeclaration'

  else if ast.type == 'ExpressionStatement'
    ast.expression = traverse(ast.expression, fn)

  else if ast.type == 'AssignmentExpression'
    ast.right = traverse(ast.right, fn)

  else if ast.type == 'FunctionExpression'
    ast.body = traverse(ast.body, fn)

  else if ast.type == 'BlockStatement'
    ast.body = _(ast.body).map((child) ->
      traverse(child, fn))

  else if ast.type == 'CallExpression'
    ast.arguments = _(ast.arguments).map((child) ->
      traverse(child, fn))

  else if ast.type == 'ReturnStatement'
    ast.argument = traverse(ast.argument, fn)

  else if ast.type == 'IfStatement'
    ast.test = traverse(ast.test, fn)
    ast.consequent = traverse(ast.consequent, fn)
    if ast.alternate?
      ast.alternate = traverse(ast.alternate, fn)

  else if ast.type == 'BinaryExpression'
    ast.left = traverse(ast.left, fn)
    ast.right = traverse(ast.right, fn)

  fn(ast)


macros = {}

define = (defines) ->
  macros = _(macros).extend(defines)

inspect = (fn) ->
  code = "a=#{fn.toString()}"
  inspectAst(esprima.parse(code))

evaluate = (fn) ->
  code = "a=#{fn.toString()}"
  ast = traverse(esprima.parse(code), (node) ->
    if _(node.type).isEqual('CallExpression') and
       _(macros).has(node.callee.name)
      macros[node.callee.name](node)
    else
      node)
  ast.body = _(ast.body[0].expression.right.body.body).map((node) ->
    if node.type == "ReturnStatement"
      type: "ExpressionStatement"
      expression: node.argument
    else
      node)
  escodegen.generate(ast)

evaluate.define = define
evaluate.inspect = inspect

module.exports = evaluate

