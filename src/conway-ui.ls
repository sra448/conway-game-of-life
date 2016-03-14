React = require \react
{div, h1, a, table, tr, td} = React.DOM

{coordinates-in-list} = require "./conway-logic.ls"

ui = ({living-cells = []}) ->
  div {},
    for [x, y] in living-cells
      div {key:"cell-#x-#y", class-name:\cell, style:top:y*20, left:x*20}

    div {class-name:\controls},
      h1 {}, "Conway's Game of Life"

      div {id:\play}, \play
      div {id:\pause}, \pause
      div {id:\tick}, \tick

module.exports = ui
