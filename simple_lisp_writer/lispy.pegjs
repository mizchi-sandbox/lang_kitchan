{
    function Node(type, value){
        this.type = type;
        this.value = value;
    }
}

program
  = list
  / atom

// splitter
whitespace = [ \t\n\r]
__ = whitespace+
_ = whitespace*

// syntax
cell
  = _ list:list _{ return new Node('atom', list) }
  / _ atom:atom _{ return new Node('atom', atom) }
  / _ array:array _ {return new Node('atom', array)}

list = "(" cells:cell+ ")" {
    return new Node('list', cells);
  }

array = "[" cells:cell* "]" {
    return cells;
  }

atom
  = identifier:$(identifier) { return new Node("identifier", identifier)}
  / operator:operator {return new Node('operator' , operator)}
  / value:$(boolean) {return new Node('boolean', value)}
  / value:$(integer) {return new Node('integer', value)}
  / value:$(string)  {return new Node('string' , value)}
  / value:array {return new Node("array", value)}


identifier = [a-zA-Z] [a-zA-Z0-9\.]*
boolean = "true" / "false"
integer = [1-9] [0-9]*
string = "\"" ("\\" ./  [^"])* "\""
operator = $("+"/ "-"/ "/" / "*")
