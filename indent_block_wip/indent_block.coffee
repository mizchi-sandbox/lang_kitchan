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
# peg_parser = fs.readFileSync('indent.pegjs').toString()
peg_parser = """
{var indent = 0; indentStack = [] }
start = Line
Line = SAMEDENT key:identifier EOL? child:(INDENT_BLOCK)? EOL?
  {
    var obj = {}
    obj[key] = child;
    return obj;
  }

INDENT_BLOCK = INDENT lines:Line+ DEDENT
  {
    var obj = {}

    //jsonize
    lines.forEach(function(line){
      for(var key in line)
        obj[key] = line[key]
    });
    return obj;
  }

  INDENT = spaces:$(__)
    & {
      return spaces.length > indent;
    }
    {
      indent = spaces.length;
      indentStack.push(indent);
      console.log("INDENT",spaces.length, indentStack);
    }

  DEDENT = {
    indent = indentStack.pop();
    console.log("DEDENT", indentStack);
    console.log("next indent", indent);
    }

identifier = $([a-z])
SAMEDENT = spaces:$(whitespace*)
  & {
    return spaces.length == indent;
  }
  {
    console.log('SAMEDENT', spaces.length);
    return spaces;
  }


whitespace = " "
_ = whitespace*
__ = $(whitespace+)
EOL = [\\n\\r\\u2028\\u2029]
"""

code = """
a
  b
  c
"""



p '-----------' + new Date
data = parse_with_gen peg_parser, code
p data
