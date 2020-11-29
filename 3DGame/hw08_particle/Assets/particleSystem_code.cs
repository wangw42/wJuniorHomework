using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class particleSystem_code : MonoBehaviour {

    ParticleSystem ps;
    float size = 5f;

    // Use this for initialization
    void Start () {
        ps = GetComponent<ParticleSystem>();
    }
	
	// Update is called once per frame
	void Update () {
        size = size * 0.99f;
        var main = ps.main;
        main.startSize  = size;
	}
}
