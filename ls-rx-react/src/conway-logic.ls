{at, apply, concat-map, sort-by, filter, map, split, zip, minimum, maximum, group-by, values, join, unique, Func} = require \prelude-ls
{memoize} = Func

# acts as a factory for coordinate arrays, that can be compared by identity
Coordinate = c = memoize Array

# turns string into list of living cells positions
read = (str) ->
  str
    |> split "\n"
    |> zip [0 to it.length]
    |> concat-map ([x, row]) ->
      zip [[x, y] for y to row.length], row
    |> filter (at 1) >> (== \X)
    |> map (at 0) >> apply Coordinate

# gets top-left and bottom-right positions of a list of positions
boundaries = (living-cells) ->
  xses = map (at 0), living-cells
  yses = map (at 1), living-cells
  [[(minimum xses), (minimum yses)] [(maximum xses), (maximum yses)]]

# positions-between gets all positions between two boundaries
positions-between = ([[x-min, y-min], [x-max,  y-max]]) ->
  [c x, y for x in [x-min to x-max] for y in [y-min to y-max]]

# turns positions into a 2d grid string representation
area = do
  boundaries
  >> positions-between
  >> (group-by at 0)
  >> values
  >> (sort-by (([[x]]) -> x))

print-cell = (living-cells, position) -->
  if position in living-cells then \X else \-

print = (living-cells) ->
  living-cells
    |> area
    |> map (map print-cell living-cells) >> join ""
    |> join "\n"

# returns the neighbouring positions
neighbour-positions = memoize (x, y) ->
  [(c x-1, y-1), (c x-1, y), (c x-1, y+1), (c x, y-1), (c x, y+1), (c x+1, y-1), (c x+1, y), (c x+1, y+1)]

# returns a list of all positions in the given array and all their neighbours
expand-positions = (positions) ->
  positions
    |> concat-map apply neighbour-positions
    |> (++) positions
    |> unique

# evolves a cell based on the rules of the game of life
will-cell-live = (is-alive, neighbours-count) ->
  is-alive && 1 < neighbours-count < 4 || neighbours-count == 3

# returns the number of living neighbours
count-living-neighbours = (living-cells, position) ->
  position
    |> apply neighbour-positions
    |> filter (in living-cells)
    |> (.length)

# evolves a cell based on the rules of the game of life
will-cell-live-fn = (living-cells, position) -->
  will-cell-live do
    position in living-cells
    count-living-neighbours living-cells, position

# evolves a grid (list of living cells' positions) into the next ticks' grid
tick = (living-cells) ->
  living-cells
    |> expand-positions
    |> filter will-cell-live-fn living-cells

# our main function is tick, all the others are mainly exposed for testing
module.exports = {
  Coordinate
  read
  print
  boundaries
  positions-between
  neighbour-positions
  expand-positions
  count-living-neighbours
  will-cell-live
  tick
}
