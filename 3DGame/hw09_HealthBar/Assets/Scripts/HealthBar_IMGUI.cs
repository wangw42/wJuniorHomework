using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
public class HealthBar_IMGUI : MonoBehaviour {

    public float hp = 10f;
    private float hp_diff = 10f;
    private Rect rect_hp;
    private Rect rect_add;
    private Rect rect_sub;
 
    void Start () {

        rect_hp = new Rect(800, 600, 1000, 100);
        rect_add = new Rect(800, 700, 140, 80);
        rect_sub = new Rect(1600, 700, 140, 80);
	}

    private void OnGUI() {
        if(GUI.Button(rect_add, "回血")) {
            hp_diff = hp_diff + 1 > 10f? 10f : hp_diff + 1;
        }
        else if(GUI.Button(rect_sub, "掉血")) 
            hp_diff = hp_diff - 1 < 0f? 0f : hp_diff - 1;

        hp = Mathf.Lerp(hp, hp_diff, 0.1f);
        GUI.HorizontalScrollbar(rect_hp, 0f, hp, 0f, 10f);
    }

}

