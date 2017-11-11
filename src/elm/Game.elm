module Game exposing (init, update, subscriptions, Model, Scene(..), ModelPlaying, Board, BoardRow, Cell(..))

import Array exposing (Array)
import Keyboard
import Random
import Task exposing (..)
import Time
import Const


init : ( Model, Cmd Msg )
init =
    ( initModel, initPage )


type alias Model =
    { scene : Scene
    , playing : ModelPlaying
    , board : Board
    , randomSeed : Maybe Random.Seed
    }


type Scene
    = Title
    | Playing
    | Dead


type alias ModelPlaying =
    { initialized : Bool
    , snakeHead : SnakeHead
    , time : Int
    , lastDownedKey : Maybe Keyboard.KeyCode
    }


type Msg
    = InitPage
    | InitGame
    | SetRandomSeed Random.Seed
    | Tick Time.Time
    | KeyDown Keyboard.KeyCode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitPage ->
            ( model, initPage )

        InitGame ->
            ( initGame model, Cmd.none )

        SetRandomSeed seed ->
            ( { model | randomSeed = Just seed }, Cmd.none )

        Tick newTime ->
            let
                newModel =
                    updateTime model
            in
                ( newModel, Cmd.none )

        KeyDown keyCode ->
            handleKeyDown keyCode model


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        commonSub =
            [ Keyboard.downs KeyDown ]
    in
        Sub.batch <|
            (case model.scene of
                Playing ->
                    (Time.every (Const.gameSpeed * Time.millisecond) Tick) :: commonSub

                otherwise ->
                    commonSub
            )


initModel : Model
initModel =
    { scene = Title
    , playing =
        { initialized = False
        , snakeHead = initSnakeHead
        , time = 0
        , lastDownedKey = Nothing
        }
    , board = initBoard
    , randomSeed = Nothing
    }


initPage : Cmd Msg
initPage =
    let
        setRandomSeedCmd =
            Time.now
                |> andThen
                    (\time ->
                        round time
                            |> Random.initialSeed
                            |> succeed
                    )
                |> Task.perform SetRandomSeed
    in
        setRandomSeedCmd


initGame : Model -> Model
initGame model =
    { model
        | scene = Playing
        , playing =
            { initialized = True
            , snakeHead = initSnakeHead
            , time = 0
            , lastDownedKey = Nothing
            }
    }


type alias Board =
    Array BoardRow


type alias BoardRow =
    Array Cell


type Cell
    = Snake Int
    | Item
    | Empty


type alias SnakeHead =
    { x : Int
    , y : Int
    }


initSnakeHead : SnakeHead
initSnakeHead =
    { x = Const.boardSizeX // 3
    , y = Const.boardSizeY // 2
    }


initBoard : Board
initBoard =
    Array.repeat Const.boardSizeY (Array.repeat Const.boardSizeX Empty)


putItem : Board -> Board
putItem board =
    let
        emptyCells =
            collectEmptyCell board
    in
        board


collectEmptyCell : Board -> Array ( Int, Int, Cell )
collectEmptyCell board =
    toIndexedCellArray board
        |> filterNotEmptyCell


toIndexedCellArray : Board -> Array ( Int, Int, Cell )
toIndexedCellArray board =
    Array.indexedMap
        (\yIndex boardRow ->
            Array.indexedMap (\xIndex cell -> ( xIndex, yIndex, cell )) boardRow
        )
        board
        -- flatten array
        |> Array.foldr (Array.append) Array.empty


filterNotEmptyCell : Array ( Int, Int, Cell ) -> Array ( Int, Int, Cell )
filterNotEmptyCell =
    Array.filter (\( x, y, cell ) -> cell |> isEmptyCell)


isEmptyCell : Cell -> Bool
isEmptyCell cell =
    case cell of
        Snake a ->
            False

        Item ->
            False

        Empty ->
            True


getCell : Int -> Int -> Board -> Cell
getCell x y board =
    case Array.get y board of
        Just row ->
            case Array.get x row of
                Just something ->
                    something

                Nothing ->
                    Debug.crash "invalid x index"

        Nothing ->
            Debug.crash "invalid y index"


setCell : Int -> Int -> Cell -> Board -> Board
setCell x y cell board =
    let
        currentBoardRow =
            Array.get y board

        newBoardRow =
            case currentBoardRow of
                Just row ->
                    Array.set x cell row

                Nothing ->
                    Debug.crash "invalid x index"
    in
        Array.set y newBoardRow board


updateTime : Model -> Model
updateTime model =
    let
        oldModelPlaying =
            model.playing

        newModelPlaying =
            { oldModelPlaying
                | time = oldModelPlaying.time + 1
            }
    in
        { model | playing = newModelPlaying }


handleKeyDown : Keyboard.KeyCode -> Model -> ( Model, Cmd Msg )
handleKeyDown keyCode model =
    case model.scene of
        Title ->
            handleTitleKeyDown keyCode model

        Playing ->
            handlePlayingKeyDown keyCode model

        Dead ->
            -- TODO
            ( model, Cmd.none )


handleTitleKeyDown : Keyboard.KeyCode -> Model -> ( Model, Cmd Msg )
handleTitleKeyDown keyCode model =
    case keyCode of
        32 ->
            ( model, perform (\_ -> InitGame) (succeed ()) )

        otherwise ->
            ( model, Cmd.none )


handlePlayingKeyDown : Keyboard.KeyCode -> Model -> ( Model, Cmd Msg )
handlePlayingKeyDown keyCode model =
    let
        oldModelPlaying =
            model.playing

        newModelPlaying =
            { oldModelPlaying
                | lastDownedKey = Just keyCode
            }
    in
        ( { model | playing = newModelPlaying }, Cmd.none )
