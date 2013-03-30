{
  var indent = 0, indentStack = [];
}

start = Line+
Line = SAMEDENT expr:Expr LineTerminator? {
  console.log(indent, indent.length);
  return expr;
}

Expr = Block / Identifier

INDENT = token:_ &{
  return token.length > indent;
}
{
  indent = token.length;
  indentStack.push(token);
  console.log("indent", indent, indentStack)
}

DEDENT = {
  indent = token.length;
  indentStack.pop(token);
  console.log("indent", indent, indentStack)
}

SAMEDENT = token:_ &{
  return token.length === indent;
}

Block
  = BlockStart expr:Expr BlockEnd {return expr}
  / INDENT expr:Expr DEDENT {return expr}

BlockStart = "{" {
  indent++;
  console.log("indent", indent)
}
BlockEnd = "}" {
  indent--;
  console.log("dedent", indent)
}

Identifier = $([a-zA-Z]+)

_ = $(Whitespace*)
Whitespace = [\t\v\f \u00A0\uFEFF]
LineTerminator = [\n\r\u2028\u2029]
