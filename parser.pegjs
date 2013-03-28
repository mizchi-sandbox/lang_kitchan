{
  var indentStack = [], indent = "";
  var line = 1;
}

start
  = h:header EOL+ ll:lines {
      return {header: h, lines: ll}
    }

header
  = people

people
  = "@people" people_list

people_list
  = pp:(_ p:name {return p;})+ {
    return {people: pp}
  }

name
  = name:[a-zA-Z]+ {
    return name.join("");
  }

lines
  = ll:line* {
    return ll;
  }

line
  = SAMEDENT t:transaction EOL* {
    return t;
  }
  / SAMEDENT block_header EOL INDENT ll:lines OUTDENT {
    return {block: true, lines: ll}
  }
  / comment EOL+

block_header
  = command _? ("," _? command)*

command
  = group_command
  / date_command
  / tag_command
  / currency_command

group_command
  = "@group" pl:people_list

date_command
  = "@date" _ d:date

tag_command
  = "@tag" tl:tag_list

tag_list
  = (_ tag)+

currency_command
  = "@currency" _ n:number

transaction
  = date:(d:date _ {return d;})? desc:(d:description ":" _? { return d; })? p:payers bs:(" -> " b:beneficiaries opt:(_ o:option {return o;})?{return [b,opt]})? {
      return {
          date   : date,
          desc   : desc,
          payers : p,
          beneficiaries : bs[0],
          options : bs[1],  
          
      }
  }

date
  = year:([0-9][0-9][0-9][0-9])"-"month:([0-9][0-9])"-"day:([0-9][0-9]) {
      return new Date(year.join(""), month.join(""), day.join(""));
  }

description
  = w:(word / tag) others:(_ w_n:(word / tag) { return w_n; } )* {
      var desc = w;
      if(others.length > 0) {
          desc = w + " " + others.join(" ");
      }
      return desc;
  } 

word
  = word:[a-zA-Z-_'0-9"]+ { return word.join(""); }

tag
  = t:("#" word) { return t.join(""); }

payers
  = p:payer others:(_ p_n:payer { return p_n; })* {
      return [p].concat(others);
    }

payer
  = n:name _ e:expr { return {name : n, payed: e}; }

beneficiaries
  = b:beneficiary others:(_ b_n:beneficiary { return b_n; })* {
        return [b].concat(others);
    }
  / "" { return []; }

beneficiary
  =  n:name _ m:modifier a:expr {
        return {
               name : n,
               amount : a,
               modifier : m
        };
    } /
    n:name _ a:expr {
        return {
               name : n,
               amount : a,
        };
    } /
    n:name {
        return {
            name : n
        };
    }

modifier
  = "+" / "-" / "*"

option
  = "..." { return "group"; }
  / "$"+ { return "split"; }

expr
  = res:sum { return res; }

sum
  = t:term others:(t_n:(("+"/"-") term) { return parseFloat(t_n.join("")); })* {
      var sum = t;
      var length = others.length;
      for (var i = 0; i < length; i++) {
          sum += others[i];
      }
      return sum;
    }



term
  = f:factor others:("*" f_n:factor { return f_n; })* {
        var prod = f;
        var length = others.length;
        if (length > 0) {
            for (var i = 0; i < length; i++) {
                prod *= others[i];
            }
        }
        return prod;
    }

factor 
  = number /
          "(" e:expr ")" { return e; }

float
  = n:((integer)? "." integer) { return parseFloat(n.join("")); }

integer
  = n:[0-9]+ { return parseInt(n.join("")); }

number
  = float / integer 

_ = whitespace+

whitespace
  = " " / "\t"

EOL
  = "\r\n" / "\n" / "\r" {
    line++;
  }

NOT_EOL
  = EOL &{ return false }
  / . { return true }

comment
  = "//" NOT_EOL* {
    return "line comment";
  }
  / "/*" [^*/]* "*/" {
    return "comment";
  }

SAMEDENT
  = i:[ \t]* &{ return i.join("") === indent; }

INDENT
  = i:[ \t]+ &{ return i.length > indent.length; }
    { indentStack.push(indent); indent = i.join(""); pos = offset; }

OUTDENT
  = { indent = indentStack.pop(); }
