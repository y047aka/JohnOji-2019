module Main exposing (main)

--import Html exposing (Html, text, node, div, header, section, nav, footer, h1, h2, p, a, ul, li, img)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Time


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { userState : UserState
    }


type UserState
    = Init
    | Loaded Vehicles
    | Failed Http.Error


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Init
    , fetchJson 1560460447855
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | Recieve (Result Http.Error Vehicles)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick posix ->
            ( model, fetchJson 1560460989381 )

        Recieve (Ok vehicles) ->
            ( { model | userState = Loaded vehicles }, Cmd.none )

        Recieve (Err error) ->
            ( { model | userState = Failed error }, Cmd.none )


fetchJson : Int -> Cmd Msg
fetchJson int =
    Http.get
        { url = "https://storage.googleapis.com/fiawec-prod/assets/live/WEC/__data.json?_=" ++ String.fromInt int
        , expect = Http.expectJson Recieve userDecoder
        }



-- HTTP


type alias Vehicle =
    { runningPosition : Int
    , vehicleNumber : Int
    , state : String
    , category : String
    , car : String
    , fullName : String

    -- , vehicleManufacturer : String
    , lapsCompleted : String
    , gap : String
    , interval : String
    , lastLapTime : String
    , bestLapTime : String
    , currentSector1 : String
    , bestSector1 : String
    , currentSector2 : String
    , bestSector2 : String
    , currentSector3 : String
    , bestSector3 : String
    , pitStop : Int
    }


type alias Vehicles =
    List Vehicle


type alias Stop =
    { pit_in_lap_count : Int
    }


userDecoder : Decode.Decoder Vehicles
userDecoder =
    Decode.field "entries" (Decode.list vehicle)


vehicle : Decode.Decoder Vehicle
vehicle =
    Decode.succeed Vehicle
        |> required "ranking" Decode.int
        |> required "number" Decode.int
        |> required "state" Decode.string
        |> required "category" Decode.string
        |> required "car" Decode.string
        |> required "driver" Decode.string
        -- |> required "vehicle_manufacturer" Decode.string
        |> required "lap" Decode.string
        |> required "gap" Decode.string
        |> required "gapPrev" Decode.string
        |> required "lastlap" Decode.string
        |> required "bestlap" Decode.string
        |> required "currentSector1" Decode.string
        |> required "bestSector1" Decode.string
        |> required "currentSector2" Decode.string
        |> required "bestSector2" Decode.string
        |> required "currentSector3" Decode.string
        |> required "bestSector3" Decode.string
        |> required "pitstop" Decode.int


stopDecoder : Decode.Decoder Stop
stopDecoder =
    Decode.succeed Stop
        |> required "pit_in_lap_count" Decode.int



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 5000 Tick



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Leaderboard - WEC"
    , body =
        [ siteHeader
        , node "main"
            []
            [ section []
                [ case model.userState of
                    Init ->
                        text ""

                    Loaded vehicles ->
                        table [ class "leaderboard" ]
                            [ tr []
                                [ th [] [ text "Pos" ]
                                , th [] [ text "#" ]
                                , th [] [ text "State" ]
                                , th [] [ text "Category" ]
                                , th [] [ text "Car" ]
                                , th [] [ text "Driver" ]

                                -- , th [] [ text "" ]
                                , th [] [ text "Laps" ]
                                , th [] [ text "Gap" ]
                                , th [] [ text "Interval" ]
                                , th [] [ text "Last Lap" ]
                                , th [] [ text "Best Lap" ]
                                , th [] [ text "S1" ]
                                , th [] [ text "BS1" ]
                                , th [] [ text "S2" ]
                                , th [] [ text "BS2" ]
                                , th [] [ text "S3" ]
                                , th [] [ text "BS3" ]
                                , th [] [ text "Pit Stops" ]
                                ]
                            , tbody [] (List.map viewRaces vehicles)
                            ]

                    Failed error ->
                        div [] [ text (Debug.toString error) ]
                ]
            ]
        , siteFooter
        ]
    }


viewRaces : Vehicle -> Html Msg
viewRaces d =
    -- let
    --     manufacturer =
    --         case d.vehicleManufacturer of
    --             "Chv" ->
    --                 "Chevrolet"
    --             "Frd" ->
    --                 "Ford"
    --             "Tyt" ->
    --                 "Toyota"
    --             _ ->
    --                 ""
    -- in
    tr []
        [ td [] [ text (String.fromInt d.runningPosition) ]
        , td []
            [ p [ class d.category ] [ text (String.fromInt d.vehicleNumber) ]
            ]
        , td [] [ text d.state ]
        , td [ class d.category ] [ text d.category ]
        , td [] [ text d.car ]
        , td [] [ text d.fullName ]

        -- , td [] [ text manufacturer ]
        , td [] [ text d.lapsCompleted ]
        , td [] [ text d.gap ]
        , td [] [ text d.interval ]
        , td [] [ text d.lastLapTime ]
        , td [] [ text d.bestLapTime ]
        , td [] [ text d.currentSector1 ]
        , td [ class "best-time" ] [ text d.bestSector1 ]
        , td [] [ text d.currentSector2 ]
        , td [ class "best-time" ] [ text d.bestSector2 ]
        , td [] [ text d.currentSector3 ]
        , td [ class "best-time" ] [ text d.bestSector3 ]
        , td [] [ text (String.fromInt d.pitStop) ]
        ]


pitStop : Stop -> Html Msg
pitStop stop =
    li [] [ text (stop.pit_in_lap_count |> String.fromInt) ]


siteHeader : Html Msg
siteHeader =
    Html.header [ class "site-header" ]
        [ h1 [] [ text "Leaderboard" ]
        ]


siteFooter : Html Msg
siteFooter =
    footer [ class "site-footer" ]
        [ p [ class "copyright" ]
            [ text "© 2019 "
            , a [ href "https://y047aka.me", target "_blank" ] [ text "y047aka" ]
            ]
        ]
