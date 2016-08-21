port module Profile.MainUpdater.Ports exposing (..)

import Profile.Common.Types exposing (..)

port mu_initialize : (InitData -> msg) -> Sub msg

port mu_new_xp : (XPData -> msg) -> Sub msg
