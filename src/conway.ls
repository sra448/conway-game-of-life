Rx = require \rx
ReactDOM = require \react-dom

{tick} = require \./conway-logic.ls
ui = require \./conway-ui.ls

HTML_CONTAINER = document.get-element-by-id "conway"
GLIDER_SEED = [[0 1], [1 2], [2 0], [2 1], [2 2]]

clicks = Rx.Observable.fromEvent HTML_CONTAINER, "click"

toggles = clicks
  .filter -> /^\[/.test it.target.id
  .map -> JSON.parse it.target.id

# make a pausable timer

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

# take care of ticks

ticks = clicks
  .filter -> it.target.id == \tick

Rx.Observable.merge [timer, ticks]
  .scan tick, GLIDER_SEED
  .subscribe (living-cells) ->
    ReactDOM.render (ui {living-cells}), HTML_CONTAINER

ReactDOM.render (ui {}), HTML_CONTAINER
