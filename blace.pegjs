{
var indent = 0, indentStack = [];
}

start = Line+
Line = expr:(Block / Identifier) LineTerminator?
  {
    return expr
  }
Block = BlockStart LineTerminator? child:(
    pre:$(Whitespace*) expr:Line _ LineTerminator?
      {
        console.log("pre",pre.length)
        return expr
      }
    )+ BlockEnd _
  {
    return child;
  }
  BlockStart = "{" {
    indent++;
    console.log("indent", indent)
  }
  BlockEnd = "}" {
    indent--;
    console.log("dedent", indent)
  }

Identifier = $([a-zA-Z]+)

_ = (Whitespace)*
Whitespace = [\t\v\f \u00A0\uFEFF]
LineTerminator = [\n\r\u2028\u2029]
