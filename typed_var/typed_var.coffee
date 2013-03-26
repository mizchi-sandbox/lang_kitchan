escodegen = require 'escodegen'
esprima = require 'esprima'
pj = require 'prettyjson'
PEG = require 'pegjs'

p = console.log.bind console

# show ast tree
get_js_ast = (code) -> pj.render esprima.parse code
json_dump = (code)-> p pj.render code

# pegjs parser
gen_parser = (src) -> PEG.buildParser src
parse_with_gen = (parser_code, code) ->
  parser = gen_parser parser_code
  parser.parse code

# pegjs parser and ast
parse_with_gen_and_escodegen = (parser_code, code) ->
  parser = gen_parser parser_code
  escodegen.generate parser.parse code

parse_with_gen_and_escodegen_exec = (parser_code, code) ->
  eval parse_with_gen_and_escodegen parser_code, code

peg_parser = """


start = Program

Program = expressions:Expression+ {
    return {
      type:"Program",
      body: expressions
    }
  };

Expression
  = exp:AssignmentExpression {
    return {
      type: "ExpressionStatement",
      expression: exp
    };
  }

AssignmentExpression
  = left:identifier _ ":" _ annotationType:identifier _ "=" _ right:Literal
  {
    return {
      type: "AssignmentExpression",
      operator: "=",
      left:{
        name: left,
        type: "Identifier",
        annotationType: annotationType
      },
      right: right
    };
  }


Literal = value:(number)
  {
    return {
      type: "Literal",
      value: Number(value)
    };
  }

whitespace = " "
_ = whitespace*
__ = whitespace+


number = $([1-9] [0-9]*)
identifier = $([a-zA-Z] [a-zA-Z0-9]*)
"""
code = """
a : Number = 3
"""

p '-----------' + new Date
json_dump parse_with_gen peg_parser, code
p parse_with_gen_and_escodegen peg_parser, code
p '-----------'
p get_js_ast "var a = 3;"
