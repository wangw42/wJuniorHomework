using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UserGUI : MonoBehaviour {

    private IUserAction action;
    // 0-未开始、1-已开始、2-失败、3-成功
    public int sign = 0;
    void Start() {
        action = SSDirector.GetInstance().CurrentScenceController as IUserAction;
    }

    void OnGUI() {
        GUIStyle text_style;
        GUIStyle button_style;

        text_style = new GUIStyle() {
            fontSize = 30
        };
        button_style = new GUIStyle("button") {
            fontSize = 15
        };

        
        if(sign == 0) {
            if(GUI.Button(new Rect(Screen.width / 2 - 50, Screen.height / 3, 100, 50), "Start", button_style)) {
                sign = 1;
            } 
        }
        
        if (sign == 2) {
            GUI.Label(new Rect(Screen.width / 2 - 60, Screen.height / 2-120, 100, 50), "Gameover!", text_style);
            if (GUI.Button(new Rect(Screen.width / 2 - 50, Screen.height / 3, 100, 50), "Restart", button_style)) {
                action.Restart();
                sign = 1;
            }
        } else if (sign == 3) {
            GUI.Label(new Rect(Screen.width / 2 - 60, Screen.height / 2 - 120, 100, 50), "You Win!", text_style);
            if (GUI.Button(new Rect(Screen.width / 2 - 50, Screen.height / 3, 100, 50), "Restart", button_style)) {
                action.Restart();
                sign = 1;
            }
        }
    }
}