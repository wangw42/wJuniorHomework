using System.Collections;
using System.Collections.Generic;
using UnityEngine;


// 设置相机跟随玩家
public class CameraFollowAction : MonoBehaviour{
    public GameObject player;            
    public float speed = 5f;          
    Vector3 offset;                      

    void Start() {
        offset = new Vector3(0, 6, -6);
    }

    void FixedUpdate() {
        Vector3 target = player.transform.position + offset;
        transform.position = Vector3.Lerp(transform.position, target, speed * Time.deltaTime);
    }
}
