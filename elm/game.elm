import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (name, style, type')
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2)
import Set exposing (..)
import List exposing (..)
import Mouse exposing (Position)


-- MAIN


main : Program Never
main =
  App.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL


type alias Model =
  { cells : Set Coord
  }


type alias Coord = (Int, Int)


model : Model
model =
  Model Set.empty


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


-- UPDATE


type Msg
  = Tick
  | MouseMsg Position


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Tick ->
      ({ model | cells = tick model.cells }, Cmd.none)

    MouseMsg position ->
      ({ model | cells = toggleCell position model.cells }, Cmd.none)


toggleCell : Position -> Set Coord -> Set Coord
toggleCell position cells =
  let
    cell = ((position.x // 16), (position.y // 16))
  in
    if Set.member cell cells then
      Set.remove cell cells
    else
      Set.insert cell cells



inc : Int -> Int
inc x = x + 1


dec : Int -> Int
dec x = x - 1


id : a -> a
id x = x


neighbours : Coord -> Set Coord
neighbours (x, y) =
  Set.fromList
    [ ((dec x), (dec y))
    , ((dec x), (id y))
    , ((dec x), (inc y))
    , ((id x), (dec y))
    , ((id x), (inc y))
    , ((inc x), (dec y))
    , ((inc x), (id y))
    , ((inc x), (inc y))
    ]


countNeighbours : Coord -> Set Coord -> Int
countNeighbours cell cells =
  Set.size <| Set.intersect (neighbours cell) cells


isCellLiving : Set Coord -> Coord -> Bool
isCellLiving cells cell =
  let
    isAlive = Set.member cell cells
    neighboursCount = countNeighbours cell cells
  in
    isAlive && (1 < neighboursCount && neighboursCount < 4) || (neighboursCount == 3)


expandPosition : Coord -> Set Coord
expandPosition cell =
  Set.insert cell (neighbours cell)


tick : Set Coord -> Set Coord
tick cells =
  cells
    |> Set.foldl (\ c acc -> Set.union acc (expandPosition c)) Set.empty
    |> Set.filter (isCellLiving cells)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.clicks MouseMsg
        ]


-- VIEW


view : Model -> Html Msg
view model =
  div
    [ style
      [ ("height", "100%")
      , ("width", "100%")
      , ("background-color", "white")
      , ("background-image", " linear-gradient(rgba(27, 148, 81, 0.6) 1px, transparent 1px), linear-gradient(90deg, rgba(27, 148, 81, 0.6) 1px, transparent 1px)")
      , ("background-size", "16px 16px")
      , ("background-position", "-1px -1px")
      ]
    ]
    [ a [ onClick Tick ] [ text "tick"]
    , Keyed.ul [] <|
        List.map viewKeyedCell (Set.toList model.cells)
    ]



viewKeyedCell : Coord -> (String, Html Msg)
viewKeyedCell cell =
  ((toString (fst cell)) ++ ":" ++ (toString (snd cell)), lazy viewCell cell )



viewCell : Coord -> Html Msg
viewCell cell =
  div
    [ style
      [ ("position", "absolute")
      , ("top", (toString ((snd cell) * 16)) ++ "px")
      , ("left", (toString ((fst cell) * 16)) ++ "px")
      , ("height", "16px")
      , ("width", "16px")
      , ("background", "rgba(27, 148, 81, 0.4)")
      ]
    ]
    []
