using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Target : MonoBehaviour{
    void Start(){
    }

    void Update(){
    }

    void OnTriggerEnter(Collider other){
        if(other.gameObject.name != "target1" && other.gameObject.name != "target2" && other.gameObject.name != "target3" && other.gameObject.name != "target4" && other.gameObject.name != "target5"
        && Model.shooted == false){
            Model.shooted = true;
            if(this.gameObject.name == "target1"){
                Model.score0 = 5;
                Model.score += 5;
            } else if(this.gameObject.name == "target2"){
                Model.score0 = 4;
                Model.score += 4;
            } else if(this.gameObject.name == "target3"){
                Model.score0 = 3;
                Model.score += 3;
            } else if(this.gameObject.name == "target4"){
                Model.score0 = 2;
                Model.score += 2;
            } else if(this.gameObject.name == "target5"){
                Model.score0 = 1;
                Model.score += 1;
            }

        }
    }

}
