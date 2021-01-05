using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class IUserGUI : MonoBehaviour {
    IUserAction action;
    private GUIStyle fontstyle0 = new GUIStyle();
    private GUIStyle fontstyle = new GUIStyle();

	// Use this for initialization
	void Start () {
        action = GameDirector.getInstance().currentSceneController as IUserAction;

        fontstyle0.fontSize = 48;
        fontstyle0.normal.textColor = Color.yellow;
        fontstyle.fontSize = 28;
        fontstyle.normal.textColor = Color.yellow;
	}
	
	// Update is called once per frame
	void Update () {
        if (!action.getGameOver())
        {
            if (Input.GetKey(KeyCode.W))
            {
                action.moveForward();
            }

            if (Input.GetKey(KeyCode.S))
            {
                action.moveBackWard();
            }

           
            if (Input.GetKeyDown(KeyCode.Space))
            {
                action.shoot();
            }
            float offsetX = Input.GetAxis("Horizontal");
            action.turn(offsetX);
        }
    }

    void OnGUI()
    {
        //controller = GameDirector.getInstance().CurrentSceneController as SceneController;

        GUI.Label(new Rect(10,10,200,200),"AI Tank Game", fontstyle0);
        GUI.Label(new Rect(10,60,200,200),"Press W/S/A/D to control the tank, Press Space to shoot.", fontstyle);
        if(GUI.Button(new Rect(10, 100, 200, 50), "Pause")){
            Time.timeScale = 0;
        }
        if(GUI.Button(new Rect(250, 100, 200, 50), "Continue")){
            Time.timeScale = 1;
        }
        if(GUI.Button(new Rect(10, 200, 200, 50), "Restart")){
            SceneManager.LoadScene(0);
        }


        if (action.getGameOver())
        {
            GUIStyle fontStyle = new GUIStyle();
            fontStyle.fontSize = 30;
            fontStyle.normal.textColor = new Color(0, 0, 0);
            GUI.Label(new Rect(Screen.width/2-50, Screen.height/2-50, 200, 50), "GameOver!", fontstyle0);

            if(GUI.Button(new Rect(Screen.width/2-50, Screen.height/2+50, 200, 50), "Restart"))
                SceneManager.LoadScene(0);
        }


    }
}
