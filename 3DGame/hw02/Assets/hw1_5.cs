using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class hw1_5 : MonoBehaviour
{
    void Start () {
        Debug.Log("start!");
        GameObject table = Resources.Load("table") as GameObject;
        Instantiate(table);
 
        table.transform.position = new Vector3(0, Random.Range(5, 7), 0);
        table.transform.parent = this.transform;
	}
	
	void Update () {
		
	}
}
