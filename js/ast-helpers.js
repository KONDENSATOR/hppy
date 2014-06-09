// Generated by CoffeeScript 1.7.1
(function() {
  var __slice = [].slice;

  exports.callExpression = function() {
    var args, name;
    name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    return {
      type: 'CallExpression',
      callee: {
        type: 'Identifier',
        name: name
      },
      "arguments": args
    };
  };

  exports.identifier = function(name) {
    return {
      type: 'Identifier',
      name: name
    };
  };

  exports.nullLiteral = function() {
    return {
      type: 'Literal',
      value: null,
      raw: 'null'
    };
  };

  exports.binaryExpression = function(operator, left, right) {
    return {
      type: 'BinaryExpression',
      operator: operator,
      left: left,
      right: right
    };
  };

  exports.ifStatement = function(test, conseq, alt) {
    return {
      type: 'IfStatement',
      test: test,
      consequent: conseq,
      alternate: alt
    };
  };

  exports.blockStatement = function(body) {
    return {
      type: 'BlockStatement',
      body: body
    };
  };

  exports.returnStatement = function(argument) {
    return {
      type: 'ReturnStatement',
      argument: argument
    };
  };

  exports.functionName = function(ast, name) {
    if (name != null) {
      ast.callee.name = name;
      return ast;
    } else {
      return ast.callee.name;
    }
  };

}).call(this);