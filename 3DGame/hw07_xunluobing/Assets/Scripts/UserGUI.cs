using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UserGUI : MonoBehaviour
{
    private UserAction action;
    private SceneController controller;
    GUIStyle font_style1;
    GUIStyle buttonStyle;
    GUIStyle font_style2;

    void Start() {
        font_style1 = new GUIStyle();
        font_style1.fontSize = 40;
        font_style1.normal.textColor = Color.yellow;

        buttonStyle = new GUIStyle("button");
        buttonStyle.fontSize = 40;
        buttonStyle.normal.textColor = Color.white;

        font_style2 = new GUIStyle();
        font_style2.fontSize = 40;
        font_style2.normal.textColor = Color.yellow;

    }

    private void Update() {
        action = Director.GetInstance().CurrentSceneController as UserAction;
        controller = Director.GetInstance().CurrentSceneController as SceneController;
        if (controller.getGameState().Equals(GameState.RUNNING)) {
            float translationX = Input.GetAxis("Horizontal");
            float translationZ = Input.GetAxis("Vertical");
            action.MovePlayer(translationX, translationZ);
        }
    }

    private void OnGUI() {
        controller = Director.GetInstance().CurrentSceneController as SceneController;
        string buttonText = "";
        if (controller.getGameState().Equals(GameState.START) || controller.getGameState().Equals(GameState.PAUSE)) {
            buttonText = "Start";
        }
        if (controller.getGameState().Equals(GameState.LOSE)) {
            buttonText = "Restart";
            GUI.Label(new Rect(Screen.width / 2 - 120, Screen.height / 2 - 200, 200, 50), "Game Over!", font_style2);
        }
        if (controller.getGameState().Equals(GameState.WIN)) {
            buttonText = "Restart";
            GUI.Label(new Rect(Screen.width / 2 - 80, Screen.height / 2 - 200, 200, 50), "You Win!", font_style2);
        } 

        GUI.Label(new Rect(40 , 20, 100, 50),
            "Score: " + controller.GetScore().ToString(), font_style1);
        GUI.Label(new Rect(40, 80, 100, 50),
            "Time: " + Director.GetInstance().leaveSeconds.ToString(), font_style2);

        if (buttonText == "Start"){
            if(GUI.Button(new Rect(Screen.width / 2 - 50, Screen.height / 2 + 200, 200, 100), buttonText, buttonStyle))
                controller.Begin();
        }else if(buttonText == "Restart"){
            if(GUI.Button(new Rect(Screen.width / 2 - 50, Screen.height / 2 + 200, 200, 100), buttonText, buttonStyle))
                controller.Restart();
        } 

    }
}
