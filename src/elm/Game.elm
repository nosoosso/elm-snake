module Game exposing (init, update, subscriptions, Model, Scene(..), ModelPlaying, Board, BoardRow, Cell(..))

import Array exposing (Array)
import Keyboard
import Random
import Task exposing (..)
import Time
import ArrayUtils
import Const
import MaybeUtils


init : ( Model, Cmd Msg )
init =
    ( initModel, initPage )


type alias Model =
    { scene : Scene
    , playing : ModelPlaying
    , board : Board
    , score : Int
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
    , direction : Direction
    }

type Direction = Top | Right | Bottom | Left

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
                    nextFrame model
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
    , score = 0
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
    let
        initializedBoard =
            initBoard

        newModel =
            { model
                | scene = Playing
                , playing =
                    { initialized = True
                    , snakeHead = initSnakeHead
                    , time = 0
                    , lastDownedKey = Nothing
                    }
                , board = initializedBoard
                , score = 0
            }

        setItemModel =
            putItem newModel
    in
        setItemModel


initSnakeHead : SnakeHead
initSnakeHead =
    { x = Const.boardSizeX // 3
    , y = Const.boardSizeY // 2
    , direction = Right
    }


initBoard : Board
initBoard =
    Array.repeat Const.boardSizeY (Array.repeat Const.boardSizeX Empty)


putItem : Model -> Model
putItem model =
    let
        emptyCells =
            collectEmptyCell model.board

        seed =
            MaybeUtils.getOrCrash "random seed has not been initialized" model.randomSeed

        ( selectedCellIndex, newSeed ) =
            Random.step (Random.int 0 (Array.length emptyCells - 1)) seed

        selectedCell =
            ArrayUtils.getOrCrash "something wrong" selectedCellIndex emptyCells


        ( x, y, _ ) =
            selectedCell

        newBoard =
            setCell x y Item model.board

    in
        { model | board = newBoard, randomSeed = Just newSeed }


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


nextFrame : Model -> Model
nextFrame model =
    let
        oldModelPlaying =
            model.playing

        newModelPlaying =
            { oldModelPlaying
                | time = oldModelPlaying.time + 1
            }

        newTimeModel =
            { model | playing = newModelPlaying }
    in
        newTimeModel


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
            ( model, Task.perform identity (succeed InitGame) )

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
