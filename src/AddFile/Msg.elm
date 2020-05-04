module AddFile.Msg exposing (Msg(..))

import Bytes exposing (Bytes)
import File exposing (File)


type Msg
    = SetVisible Bool
    | ChangeIpfsHash String
    | DownloadIpfs
    | FileRequested
    | FileProvided File
    | FileBytesRead File Bytes
    | FileHashReceived String
    | FileReady (Maybe String) Bytes String
