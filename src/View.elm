module View exposing (view)

import Html exposing (div, Html, text, button)
import Collage
import Element
import Color exposing (Color)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onMouseDown, onMouseUp, on)
import Markdown
import Model exposing (Model)
import Actions exposing (Action)
import Grid exposing (Grid)
import Json.Decode as Json


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


onTouchStart : Action -> Html.Attribute Action
onTouchStart action =
    on "touchstart" (Json.succeed action)


onTouchEnd : Action -> Html.Attribute Action
onTouchEnd action =
    on "touchend" (Json.succeed action)


renderBox : ( Float, Float ) -> (Color -> Color) -> Color -> ( Int, Int ) -> Collage.Form
renderBox ( xOff, yOff ) fun c ( x, y ) =
    Collage.rect 30 30
        |> Collage.filled (fun c)
        |> Collage.move ( (toFloat x + xOff) * 30, (toFloat y + yOff) * -30 )


renderNext : Grid Color -> Html Action
renderNext grid =
    let
        ( width, height ) =
            Grid.size grid
    in
        grid
            |> Grid.mapToList (renderBox ( (1 - toFloat width) / 2, (1 - toFloat height) / 2 ) (always (Color.rgb 236 240 241)))
            |> Collage.collage (width * 30) (height * 30)
            |> Element.toHtml


renderWell : Model -> Html Action
renderWell { width, height, active, grid, position } =
    (Collage.filled (Color.rgb 236 240 241) (Collage.rect (toFloat (width * 30)) (toFloat (height * 30)))
        :: (grid
                |> Grid.stamp (Tuple.first position) (floor (Tuple.second position)) active
                |> Grid.mapToList (renderBox ( (1 - toFloat width) / 2, (1 - toFloat height) / 2 ) identity)
           )
    )
        |> Collage.collage (width * 30) (height * 30)
        |> Element.toHtml


renderTitle : String -> Html Action
renderTitle txt =
    div
        [ style
            [ "color" => "#34495f"
            , "font-size" => "40px"
            , "line-height" => "60px"
            , "margin" => "30px 0 0"
            ]
        ]
        [ text txt ]


renderLabel : String -> Html Action
renderLabel txt =
    div
        [ style
            [ "color" => "#bdc3c7"
            , "font-weight" => "300"
            , "line-height" => "1"
            , "margin" => "30px 0 0"
            ]
        ]
        [ text txt ]


renderCount : Int -> Html Action
renderCount n =
    div
        [ style
            [ "color" => "#3993d0"
            , "font-size" => "30px"
            , "line-height" => "1"
            , "margin" => "5px 0 0"
            ]
        ]
        [ text (toString n) ]


renderGameButton : Model.State -> Html Action
renderGameButton state =
    let
        ( txt, action ) =
            case state of
                Model.Stopped ->
                    ( "New game", Actions.Start )

                Model.Playing ->
                    ( "Pause", Actions.Pause )

                Model.Paused ->
                    ( "Resume", Actions.Resume )
    in
        button
            [ style
                [ "background" => "transparent"
                , "border" => "1px solid black"
                , "border-radius" => "20px"
                , "color" => "black"
                , "cursor" => "pointer"
                , "display" => "block"
                , "font-family" => "Helvetica, Arial, sans-serif"
                , "font-size" => "18px"
                , "font-weight" => "300"
                , "height" => "60px"
                , "line-height" => "60px"
                , "outline" => "none"
                , "padding" => "0"
                , "width" => "120px"
                , "position" => "fixed"
                , "top" => "20px"
                , "right" => "20px"
                ]
            , onClick action
            ]
            [ text txt ]


renderPanel : Model -> Html Action
renderPanel { score, lines, next, state } =
    div
        [ style
            [ "bottom" => "80px"
            , "color" => "#34495f"
            , "font-family" => "Helvetica, Arial, sans-serif"
            , "font-size" => "14px"
            , "left" => "300px"
            , "padding" => "0 30px"
            , "position" => "absolute"
            , "right" => "0"
            , "top" => "0"
            ]
        ]
        [ renderTitle "Flatris"
        , renderLabel "Score"
        , renderCount score
        , renderLabel "Lines Cleared"
        , renderCount lines
        , renderLabel "Next Shape"
        , div
            [ style
                [ "margin-top" => "10px"
                , "position" => "relative"
                ]
            ]
            [ renderNext next ]
        ]


