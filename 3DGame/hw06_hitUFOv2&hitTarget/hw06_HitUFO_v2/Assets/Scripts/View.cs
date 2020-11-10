using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IUserAction{
    void GameOver();
}

public class View : MonoBehaviour{
    private Model model;
    private GUIStyle fontstyle0 = new GUIStyle();
    private GUIStyle fontstyle = new GUIStyle();
    private GUIStyle fontstyle1 = new GUIStyle();

    void Start(){
        model = Controller.getInstance().currentModel as Model;
        fontstyle0.fontSize = 48;
        fontstyle0.normal.textColor = Color.yellow;
        fontstyle.fontSize = 32;
        fontstyle.normal.textColor = Color.black;
        fontstyle1.fontSize = 32;
        fontstyle1.normal.textColor = Color.yellow;
    }

    void Update(){
    }

    public void OnGUI(){
        GUI.Label(new Rect(10,10,200,200),"HitUFO: Yellow 1, Blue 2, Purple 3", fontstyle0);
        GUI.Label(new Rect(10,60,200,200),"Round: " + model.Round, fontstyle);
        GUI.Label(new Rect(10,90,200,200),"Trial: " + model.Level, fontstyle);
        GUI.Label(new Rect(10,120,200,200),"Score: " + model.Score, fontstyle);
       
        if (GUI.Button(new Rect(10, 180, 100, 50), "Restart")){
            model.Restart();
        }        
    }

}

