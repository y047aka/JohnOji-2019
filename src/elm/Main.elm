module Main exposing (main)

--import Html exposing (Html, text, node, div, header, section, nav, footer, h1, h2, p, a, ul, li, img)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Time exposing (posixToMillis)


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
    | Loaded Race
    | Failed Http.Error


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Init
    , fetchJson 1560463226000
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | Recieve (Result Http.Error Race)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick posix ->
            ( model, fetchJson (posixToMillis posix) )

        Recieve (Ok race) ->
            ( { model | userState = Loaded race }, Cmd.none )

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
    , team : String
    , fullName : String
    , car : String
    , tyre : String
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


type alias Race =
    { summary : RaceSummary
    , vehicles : List Vehicle
    }


type alias RaceSummary =
    { eventName : String
    , elapsedTime : String
    , raceState : String
    , airTemp : String
    , trackTemp : String
    }


type alias Stop =
    { pit_in_lap_count : Int
    }


userDecoder : Decode.Decoder Race
userDecoder =
    Decode.succeed Race
        |> required "params" raceOutlineDecoder
        |> required "entries" (Decode.list vehicleDecoder)


raceOutlineDecoder : Decode.Decoder RaceSummary
raceOutlineDecoder =
    Decode.succeed RaceSummary
        |> required "eventName" Decode.string
        |> required "elapsedTime" Decode.string
        |> required "racestate" Decode.string
        |> required "airTemp" Decode.string
        |> required "trackTemp" Decode.string


vehicleDecoder : Decode.Decoder Vehicle
vehicleDecoder =
    Decode.succeed Vehicle
        |> required "ranking" Decode.int
        |> required "number" Decode.int
        |> required "state" Decode.string
        |> required "category" Decode.string
        |> required "team" Decode.string
        |> required "driver" Decode.string
        |> required "car" Decode.string
        |> required "tyre" Decode.string
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
    { title = "John Oji 2019"
    , body =
        [ siteHeader
        , case model.userState of
            Init ->
                text ""

            Loaded race ->
                node "main"
                    []
                    [ viewRaceSummary race.summary
                    , viewRaceTable race.vehicles
                    ]

            Failed error ->
                text (Debug.toString error)
        ]
    }


viewRaceSummary : RaceSummary -> Html Msg
viewRaceSummary summary =
    section [ class "race-summary" ]
        [ h1 []
            [ text summary.eventName ]
        , table []
            [ tr []
                [ th [] [ text "Elapsed" ]
                , th [] [ text "State" ]
                , th [] [ text "Air-Temp" ]
                , th [] [ text "Track-Temp" ]
                ]
            , tr []
                [ td [] [ text summary.elapsedTime ]
                , td [ class "race-state" ]
                    [ case summary.raceState of
                        "green" ->
                            span [ class "green" ] [ text "GREEN FLAG" ]

                        "yellow" ->
                            span [ class "yellow" ] [ text "YELLOW FLAG" ]

                        "full_yellow" ->
                            span [ class "fcy" ] [ text "FULL COURSE YELLOW" ]

                        "red" ->
                            span [ class "red" ] [ text "RED FLAG" ]

                        _ ->
                            span [] [ text summary.raceState ]
                    ]
                , td [] [ text (summary.airTemp ++ " °C") ]
                , td [] [ text (summary.trackTemp ++ " °C") ]
                ]
            ]
        ]


viewRaceTable : List Vehicle -> Html Msg
viewRaceTable vehicles =
    section [ class "leaderboard" ]
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Pos" ]
                    , th [] [ text "#" ]
                    , th [] [ text "State" ]
                    , th [] [ text "Team" ]
                    , th [] [ text "Driver" ]
                    , th [] [ text "Car" ]
                    , th [] [ text "Tyre" ]
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
                ]
            , tbody [] (List.map viewVehicle vehicles)
            ]
        ]


viewVehicle : Vehicle -> Html Msg
viewVehicle d =
    tr []
        [ td [] [ text (String.fromInt d.runningPosition) ]
        , td [ class "car-number" ]
            [ p [ class d.category ] [ text (String.fromInt d.vehicleNumber) ]
            ]
        , td [] [ text d.state ]

        -- , td [ class d.category ] [ text d.category ]
        , td [] [ text d.team ]
        , td [] [ text d.fullName ]
        , td [] [ text d.car ]
        , td [] [ text d.tyre ]
        , td [] [ text d.lapsCompleted ]
        , td []
            [ case d.gap of
                "" ->
                    text "-"

                _ ->
                    text ("+" ++ d.gap)
            ]
        , td []
            [ case d.interval of
                "" ->
                    text "-"

                _ ->
                    text ("+" ++ d.interval)
            ]
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
        [ h1 [] [ text "" ]
        ]


siteFooter : Html Msg
siteFooter =
    footer [ class "site-footer" ]
        [ p [ class "copyright" ]
            [ text "© 2019 "
            , a [ href "https://y047aka.me", target "_blank" ] [ text "y047aka" ]
            ]
        ]
