using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Director : System.Object{
    private static Director _instance;                          
    public SceneController CurrentSceneController { get; set; } 
    public int leaveSeconds = 60;                               

    private Director() {}

    public static Director GetInstance() {
        if (_instance == null) {
            _instance = new Director();
        }
        return _instance;
    }

    public int GetFPS() {
        return Application.targetFrameRate;
    }

    public void SetFPS(int fps) {
        Application.targetFrameRate = fps;
    }

    public IEnumerator CountDown() {
        while (leaveSeconds > 0) {
            yield return new WaitForSeconds(1f);
            leaveSeconds--;
            if (leaveSeconds == 0) {
                Singleton<GameEventManager>.Instance.TimeIsUP();
            }
        }
    }
}
