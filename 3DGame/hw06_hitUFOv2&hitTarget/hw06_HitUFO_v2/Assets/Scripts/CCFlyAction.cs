using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CCFlyAction : SSAction{

    public float speed;

    public static CCFlyAction GetSSAction(float speed){
        CCFlyAction action = ScriptableObject.CreateInstance<CCFlyAction>();
        action.speed=speed;
        return action;
    }

    public override void Start(){ 
    }

    public override void Update(){
        Vector3 v = new Vector3(this.gameobject.transform.localRotation.x,this.gameobject.transform.localRotation.y,this.gameobject.transform.localRotation.z);
        this.transform.position = Vector3.MoveTowards (this.transform.position, this.transform.position + v*1000000 , speed * Time.deltaTime);

            if(this.gameobject.transform.position.x > 10 || this.gameobject.transform.position.x < -10){
                this.destory=true;
                this.callback.SSActionEvent (this);
            }
            if(this.gameobject.transform.position.y > 10 || this.gameobject.transform.position.y < -10){
                this.destory=true;
                this.callback.SSActionEvent (this);
            }
            if(this.gameobject.transform.position.z < -10){
                this.destory=true;
                this.callback.SSActionEvent (this);
            }

    }
}
