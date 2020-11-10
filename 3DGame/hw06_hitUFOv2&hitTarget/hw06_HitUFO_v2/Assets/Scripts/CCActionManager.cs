using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CCActionManager : Adapter{

    public override void fly(GameObject ufo,float speed){
        CCFlyAction action = CCFlyAction.GetSSAction(speed);
        this.RunAction(ufo, action, this);
    }

}
