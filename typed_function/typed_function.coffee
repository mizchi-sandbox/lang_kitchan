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

Program = lines:Line+ {
    return {
      type:"Program",
      body: lines
    };
  }

Line = expression:Expression LineTerminator? {return expression}

whitespace = " "
_ = whitespace*
__ = whitespace+
LineTerminator = [\\n\\r\\u2028\\u2029]

Literal = value:(Number)
  {
    return {
      type: "Literal",
      value: Number(value)
    };
  }


Number = $(("+" / "-")? [1-9] [0-9]*)

Ident = TypedIdentifier / Identifier

  Identifier = identifier:$([a-zA-Z] [a-zA-Z0-9]*) {
    return {type:"Identifier", name: identifier}
  }

  TypedIdentifier = identifier:Identifier _ ":" _ TypeClass:Identifier  {
    identifier.anotation = {TypeClass:TypeClass};
    return identifier;
  }

BlockStatement = expressions:Expression+ {
  return {
    type:"BlockStatement",
    body: expressions
  };
}


Expression
  = exp:( AssignmentExpression / Literal ) {
      return {
        type: "ExpressionStatement",
        expression: exp
      };
    }

  AssignmentExpression
    = left:Ident _ "=" _ right:(Literal / FunctionExpression)
    {
      return {
        type: "AssignmentExpression",
        operator: "=",
        left: left,
        right: right
      };
    }

FunctionExpression
  = param:FunctionParamEnd?  _ "->" _ body:BlockStatement {
      return {
        type: "FunctionExpression",
        id: null,
        params: [param],
        body: body
      };
    }
  / "(" _ params: FunctionParams _ ")" _ "->" _ body:BlockStatement {
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

"""

code = """
x = 3
f:Function = a:Number -> 3
"""

p '-----------' + new Date
json_dump parse_with_gen peg_parser, code
p parse_with_gen_and_escodegen peg_parser, code

p '-----------'
#p get_js_ast "a = function(a,b,c){a};"
