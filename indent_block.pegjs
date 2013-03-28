{ var indentStack = [], indent = ""; }

start
  = INDENT? l:line
    { return l; }

line
  = SAMEDENT line:(!EOL c:$([a-z]))+ EOL? children:(
      INDENT c:line* DEDENT { return c; }
    )?
    {
      var o = {}; o[line] = children; return children ? o : line.join(""); }

EOL = [\\n\\r\\u2028\\u2029]

SAMEDENT
  = i:[ \t]* &{ return i.join("") === indent; }

INDENT
  = i:[ \t]+ &{ return i.length > indent.length; }
    { indentStack.push(indent); indent = i.join(""); pos = offset; }

DEDENT
  = { indent = indentStack.pop(); }

