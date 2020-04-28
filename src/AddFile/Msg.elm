module AddFile.Msg exposing (Msg(..))

import File exposing (File)


type Msg
    = SetVisible Bool
    | ChangeIpfsHash String
    | DownloadIpfs
    | FileRequested
    | FileProvided File
