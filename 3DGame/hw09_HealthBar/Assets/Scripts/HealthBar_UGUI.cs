using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
 
public class HealthBar_UGUI : MonoBehaviour {
    public Slider slider;
    public float hp = 10f;
    private float hp_diff = 10f;
    private Rect rect_add;
    private Rect rect_sub;
 
    void Start () {
        rect_add = new Rect(20, 50, 140, 80);
        rect_sub = new Rect(200, 50, 140, 80);
	}

    void Update()
    {
        this.transform.LookAt(Camera.main.transform.position);
    }
 
    private void OnGUI() {
        if(GUI.Button(rect_add, "回血")) 
            hp_diff = hp_diff + 1 > 10f? 10f : hp_diff + 1;
        else if(GUI.Button(rect_sub, "掉血")) 
            hp_diff = hp_diff - 1 < 0f? 0f : hp_diff - 1;

        hp = Mathf.Lerp(hp, hp_diff, 0.1f);
        slider.value = hp;
    }
}