renderControlButton : String -> List (Html.Attribute Action) -> Html Action
renderControlButton txt attrs =
    div
        (style
            [ "border" => "0"
            , "color" => "#34495f"
            , "cursor" => "pointer"
            , "text-align" => "center"
            , "-webkit-user-select" => "none"
            , "display" => "block"
            , "float" => "left"
            , "font-family" => "Helvetica, Arial, sans-serif"
            , "font-size" => "24px"
            , "font-weight" => "300"
            , "height" => "80px"
            , "line-height" => "80px"
            , "margin" => "10px"
            , "outline" => "none"
            , "padding" => "0"
            , "width" => "80px"
            , "border-radius" => "80px"
            , "border" => "1px solid black"
            ]
            :: attrs
        )
        [ text txt ]


renderControls : Html Action
renderControls =
    div
        [ style
            [ ( "position", "fixed" )
            , ( "top", "0" )
            , ( "right", "0" )
            , ( "bottom", "0" )
            , ( "left", "0" )
            , ( "display", "flex" )
            , ( "flex-flow", "row nowrap" )
            , ( "align-items", "center" )
            , ( "justify-content", "space-between" )
            ]
        , onTouchEnd Actions.UnlockButtons
        , onMouseUp Actions.UnlockButtons
        ]
        [ div [ style [ ( "flex", "0 1" ), ( "min-width", "204px" ) ] ]
            [ renderControlButton "←"
                [ onMouseDown (Actions.MoveLeft True)
                , onMouseUp (Actions.MoveLeft False)
                , onTouchStart (Actions.MoveLeft True)
                , onTouchEnd (Actions.MoveLeft False)
                ]
            , renderControlButton "→"
                [ onMouseDown (Actions.MoveRight True)
                , onMouseUp (Actions.MoveRight False)
                , onTouchStart (Actions.MoveRight True)
                , onTouchEnd (Actions.MoveRight False)
                ]
            ]
        , div [ style [ ( "flex", "0 1" ), ( "min-width", "204px" ) ] ]
            [ renderControlButton "↻"
                [ onMouseDown (Actions.Rotate True)
                , onMouseUp (Actions.Rotate False)
                , onTouchStart (Actions.Rotate True)
                , onTouchEnd (Actions.Rotate False)
                ]
            , renderControlButton "↓"
                [ onMouseDown (Actions.Accelerate True)
                , onMouseUp (Actions.Accelerate False)
                , onTouchStart (Actions.Accelerate True)
                , onTouchEnd (Actions.Accelerate False)
                ]
            ]
        ]


renderInfo : Model.State -> Html Action
renderInfo state =
    div
        [ style
            [ "background" => "rgba(236, 240, 241, 0.85)"
            , "color" => "#34495f"
            , "font-family" => "Helvetica, Arial, sans-serif"
            , "font-size" => "18px"
            , "height" => "600px"
            , "left" => "0"
            , "line-height" => "1.5"
            , "padding" => "0 15px"
            , "position" => "absolute"
            , "top" => "0"
            , "width" => "270px"
            , "display"
                => if state == Model.Playing then
                    "none"
                   else
                    "block"
            ]
        ]
        [ Markdown.toHtml [] """
elm-flatris is a [**Flatris**](https://github.com/skidding/flatris)
clone coded in [**Elm**](http://elm-lang.org/) language.

Inspired by the classic [**Tetris**](http://en.wikipedia.org/wiki/Tetris)
game, the game can be played with a keyboard using the arrow keys,
and on mobile devices using the buttons below.

elm-flatris is open source on
[**GitHub**](https://github.com/w0rm/elm-flatris).
"""
        ]


view : Model -> Html Action
view model =
    div
        [ style
            [ "padding" => "10px"
            , "overflow" => "hidden"
            ]
        , onTouchEnd Actions.UnlockButtons
        , onMouseUp Actions.UnlockButtons
        ]
        [ div
            [ style
                [ "margin" => "auto"
                , "position" => "relative"
                , "width" => "480px"
                ]
            ]
            [ renderWell model
            , renderPanel model
            , renderInfo model.state
            ]
        , renderControls
        , renderGameButton model.state
        ]
