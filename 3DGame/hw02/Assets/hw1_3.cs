using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class hw1_3 : MonoBehaviour
{
    private void Awake()
    {
        Debug.Log("Awake!");
    }
 
    void Start () {
        Debug.Log("Start!");
	}
	
    void Update () {
        Debug.Log("Update!");
	}
 
    private void FixedUpdate()
    {
        Debug.Log("Fixedupdate!");
    }
 
    private void OnGUI()
    {
        Debug.Log("OnGUI!");
    }
 
    private void OnDisable()
    {
        Debug.Log("OnDisable!");
    }
 
    private void OnEnable()
    {
        Debug.Log("OnEnable!");
    }
}
