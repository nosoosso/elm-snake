import Const

type alias Model =
  { board : Board
  }

type alias Board = List BoardRow

type alias BoardRow = List BoardItem

type BoardItem = Snake Int | Item | None

initBoard : Board 
initBoard = 
  [ [ None, None ]
  , [ None, None ]
  ]
