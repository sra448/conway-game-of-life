Rx = require \rx
ReactDOM = require \react-dom
{filter} = require \prelude-ls

{tick, coordinates-in-list, coordinates-equals} = require \./conway-logic.ls
ui = require \./conway-ui.ls

HTML_CONTAINER = document.get-element-by-id "conway"
GLIDER_SEED = [[0 1], [1 2], [2 0], [2 1], [2 2]]

clicks = Rx.Observable.fromEvent document.body, "click"

toggles = clicks
  .filter -> !it.target.id
  .map (e) ->
    [\toggle, [(Math.floor e.page-x / 20), (Math.floor e.page-y / 20)]]

pauser = new Rx.Subject

play = clicks
  .filter -> it.target.id == \play
  .subscribe ->
    pauser.onNext true

pause = clicks
  .filter -> it.target.id == \pause
  .subscribe ->
    pauser.onNext false

timer = Rx.Observable
  .interval 400
  .pausable pauser
  .map -> [\tick]

# take care of ticks

ticks = clicks
  .filter -> it.target.id == \tick
  .map -> [\tick]

toggle-cell = (list, coord) ->
  if coordinates-in-list list, coord
    list |> filter -> !coordinates-equals coord, it
  else
    list ++ [coord]

update-world = (state, [action, value]) ->
  switch action
    case \toggle then toggle-cell state, value
    case \tick then tick state
    default state

Rx.Observable.merge [timer, ticks, toggles]
  .scan update-world, []
  .subscribe (living-cells) ->
    ReactDOM.render (ui {living-cells}), HTML_CONTAINER

ReactDOM.render (ui {}), HTML_CONTAINER
