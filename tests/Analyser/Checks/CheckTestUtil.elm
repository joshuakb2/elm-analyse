module Analyser.Checks.CheckTestUtil exposing (..)

import Analyser.Checks.Base exposing (Checker)
import Analyser.Configuration exposing (defaultConfiguration)
import Analyser.Messages.Types exposing (Message, MessageData)
import Analyser.Files.Types exposing (..)
import Analyser.Files.FileContent as FileContent exposing (FileContent)
import Elm.Parser
import Test exposing (Test, describe, test)
import Expect
import Elm.Interface as Interface exposing (Interface)
import Elm.RawFile as RawFile
import Elm.Processing as Processing


fileContentFromInput : String -> FileContent
fileContentFromInput input =
    { path = "./foo.elm", ast = Nothing, formatted = True, sha1 = Nothing, content = Just input, success = True }


getMessages : String -> Checker -> Maybe (List MessageData)
getMessages input checker =
    Elm.Parser.parse input
        |> Result.map
            (\rawFile ->
                { interface = Interface.build rawFile
                , moduleName = RawFile.moduleName rawFile
                , ast = Processing.process Processing.init rawFile
                , content = ""
                , path = "./foo.elm"
                , sha1 = ""
                }
            )
        |> Result.toMaybe
        |> Maybe.map (flip checker.check defaultConfiguration >> List.map .data)


build : String -> Checker -> List ( String, String, List MessageData ) -> Test
build suite checker cases =
    describe suite <|
        List.map
            (\( name, input, messages ) ->
                test name (\() -> getMessages input checker |> Expect.equal (Just messages))
            )
            cases
