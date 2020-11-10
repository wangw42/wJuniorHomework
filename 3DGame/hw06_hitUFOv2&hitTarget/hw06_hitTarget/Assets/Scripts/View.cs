using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IUserAction
{
    void GameOver();
}

public class View : MonoBehaviour
{
    private Model action;
    private GUIStyle fontstyle = new GUIStyle();
    private GUIStyle fontstyle1 = new GUIStyle();

    void Start(){
        action = Controller.getInstance().currentModel as Model;
        fontstyle.fontSize = 36;
        fontstyle.normal.textColor = Color.yellow;
        fontstyle1.fontSize = 28;
        fontstyle1.normal.textColor = Color.white;
    }

    void Update(){
        
    }

    public void OnGUI(){
        GUI.Label(new Rect(10,20,200,200),"打靶游戏，按空格回收箭矢", fontstyle1);
        GUI.Label(new Rect(10,80,200,200),"Sum Score: " + Model.score, fontstyle);
        GUI.Label(new Rect(10,140,200,200),"This trial's Score: " + Model.score0, fontstyle1);
        
        if(Model.wind_direction == 0){
            GUI.Label(new Rect(10,180,200,200),"Wind: ← " + Model.strength, fontstyle1);
        }
        else if(Model.wind_direction == 1){
            GUI.Label(new Rect(10,180,200,200),"Wind: → " + Model.strength, fontstyle1);
        }
        else if(Model.wind_direction == 2){
            GUI.Label(new Rect(10,180,200,200),"Wind: ↑ " + Model.strength, fontstyle1);
        }
        else if(Model.wind_direction == 3){
            GUI.Label(new Rect(10,180,200,200),"Wind: ↓ " + Model.strength, fontstyle1);
        }
        

    }

}
