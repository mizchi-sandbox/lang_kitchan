// do not use result cache, nor line and column tracking

{
  var indentStack = [], indent = "", p = console.log; }

start
  = INDENT? lines:( blank / line )*
    {
      p("line");
      return lines; }

line
  = SAMEDENT line:(!EOL c:. { return c; })+ EOL?
    children:( b:blank* INDENT c:( blank / line )* DEDENT { return b.concat(c); })?
    { return [line.join(""), children === "" ? [] : children]; }

blank
  = [ \t]* EOL
    { return undefined; }

EOL
  = "\r\n" / "\n" / "\r"

SAMEDENT
  = i:[ \t]* &{ return i.join("") === indent; }

INDENT
  = i:[ \t]+ &{ return i.length > indent.length; }
    { indentStack.push(indent); indent = i.join(""); pos = offset; }

DEDENT
  = { indent = indentStack.pop(); }
