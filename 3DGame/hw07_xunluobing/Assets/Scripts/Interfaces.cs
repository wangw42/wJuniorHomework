using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum ActionEventType : int { Started, Completed } 
public enum GameState { RUNNING, PAUSE, START, LOSE, WIN } 

public interface SceneController{
    GameState getGameState();
    void LoadResources();            
    int GetScore();                          
    void setGameState(GameState gs); 
    void Restart();                  
    void Pause();                   
    void Begin();                    
}

public interface UserAction{
    void MovePlayer(float translationX, float translationZ);
}

public interface ActionCallback{
    void ActionEvent(Action source, ActionEventType events = ActionEventType.Completed,
        int intParam = 0, string strParam = null, object objectParam = null);
}
