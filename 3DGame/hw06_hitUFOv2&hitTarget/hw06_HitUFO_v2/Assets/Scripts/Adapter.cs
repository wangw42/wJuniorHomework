using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Adapter : SSActionManager, ISSActionCallback{
    public bool running;

    public virtual void fly(GameObject ufo,float speed){
    }

    public void SSActionEvent(SSAction source,SSActionEventType events = SSActionEventType.Completed,
        int intParam = 0,
        string strParam = null,
        Object objectParam = null) {
        
    }

    public void pause(){
        running=!running;
    }

    void Start(){
        running=true;
    }

    void Update(){
        if(running){
            base.Update();   
        }
    }
}