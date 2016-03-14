React = require \react
{div, h1, a, table, tr, td} = React.DOM

{coordinates-in-list} = require "./conway-logic.ls"

cell-style = do
  width: 25
  height: 25
  border: 'solid 1px #bada55'

ui = ({living-cells = []}) ->
  div {},
    h1 {}, "Conway Game of Life"

    div {id:\play}, \play
    div {id:\pause}, \pause
    div {id:\tick}, \tick

    table {style:border-collapse:\collapse},
      for x to 20
        tr {},
          for y to 20
            td {id:"[#x, #y]", style:cell-style},
              if coordinates-in-list living-cells, [x, y] then \X

module.exports = ui
