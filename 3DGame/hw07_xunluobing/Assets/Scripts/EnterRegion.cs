using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnterRegion : MonoBehaviour {
    public int region;                        
    FirstSceneController sceneController;      

    void OnTriggerEnter(Collider collider) {
        sceneController = Director.GetInstance().CurrentSceneController as FirstSceneController;
        if (collider.gameObject.tag == "Player") {
            sceneController.playerRegion = region;
        }
    }

    private void OnTriggerExit(Collider collider) {
        if (collider.gameObject.tag == "Patrol") {
            collider.gameObject.GetComponent<PatrolData>().isCollided = true;
        }
    }
}
