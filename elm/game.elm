import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (name, style, type')
import Html.Events exposing (onClick)
import Html.Keyed as Keyed
import Html.Lazy exposing (lazy, lazy2)
import Set exposing (..)
import List exposing (..)



main =
  App.beginnerProgram { model = model, update = update, view = view }


-- MODEL


type alias Model =
  { cells : Set (PositionX, PositionY)
  }


type alias PositionX = Int
type alias PositionY = Int


model : Model
model =
  Model
    (Set.fromList
      [ (10, 10)
      , (11, 11)
      , (11, 12)
      , (10, 12)
      , (9, 12)
      ])


-- UPDATE


inc : Int -> Int
inc x = x + 1


dec : Int -> Int
dec x = x - 1


id : a -> a
id x = x


--findNeighbours : Position -> Set Position -> Set Position
--findNeighbours cell cells =
-- List.filter (isNeighbour cell) cells


neighbours : (PositionX, PositionY) -> Set (PositionX, PositionY)
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


countNeighbours : (PositionX, PositionY) -> Set (PositionX, PositionY) -> Int
countNeighbours cell cells =
  Set.size <| Set.intersect (neighbours cell) cells


isCellLiving : Set (PositionX, PositionY) -> (PositionX, PositionY) -> Bool
isCellLiving cells cell =
  let
    isAlive = Set.member cell cells
    neighboursCount = countNeighbours cell cells
  in
    isAlive && (1 < neighboursCount && neighboursCount < 4) || (neighboursCount == 3)


expandPosition : (PositionX, PositionY) -> Set (PositionX, PositionY)
expandPosition cell =
  Set.insert cell (neighbours cell)


tick : Set (PositionX, PositionY) -> Set (PositionX, PositionY)
tick cells =
  cells
    |> Set.foldl (\ c acc -> Set.union acc (expandPosition c)) Set.empty
    |> Set.filter (isCellLiving cells)




type Msg
  = Tick


update : Msg -> Model -> Model
update msg model =
  case msg of
    Tick ->
      { model | cells = tick model.cells }


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ a [ onClick Tick ] [ text "tick"]
    , Keyed.ul [] <|
        List.map viewKeyedCell (Set.toList model.cells)
    ]



viewKeyedCell : (PositionX, PositionY) -> (String, Html Msg)
viewKeyedCell cell =
  ((toString (fst cell)) ++ ":" ++ (toString (snd cell)), lazy viewCell cell )



viewCell : (PositionX, PositionY) -> Html Msg
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
