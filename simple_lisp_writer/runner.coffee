PEG = require 'pegjs'
fs = require 'fs'

parser = PEG.buildParser fs.readFileSync('lispy.pegjs').toString()
rewrite = (node) ->
  switch node.type
    when 'list'
      head = rewrite node.value[0]
      array = rewrite (type:'array', value: node.value[1..])

      args = []
      for exp in array
        if exp instanceof Array
          args.push "[#{exp.join(',')}]"
        else
          args.push exp

      """
      #{head}(#{args.join(',')})
      """
    when 'array'
      data =
        for i in node.value
          rewrite(i.value)
      data

    when 'atom' then rewrite node.value
    when 'boolean' then node.value
    when 'integer' then node.value
    when 'identifier' then node.value
    else
      throw 'parse error'+ node.toString()


parsed = parser.parse """
(console.log 3)
"""

rewrited = rewrite parsed
console.log "===== rewriterd ======="
console.log rewrited
console.log "===== exec      ======="
eval rewrited
