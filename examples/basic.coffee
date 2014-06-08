hppy = require '../'
fs   = require 'fs'
_    = require 'underscore'

HPPY_CALLBACK_NAME = "hppy_callback"
HPPY_ERROR_NAME = "hppy_error"

NULLARG =
  type: 'Literal'
  value: null
  raw: 'null'
ERRORARG =
  type: 'Identifier'
  name: HPPY_ERROR_NAME
CALLBACKARG =
  type: 'Identifier'
  name: HPPY_CALLBACK_NAME

# This is where we define our macros
hppy.define(

  # Adds a callback argument named HPPY_CALLBACK_NAME as last param
  # to the declared function signature.
  #
  # Usage:
  #   myasyncfunction = cps((any, arguments) ->)
  #
  # Translates to:
  #   myasyncfunction = (any, arguments, hppy_callback) ->
  #
  cps: (ast) ->
    # Get the real function from the last argument of CPS
    f = _(ast.arguments).last()
    # Push the callback template parameter to the function arguments
    f.params.push(CALLBACKARG)
    # Return the modified function
    f

  # Adds a err parameter as a first param to the inlined function.
  # Then adds a if statement to the begining of the function that
  # checks if err is null or not. If err isn't null, it will
  # call the CPS callback function.
  #
  # Usage:
  #   fs.readFile(file, cont((text) -> console.log(text)))
  #
  # Translates to:
  #   fs.readFile(file, (err, text) ->
  #     if err?
  #       callback(err)
  #     else
  #       console.log(text))
  #
  cont: (ast) ->
    # Get the real function from the last argument of CPS
    f = _(ast.arguments).last()
    # Push the callback template parameter to the function arguments
    f.params.unshift(ERRORARG)
    # Return the modified function
    body = f.body.body
    f.body.body =
      type: 'IfStatement'
      test:
        type: 'BinaryExpression'
        operator: '!='
        left:
          type: 'Identifier'
          name: HPPY_ERROR_NAME
        right:
          type: 'Literal'
          value: null
          raw: 'null'
      consequent:
        type: 'BlockStatement'
        body:
          type: 'ReturnStatement'
          argument:
            type: 'CallExpression'
            callee:
              type: 'Identifier'
              name: HPPY_CALLBACK_NAME
            arguments: [
              type: 'Identifier'
              name: HPPY_ERROR_NAME ]
      alternate:
        type: 'BlockStatement'
        body: body
    f

  # 'Returns' the given value by passing it to the callback as
  # the second argument.
  #
  # Usage:
  #   ret(text)
  #
  # Translates to:
  #   callback(null, args)
  #
  ret: (ast) ->
    # Clone the ret arguments
    args = ast.arguments.slice()
    # Add a NULL template in the begining
    args.unshift(NULLARG)

    # Return new AST node
    type      : 'CallExpression'
    arguments : args
    callee    :
      type    : 'Identifier'
      name    : HPPY_CALLBACK_NAME

  # 'Returns' the given value by passing it to the callback as
  # the first argument.
  #
  # Usage:
  #   ret('My error message')
  #
  # Translates to:
  #   callback(args)
  #
  err: (ast) ->
    ast.callee.name = HPPY_CALLBACK_NAME
    ast)


# This code will be processed with the macros
eval(hppy(() ->
  myfunc = cps((fileName) ->
    fs.readFile(fileName, 'utf8', cont('myfunc', 'readfile', (data) ->
      if data.length == 0
        err("File empty!")
      else
        ret(data))))

  myfunc('testfile', (err, data) ->
    if err?
      # Log output for system administrators
      console.error err
    else
      console.log "No errors"
      console.log data)))

