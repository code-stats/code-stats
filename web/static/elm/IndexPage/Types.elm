module IndexPage.Types exposing (..)

type alias Progress =
  { xp : Int
  , new_xp : Int
  }

type alias Language =
  { xp : Int
  , new_xp : Int
  , name : String
  }

-- Type sent by backend when initting
type alias InitLanguage =
  { xp : Int
  , name : String
  }

type alias TickerDataRow =
  { xp : Int
  , language : String
  , username : String
  }

type alias InitData =
  { total_xp : Int
  , languages : List InitLanguage
  }

-- Input messages from JS
type Msg
  = Init InitData
  | NewXP TickerDataRow

type alias Model =
  { total : Progress
  , languages : List Language
  , tickerdata : List TickerDataRow
  }
