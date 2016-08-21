module Profile.MainUpdater.Types exposing (..)

import Profile.Common.Types exposing (..)

type alias Model =
  { languages : List LanguageProgress
  , machines : List MachineProgress
  }
