module Main exposing (..)

import Browser
import Csv.Decode as CsvDecode
import Dict exposing (Dict)
import Hex
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Svg as S
import Svg.Attributes as SA



---- MODEL ----


type alias Model =
    { features : List Feature
    , display : Maybe String
    , votingData : Dict String ConstituencyVoting
    }


type alias Point =
    { x : Float
    , y : Float
    }


type alias Feature =
    { name : String
    , coordinates : List (List (List Point))
    }


type alias GeoJson =
    { features : List Feature }


type alias Flags =
    { features : List Feature
    , votesCsv : String
    }


type alias ConstituencyVoting =
    { name : String
    , percentage : Int
    }


decoder =
    CsvDecode.map2 ConstituencyVoting
        (CsvDecode.column 0
            (CsvDecode.string
                |> CsvDecode.map
                    (\str ->
                        str
                            |> String.replace " CC" ""
                            |> String.replace " BC" ""
                    )
            )
        )
        (CsvDecode.column 8
            (CsvDecode.string
                |> CsvDecode.andThen
                    (\str ->
                        case String.toInt (String.replace "%" "" str) of
                            Just int ->
                                CsvDecode.succeed int

                            Nothing ->
                                CsvDecode.fail ("Failed to decode int from " ++ str)
                    )
            )
        )


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        votingData =
            CsvDecode.decodeCsv CsvDecode.NoFieldNames decoder flags.votesCsv
                |> Result.withDefault []
                |> List.map (\entry -> ( entry.name, entry ))
                |> Dict.fromList
    in
    ( { features = flags.features, votingData = votingData, display = Nothing }, Cmd.none )



---- UPDATE ----


type Msg
    = Over String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Over name ->
            ( { model | display = Just name }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    let
        pathFrom list =
            "M "
                ++ (List.map (\coord -> String.fromFloat coord.x ++ "," ++ String.fromFloat ((61.0 - coord.y) * 1.65) ++ " ") list
                        |> String.concat
                   )
                ++ "Z"

        nextLevel name list =
            case Dict.get name model.votingData of
                Just data ->
                    let
                        colour =
                            ((toFloat data.percentage / 100.0) * 255)
                                |> round
                                |> Hex.toString
                                |> (\hex -> "#" ++ hex ++ "0000")
                    in
                    S.path [ SA.d (pathFrom list), SA.fill colour, onMouseOver (Over name) ] []

                Nothing ->
                    S.path [ SA.d (pathFrom list), SA.fill "#112233", onMouseOver (Over name) ] []

        topLevel name list =
            List.map (nextLevel name) list

        paths =
            model.features
                |> List.map (\feature -> List.map (topLevel feature.name) feature.coordinates)
                |> List.concat
                |> List.concat
    in
    div []
        [ div [] [ text (model.display |> Maybe.withDefault "") ]
        , S.svg [ SA.viewBox "-8 -1 12 20", SA.width "720", SA.height "780" ] paths
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
