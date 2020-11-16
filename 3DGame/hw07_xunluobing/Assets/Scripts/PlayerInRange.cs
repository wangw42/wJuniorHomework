using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInRange : MonoBehaviour
{
    void OnTriggerEnter(Collider collider) {
        if (collider.gameObject.tag == "Player") {
            this.gameObject.transform.parent.GetComponent<PatrolData>().isPlayerInRange = true;
            this.gameObject.transform.parent.GetComponent<PatrolData>().player = collider.gameObject;
        }
    }
    void OnTriggerExit(Collider collider) {
        if (collider.gameObject.tag == "Player") {
            this.gameObject.transform.parent.GetComponent<PatrolData>().isPlayerInRange = false;
            this.gameObject.transform.parent.GetComponent<PatrolData>().player = null;
        }
    }
}
