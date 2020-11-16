using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PatrolCollide : MonoBehaviour
{
    void OnCollisionEnter(Collision collision) {
        if (collision.gameObject.tag == "Player") {
            this.GetComponent<Animator>().SetTrigger("shoot");
            Singleton<GameEventManager>.Instance.OnPlayerCatched();
        } else if(collision.gameObject.tag == "Pig"){

            Director.GetInstance().leaveSeconds -= Random.Range(1,10);
            Destroy(collision.gameObject);

        } else {
            this.GetComponent<PatrolData>().isCollided = true;
        }

    }
}
