// Generated by CoffeeScript 1.7.1
(function() {
  var define, escodegen, esprima, evaluate, inspect, macros, traverse, util, _;

  esprima = require('esprima');

  escodegen = require('escodegen');

  _ = require('underscore');

  util = require('util');

  _.mixin({
    clear: function(obj) {
      var key, keys, _i, _len, _results;
      keys = _.keys(obj);
      _results = [];
      for (_i = 0, _len = keys.length; _i < _len; _i++) {
        key = keys[_i];
        _results.push(delete obj[key]);
      }
      return _results;
    }
  });

  _.mixin({
    replace: function(current, other) {
      _.clear(current);
      return _.extend(current, other);
    }
  });

  _.mixin({
    inspect: function(tree) {
      console.log(util.inspect(tree, {
        colors: true,
        depth: null
      }));
      return tree;
    }
  });

  traverse = function(ast, fn) {
    if (ast.type === 'Program') {
      ast.body = _(ast.body).map(function(child) {
        return traverse(child, fn);
      });
    } else if (ast.type === 'MemberExpression') {

    } else if (ast.type === 'Literal') {

    } else if (ast.type === 'Identifier') {

    } else if (ast.type === 'VariableDeclaration') {

    } else if (ast.type === 'ExpressionStatement') {
      ast.expression = traverse(ast.expression, fn);
    } else if (ast.type === 'AssignmentExpression') {
      ast.right = traverse(ast.right, fn);
    } else if (ast.type === 'FunctionExpression') {
      ast.body = traverse(ast.body, fn);
    } else if (ast.type === 'BlockStatement') {
      ast.body = _(ast.body).map(function(child) {
        return traverse(child, fn);
      });
    } else if (ast.type === 'CallExpression') {
      ast["arguments"] = _(ast["arguments"]).map(function(child) {
        return traverse(child, fn);
      });
    } else if (ast.type === 'ReturnStatement') {
      ast.argument = traverse(ast.argument, fn);
    } else if (ast.type === 'IfStatement') {
      ast.test = traverse(ast.test, fn);
      ast.consequent = traverse(ast.consequent, fn);
      if (ast.alternate != null) {
        ast.alternate = traverse(ast.alternate, fn);
      }
    } else if (ast.type === 'BinaryExpression') {
      ast.left = traverse(ast.left, fn);
      ast.right = traverse(ast.right, fn);
    }
    return fn(ast);
  };

  _.mixin({
    traverse: traverse
  });

  macros = {};

  define = function(defines) {
    return macros = _(macros).extend(defines);
  };

  inspect = function(fn) {
    var code;
    code = "a=" + (fn.toString());
    return _(esprima.parse(code)).inspect();
  };

  evaluate = function(fn) {
    var ast, code;
    code = "a=" + (fn.toString());
    ast = _(esprima.parse(code)).traverse(function(node) {
      if (_(node.type).isEqual('CallExpression') && _(macros).has(node.callee.name)) {
        return macros[node.callee.name](node);
      } else {
        return node;
      }
    });
    ast.body = _(ast.body[0].expression.right.body.body).map(function(node) {
      if (node.type === "ReturnStatement") {
        return {
          type: "ExpressionStatement",
          expression: node.argument
        };
      } else {
        return node;
      }
    });
    code = escodegen.generate(ast);
    console.log(code);
    return code;
  };

  evaluate.define = define;

  evaluate.inspect = inspect;

  module.exports = evaluate;

}).call(this);
