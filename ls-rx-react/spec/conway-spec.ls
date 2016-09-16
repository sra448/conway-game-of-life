fold = require \prelude-ls

that-it = it

conway = require "../src/conway-logic.ls"
c = conway.Coordinate

describe "conway-logic", ->

  that-it "is defined", ->
    expect conway
      .to-be-defined!


  describe "Coordinate", ->
    that-it "acts as a constructor for coordinate arrays, that can be compared by identity", ->
      expect conway.Coordinate 1, 2
        .not.to-be [1, 2]
      expect [1, 2]
        .not.to-be [1, 2]
      expect conway.Coordinate 1, 2
        .to-be conway.Coordinate 1, 2


  describe "read", ->

    # turns a string representation of a 2d grid into an array of living cells' positions

    that-it "living cells (X) end up in results array", ->
      expect (conway.read "X").length
        .to-equal 1

    that-it "dead cells (non-X) don't end up in results array", ->
      ["-", " ", "0", "o", "x"].for-each (str) ->
        expect (conway.read str).length
          .to-equal 0

    that-it "many cells can be in a row", ->
      [["XX" 2], ["--" 0], ["X-" 1], ["-X" 1], ["X-X" 2], ["-X-" 1]].for-each ([str, count]) ->
        expect (conway.read str).length
          .to-equal count

    that-it "many rows (seperated by \\n) make up the grid", ->
      [["XX\nXX" 4], ["--\n--" 0], ["X-\n--" 1], ["-X\n--" 1], ["X-X\n-X-" 3], ["-X-\nX-X" 3]].for-each ([str, count]) ->
        expect (conway.read str).length
          .to-equal count

    that-it "living cells turn into positions with fix-point in the top-left corner", ->
      [["X" [0, 0]] ["-X" [0, 1]] ["--\nX-" [1, 0]] ["--\n-X" [1, 1]]].for-each ([str, coords]) ->
        expect conway.read str
          .to-equal [coords]


  describe "print", ->

    that-it "turns a single cell (any positions) into an X", ->
      [(c 0, 0), (c 0, 1), (c 1, 0), (c 12, 4), (c 4, 12)].for-each (coords) ->
        expect conway.print [coords]
          .to-equal "X"

    that-it "turns a dead cells between living cells into a -", ->
      [[[(c 0, 0), (c 0, 2)], "X-X"]].for-each ([coords, str]) ->
        expect conway.print coords
          .to-equal str

    that-it "returns rows delimited by \\n", ->
      [[[(c -1, 1), (c 1, 1)], "X\n-\nX"]].for-each ([coords, str]) ->
        expect conway.print coords
          .to-equal str

    that-it "returns a string that represents a grid that spans from top-left cell to bottom-right cell", ->
      [[[(c 0, 0), (c 0, 2)], "X-X"], [[(c 0, 0), (c 1, 2)], "X--\n--X"]].for-each ([coords, str]) ->
        expect conway.print coords
          .to-equal str


  describe "boundaries", ->

    that-it "returns the top-left and bottom-right positions given an array of positions", ->
      expect conway.boundaries [[0 0] [3 3] [2 1]]
        .to-equal [[0 0], [3 3]]

    that-it "works for single cells as well", ->
      [[0 0], [1 0], [9 9], [-1 -10]].for-each (coords) ->
        expect conway.boundaries [coords]
          .to-equal [coords, coords]


  describe "positions-between", ->

    that-it "returns a list of all positions between two boundaries", ->
      expect conway.positions-between [[0 0], [2 2]]
        .to-equal [[0 0], [0 1], [0 2], [1 0], [1 1], [1 2], [2 0], [2 1], [2 2]]


  describe "neighbour-positions", ->

    that-it "returns a list of all the neighbouring positions given some positions", ->
      expect conway.neighbour-positions 1, 1
        .to-equal [[0 0], [0 1], [0 2], [1 0], [1 2], [2 0], [2 1], [2 2]]


  describe "expand-positions", ->

    that-it "returns a list of all positions in the given array and all their neighbours", ->
      expect conway.expand-positions [(c 1 1)]
        .to-equal [(c 1 1),
                   (c 0 0), (c 0 1), (c 0 2), (c 1 0), (c 1 2), (c 2 0), (c 2 1), (c 2 2)]
      expect conway.expand-positions [(c 1 1), (c 3 3)]
        .to-equal [(c 1 1), (c 3 3),
                   (c 0 0), (c 0 1), (c 0 2), (c 1 0), (c 1 2), (c 2 0), (c 2 1), (c 2 2),
                   (c 2 3), (c 2 4), (c 3 2), (c 3 4), (c 4 2), (c 4 3), (c 4 4)]

    that-it "returned list only contains each positions once", ->
      expect conway.expand-positions [(c 1 1), (c 2 2)]
        .to-equal [(c 1 1), (c 2 2),
                   (c 0 0), (c 0 1), (c 0 2), (c 1 0), (c 1 2), (c 2 0), (c 2 1),
                   (c 1 3), (c 2 3), (c 3 1), (c 3 2), (c 3 3)]


  describe "count-living-neighbours", ->

    that-it "returns the number of neighbours that are present in the list of living-cells passed in", ->
      expect conway.count-living-neighbours [(c 0 0)], (c 1 1)
        .to-equal 1


  describe "will-cell-live", ->

    that-it "makes any living cell with fewer than two live neighbours die, as if caused by under-population", ->
      [0, 1].for-each (count) ->
        expect conway.will-cell-live true, count
          .to-be false

    that-it "makes any living cell with two or three live neighbours live on to the next generation", ->
      [2, 3].for-each (count) ->
        expect conway.will-cell-live true, count
          .to-be true

    that-it "makes any living cell with more than three live neighbours die, as if by over-population", ->
      [4, 5, 6, 7, 8].for-each (count) ->
        expect conway.will-cell-live true, count
          .to-be false

    that-it "makes any dead cell with exactly three live neighbours becomes alive cell, as if by reproduction", ->
      expect conway.will-cell-live false, 3
        .to-be true

    that-it "makes any other dead cell remain dead", ->
      [0, 1, 2, 4, 5, 6, 7, 8].for-each (count) ->
        expect conway.will-cell-live false, count
          .to-be false


  describe "tick", ->

    that-it "makes all cells in a grid evolve based on the rules of will-cell-live", ->
      [["XXX", "X\nX\nX"]].for-each ([current-grid, future-grid]) ->
        expect conway.print conway.tick conway.read current-grid
          .to-equal future-grid

    that-it "evolves an empty grid into another empty grid", ->
      expect conway.tick []
        .to-equal []

    that-it "makes a lone glider glide forever", ->
      g1 = "-X-\n
            --X\n
            XXX"
      g2 = "X-X\n
            -XX\n
            -X-"
      g3 = "--X\n
            X-X\n
            -XX"
      g4 = "X--\n
            -XX\n
            XX-"

      [[g1, g2], [g2, g3], [g3, g4], [g4, g1]].for-each ([current-grid, future-grid]) ->
        expect conway.print conway.tick conway.read current-grid
          .to-equal future-grid
