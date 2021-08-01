module Main exposing (..)

import Browser
import Dict exposing (Dict)
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
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    -- let
    -- data =
    --  Decode.decodeValue (Decode.dict Decode.string) flags.data
    --     |> Result.withDefault Dict.empty
    -- in
    ( { features = flags.features, display = Nothing }, Cmd.none )



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
            S.path [ SA.d (pathFrom list), onMouseOver (Over name) ] []

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
