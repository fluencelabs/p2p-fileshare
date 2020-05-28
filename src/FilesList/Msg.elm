module FilesList.Msg exposing (Msg(..))

{-|
  Copyright 2020 Fluence Labs Limited

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-}

type Msg
    = NoOp
    | FileUploading String
    | FileUploaded String
    | FileDownloading String
    | FileAdvertised String (Maybe String)
    | FileLog String String
    | FileAsked String
    | ResetEntries
    | FileRequested String
    | FileLoaded String (Maybe String)
    | DownloadFile String
    | Copy String
    | Copied String
    | ReplaceCopyMessage String
    | SetLogsVisible String Bool
