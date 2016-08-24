port module IndexPage.Ports exposing (..)

-- Work around an Elm compiler bug that reordered the code the wrong way,
-- putting our port code before Elm JSON decoder code.
-- This forces the JSON decoder code to be before our code.
import Json.Decode exposing (..)

import IndexPage.Types exposing (..)

port iu_initialize : (InitData -> msg) -> Sub msg

port iu_new_xp : (TickerDataRow -> msg) -> Sub msg
