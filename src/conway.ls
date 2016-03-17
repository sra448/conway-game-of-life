Rx = require \rx
ReactDOM = require \react-dom
{filter} = require \prelude-ls

ui = require \./conway-ui.ls
{Coordinate, tick, coordinates-in-list, coordinates-equals} = require \./conway-logic.ls

mouse-coords-to-tile-coords = (x, y) ->
  Coordinate (Math.floor x / 20), (Math.floor y / 20)

# catch user interaction

clicks = Rx.Observable.fromEvent document.body, "click"
mouse-down = Rx.Observable.fromEvent document.body, \mousedown
mouse-move = Rx.Observable.fromEvent document.body, \mousemove
mouse-up = Rx.Observable.fromEvent document.body, \mouseup

toggles = clicks
  .filter -> !it.target.id
  .map (e) -> [\toggle, (mouse-coords-to-tile-coords e.page-x, e.page-y)]

draws = mouse-down
  .flat-map ->
    mouse-move
      .map (e) -> mouse-coords-to-tile-coords e.page-x, e.page-y
      .distinct-until-changed!
      .map (coords) -> [\draw, coords]
      .take-until mouse-up

pauser = new Rx.Subject

play = mouse-down
  .filter -> it.target.id == \play
  .subscribe ->
    pauser.onNext true

pause = mouse-down
  .filter -> it.target.id == \pause
  .subscribe ->
    pauser.onNext false

timer = Rx.Observable
  .interval 500
  .pausable pauser
  .map -> [\tick]

ticks = mouse-down
  .filter -> it.target.id == \tick
  .map -> [\tick]

# world manipulation

activate-cell = (list, coord) ->
  if coordinates-in-list list, coord
    list
  else
    list ++ [coord]

toggle-cell = (list, coord) ->
  if coordinates-in-list list, coord
    list |> filter -> !coordinates-equals coord, it
  else
    list ++ [coord]

update-world = (state, [action, value]) ->
  switch action
    case \toggle then toggle-cell state, value
    case \draw then activate-cell state, value
    case \tick then tick state
    default state

# kickoff

Rx.Observable.merge [timer, ticks, draws]
  .start-with [\tick]
  .scan update-world, []
  .subscribe (living-cells) ->
    ReactDOM.render (ui {living-cells}), document.get-element-by-id "conway"
