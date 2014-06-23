hppy
====

Allows you to write Runtime macros for Node.js.

### What is it

Hppy takes a function and executes *.toString()* on it. It then parses the string into a AST with **esprima**.

First, it strips away the container function.

Now with the AST it iterates all the nodes looking for a call with a name that is defined within the *macros*. It passes the subnode to the declared macro function.

When all nodes are iterated, it compiles the new AST back to JavaScript again. This JavaScript is returned from the hppy function. Now it's up to you to evaluate it in the right context with *eval()*.

### Why

Because sometimes you want macros.

### Warning

This library is NOT ready for production use!

### Features

Gives you the ability to manipulate the AST.

### Future features

Helper functions for manipulating the AST more intuitively.

### Installation

```
npm install hppy
```

### Usage

```coffeescript
hppy = require('hppy')
```

Define macros

```coffeescript
hppy.define(
  mymacro: (ast) ->
)
```

Macro enabled code goes within the function passed to hppy.

```coffeescript
eval(hppy(() ->
)
```

### Practical example

```coffeescript
hppy = require '../'
fs   = require 'fs'
_    = require 'underscore'

HPPY_CALLBACK_NAME = "hppy_callback"
HPPY_ERROR_NAME = "hppy_error"

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
    #console.dir(ast)
    #return ast

    # Get the real function from the last argument of CPS
    f = _(ast.arguments).last()

    # Push the callback template parameter to the function arguments
    f.params.unshift(ERRORARG)

    # Return the modified function
    f.body = hppy.blockStatement([hppy.ifStatement(
      hppy.binaryExpression(
        hppy.NEQ
        ,hppy.identifier(HPPY_ERROR_NAME)
        ,hppy.nullLiteral()
      )
      ,hppy.blockStatement([
        hppy.returnStatement(
          hppy.callExpression(
            HPPY_CALLBACK_NAME
            ,hppy.identifier(HPPY_ERROR_NAME)
          )
        )]
      )
      ,f.body
    )])
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
    args.unshift(hppy.nullLiteral())

    # Return new AST node
    hppy.callExpression(HPPY_CALLBACK_NAME, args...)

  # 'Returns' the given value by passing it to the callback as
  # the first argument.
  #
  # Usage:
  #   ret('My error message')
  #
  # Translates to:
  #   callback(args)
  #
  err: (ast) -> hppy.functionName(ast, HPPY_CALLBACK_NAME))

print = (text) ->
  console.log(text)
  text

# This code will be processed with the macros
eval(print hppy(() ->
  myfunc = cps((fileName) ->
    fs.readFile(fileName, 'utf8', cont('myfunc', 'readfile', (data) ->
      if data.length == 0
        err("File empty!")
      else
        ret(null, data))))

  myfunc('testfile', (err, data) ->
    if err?
      # Log output for system administrators
      console.error err
    else
      console.log "No errors"
      console.log data)))

```
