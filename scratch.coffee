escodegen = require 'escodegen'
esprima = require 'esprima'
pj = require 'prettyjson'
PEG = require 'pegjs'
fs = require 'fs'

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

#peg_parser = fs.readFileSync('indent_block.pegjs').toString()

#fs.readFileSync('indent_block.pegjs').toString()
peg_parser = """
{
  var indent_depth = 0;
  var indentStack = [];
  }
start = Line
Line = indent:SAMEDENT identifier:Identifier _ EOL?
  children:(INDENT lines:Line* DEDENT {return lines;})
  {
    console.log(identifier, indent_depth)
    return indent+identifier;
  }

INDENT = indent:$(Whitespace+) {
  indent_depth = indent.length;
  indentStack.push(indent);
  }

DEDENT
  = { indent = indentStack.pop(); }

SAMEDENT = i:" "* &{
  return i.join("") === indent_depth;
}

EOL = [\\n\\r\\u2028\\u2029]
Whitespace = " "
_ = Whitespace*
__ = Whitespace+
Identifier = $([a-zA-Z]+)

"""

code = """
ar
  b
"""
p '-----------' + new Date
data = parse_with_gen peg_parser, code
p data
