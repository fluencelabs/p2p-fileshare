module AddFile.Msg exposing (Msg(..))

type Msg
    = SetVisible Bool
    | ChangeIpfsHash String
    | DownloadIpfs
    | FileRequested
