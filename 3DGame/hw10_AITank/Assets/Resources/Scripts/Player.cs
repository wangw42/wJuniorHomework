using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : Tank{
    public delegate void DestroyPlayer();
    public static event DestroyPlayer destroyEvent;


    void Start () {
        setHP(10.0f);
	}
	
	void Update () {
		if(getHP()<= 0)    
        {
            this.gameObject.SetActive(false);
            destroyEvent();
        }
	}

    public void moveForward(){
        gameObject.GetComponent<Rigidbody>().velocity = gameObject.transform.forward * 20;
    }

    public void moveBackWard(){
        gameObject.GetComponent<Rigidbody>().velocity = gameObject.transform.forward * -20;
    }


    public void turn(float offsetX){
        float x = gameObject.transform.localEulerAngles.x;
        float y = gameObject.transform.localEulerAngles.y + offsetX*2;
        gameObject.transform.localEulerAngles = new Vector3(x, y, 0);
    }
}
