module Game exposing (init, update, subscriptions, Model, Scene(..), ModelPlaying, Board, BoardRow, Cell(..))

import Array exposing (Array)
import Keyboard
import Random
import Task exposing (..)
import Time
import Const
import Utils.ArrayUtils as ArrayUtils
import Utils.MaybeUtils as MaybeUtils


init : ( Model, Cmd Msg )
init =
    ( initModel, initPage )


type alias Model =
    { scene : Scene
    , playing : ModelPlaying
    , board : Board
    , score : Int
    , time : Int
    , randomSeed : Maybe Random.Seed
    }


type Scene
    = Title
    | Playing
    | Dead


type alias ModelPlaying =
    { initialized : Bool
    , snakeHead : SnakeHead
    }


type alias SnakeHead =
    { x : Int
    , y : Int
    , length : Int
    , direction : Direction
    }


type Direction
    = Top
    | Right
    | Bottom
    | Left


type alias Board =
    Array BoardRow


type alias BoardRow =
    Array Cell


type Cell
    = Snake Int
    | Item
    | Empty


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
        }
    , board = initBoard
    , score = 0
    , time = 0
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
                    }
                , board = initializedBoard
                , score = 0
                , time = 0
            }

        setItemModel =
            putItem newModel
    in
        setItemModel


initSnakeHead : SnakeHead
initSnakeHead =
    { x = Const.boardSizeX // 3
    , y = Const.boardSizeY // 2
    , length = 1
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


mapCell : (Cell -> Cell) -> Board -> Board
mapCell f old =
    Array.map (\row -> Array.map f row) old


decrementSnakeLength : Cell -> Cell
decrementSnakeLength cell =
    case cell of
        Snake len ->
            let
                newLength =
                    len - 1
            in
                if newLength > 0 then
                    Snake newLength
                else
                    Empty

        Item ->
            Item

        Empty ->
            Empty


mayGetItem : Model -> Model
mayGetItem model =
    let
        { x, y } =
            model.playing.snakeHead

        cellOnHead =
            getCell x y model.board

        newModel =
            case cellOnHead of
                Item ->
                    let
                        newBoard =
                            setCell x y Empty model.board

                        oldPlaying =
                            model.playing

                        oldSnakeHead =
                            oldPlaying.snakeHead

                        newSnakeHead =
                            { oldSnakeHead | length = oldSnakeHead.length + 1 }

                        newPlaying =
                            { oldPlaying | snakeHead = newSnakeHead }

                        newModel =
                            { model
                                | board = newBoard
                                , score = model.score + Const.itemScore
                                , playing = newPlaying
                            }

                        itemPutted =
                            putItem newModel
                    in
                        itemPutted

                _ ->
                    model
    in
        newModel


moveHead : Model -> Model
moveHead model =
    let
        { snakeHead } =
            model.playing

        newSnakeHead =
            case snakeHead.direction of
                Top ->
                    { snakeHead | y = snakeHead.y - 1 }

                Right ->
                    { snakeHead | x = snakeHead.x + 1 }

                Bottom ->
                    { snakeHead | y = snakeHead.y + 1 }

                Left ->
                    { snakeHead | x = snakeHead.x - 1 }

        oldPlaying =
            model.playing

        newPlaying =
            { oldPlaying | snakeHead = newSnakeHead }
    in
        { model | playing = newPlaying }


nextFrame : Model -> Model
nextFrame model =
    let
        { x, y } =
            model.playing.snakeHead

        decremented =
            { model | board = mapCell decrementSnakeLength model.board }

        itemChecked =
            mayGetItem decremented

        snakeHeadPutted =
            { itemChecked
                | board = setCell x y (Snake itemChecked.playing.snakeHead.length) itemChecked.board
            }

        snakeHeadMoved =
            moveHead snakeHeadPutted
    in
        { snakeHeadMoved | time = model.time + 1 }


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
        { snakeHead } =
            model.playing

        oldPlaying =
            model.playing

        newSnakeHead =
            case keyCode of
                38 ->
                    if snakeHead.direction /= Bottom then
                        { snakeHead | direction = Top }
                    else
                        snakeHead

                39 ->
                    if snakeHead.direction /= Left then
                        { snakeHead | direction = Right }
                    else
                        snakeHead

                40 ->
                    if snakeHead.direction /= Top then
                        { snakeHead | direction = Bottom }
                    else
                        snakeHead

                37 ->
                    if snakeHead.direction /= Right then
                        { snakeHead | direction = Left }
                    else
                        snakeHead

                _ ->
                    snakeHead

        newModelPlaying =
            { oldPlaying
                | snakeHead = newSnakeHead
            }
    in
        ( { model | playing = newModelPlaying }, Cmd.none )
