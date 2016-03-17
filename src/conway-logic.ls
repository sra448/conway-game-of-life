Immutable = require \immutable
{at, concat-map, curry, sort-by, filter, flip, find, fold, map, split, zip, minimum, maximum, group-by, values, join, Func} = require \prelude-ls
{memoize} = Func

# log logs a single value, just for debugging
log = ->
  console.log it
  it

# acts as a constructor for coordinate arrays, that can be compared by identity
Coordinate = c = memoize (x, y) ->
  [x, y]

# turns string into list of living cells coordinates
read = (str) ->
  str
    |> split "\n"
    |> zip [0 to it.length]
    |> concat-map ([x, row]) ->
      zip [[x, y] for y to row.length], row
        |> filter ([coord, value]) ->
          value == \X
        |> map ([[x, y]]) -> c x, y

# turns coordinates into a 2d grid string representation
print = (living-cells-coordinates) ->
  living-cells-coordinates
    |> boundaries
    |> coordinates-beetween
    |> map ([x, y]) -> c x, y
    |> group-by (at 0)
    |> values
    |> sort-by ([[x]]) -> x
    |> map map (coord) ->
      if coordinates-in-list living-cells-coordinates, coord then \X else \-
    |> map join ""
    |> join "\n"

# checks coordinate equality
coordinates-equals = curry ([x1, y1], [x2, y2]) ->
  x1 == x2 && y1 == y2

# check if coordinates are in list of coordinates
coordinates-in-list = curry (list, coordinates) ->
  !! find (== coordinates), list

# gets top-left and bottom-right coordinates of a list of coordinates
boundaries = (living-cells-coordinates) ->
  xses = map (at 0), living-cells-coordinates
  yses = map (at 1), living-cells-coordinates
  [[(minimum xses), (minimum yses)] [(maximum xses), (maximum yses)]]

# expands any pair of boundary coordinates by one
expand-boundaries = ([[x-min, y-min], [x-max,  y-max]]) ->
  [[x-min - 1, y-min - 1], [x-max + 1,  y-max + 1]]

# coordinates-beetween gets all coordinates between two boundaries
coordinates-beetween = ([[x-min, y-min], [x-max,  y-max]]) ->
  [[x, y] for x in [x-min to x-max] for y in [y-min to y-max]]

# returns the neighbouring coordinates
neighbour-coordinates = ([x, y]) ->
  [(c x-1, y-1), (c x-1, y), (c x-1, y+1), (c x, y-1), (c x, y+1), (c x+1, y-1), (c x+1, y), (c x+1, y+1)]

# returns a list of all coordinates in the given array and all their neighbours
expand-coordinates = (list-of-coordinates) ->
  list-of-coordinates
    |> concat-map neighbour-coordinates
    |> (++) list-of-coordinates
    |> (flip fold) [], (acc, x) ->
      if coordinates-in-list acc, x then acc else acc ++ [x]

# returns the number of living neighbours
count-living-neighbours = (living-cells-coordinates, coordinates) ->
  coordinates
    |> neighbour-coordinates
    |> filter coordinates-in-list living-cells-coordinates
    |> (.length)

# evolves a cell based on the rules of the game of life
will-cell-live = ({living, number-of-neighbours}) ->
  switch living
    case true then number-of-neighbours in [2, 3]
    case false then number-of-neighbours == 3
    default living

# evolves a grid (list of living cells' coordinates) into the next ticks' grid
tick = (living-cells-coordinates) ->
  living-cells-coordinates
    |> expand-coordinates
    |> filter (coords) ->
      will-cell-live do
        living: coordinates-in-list living-cells-coordinates, coords
        number-of-neighbours: count-living-neighbours living-cells-coordinates, coords

# our main function is tick, all the others are mainly exposed for testing
module.exports = {
  Coordinate
  read
  print
  boundaries
  expand-boundaries
  coordinates-beetween
  coordinates-equals
  coordinates-in-list
  neighbour-coordinates
  expand-coordinates
  count-living-neighbours
  will-cell-live
  tick
}
