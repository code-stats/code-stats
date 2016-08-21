module Profile.Common.Types exposing (..)

type alias Progress =
  { xp : Int
  , new_xp : Int
  }

type alias NamedProgress =
  { xp : Int
  , new_xp : Int
  , name : String
  }

type alias LanguageProgress = NamedProgress
type alias MachineProgress = NamedProgress

type alias XPDataRow =
  { amount : Int
  , language : String
  , machine : String
  }

type alias XPData =
  { xps : List XPDataRow
  }

type alias InitData =
  { total : { xp : Int, new_xp : Int }
  , languages: List LanguageProgress
  , machines: List MachineProgress
  }

-- Input messages from JS
type Msg
  = Init InitData
  | NewXP XPData
