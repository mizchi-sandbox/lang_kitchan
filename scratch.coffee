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
  = exp:(
    AssignmentExpression / Literal
    ) {
      return {
        type: "ExpressionStatement",
        expression: exp
      };
    }

AssignmentExpression
  = left:Identifier _ ":" _ annotationType:Identifier _ "=" _ right:(Literal / Function)
  {
    return {
      type: "AssignmentExpression",
      operator: "=",
      left: left,
      right: right
    };
  }


BlockStatement = Literal {
  return {
    type:"BlockStatement",
    body: []
  };
}

Function
  = "(" _ params: FunctionParams _ ")" _ "->" _ body:BlockStatement {
    return {
      type: "FunctionExpression",
      id: null,
      params: params,
      body: body
    };
  }

  FunctionParams = init:FunctionParam* _ last:FunctionParamEnd? {
    return init.concat([last]);
  }

  FunctionParam = _ ident:Ident _ "," {return ident;}
  FunctionParamEnd = ident:Ident  {return ident;}

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

Ident = Identifier / TypedIdentifier

  Identifier = identifier:$([a-zA-Z] [a-zA-Z0-9]*) {
    return {type:"Identifier", name: identifier}
  }

  TypedIdentifier = Identifier _ ":" _ TypeClass:Identifier  {
    return {type:"Identifier", name: identifier, anotation:{TypeClass:TypeClass}}
  }

"""
code = """
a : Number = ( a, b, c ) -> 3
"""


# right:
#   type:       FunctionExpression
#   id:         null
#   params:
#     -
#       type: Identifier
#       name: a
#   defaults:
#     (empty array)
#   body:
#     type: BlockStatement
#     body:
#       -
#         type:     ReturnStatement
#         argument:
#           type: Identifier
#           name: a
#   rest:       null
#   generator:  false
#   expression: false

p '-----------' + new Date
json_dump parse_with_gen peg_parser, code
p parse_with_gen_and_escodegen peg_parser, code
p '-----------'
#p get_js_ast "a = function(a){return a; };"
