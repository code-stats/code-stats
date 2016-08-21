port module Profile.TotalUpdater.Ports exposing (..)

import Profile.Common.Types exposing (..)

port tu_initialize : (InitData -> msg) -> Sub msg

port tu_new_xp : (XPData -> msg) -> Sub msg
