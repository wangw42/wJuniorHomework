using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface ForModel{
    void LoadResources();
    void Pause();
    void Resume();
}

public class Model : MonoBehaviour, ForModel{
    public int Score;
    public int Round;
    public int mytime;
    public int Level;
    Controller controller;
    public Factory myfactory;

    void Awake(){
        controller = Controller.getInstance();
        controller.setFPS(60);
        controller.currentModel = this;
        controller.running=true;
        LoadResources();
        Score=0;
        Round=1;
        Level=0;
        mytime=0;
        myfactory=Sing.Instance;
        InvokeRepeating("updatetime",1f,1f);
        InvokeRepeating("gentiral",1f,3f);
    }

    public void Start(){
        Debug.Log(myfactory);
        for(int i=0; i<10;i++){
            myfactory.newUFO();
        }
    }

    public void Restart(){
        controller.running=false;
        Score=0;
        Round=1;
        Level=0;
        mytime=0;
        List<GameObject> ufos = myfactory.UFO_on;
        List<GameObject> t= new List<GameObject>();
        foreach(GameObject ufo in ufos){
            t.Add(ufo);
        }
        ufos.Clear();
        foreach(GameObject st in t){
            myfactory.freeUFO(st);
        }
        for(int i=0; i<10;i++){
            myfactory.newUFO();
        }
        controller.running=true;
    }

    public void Resume(){

    }

    public void Pause(){
        controller.running=!controller.running;
    }

    public void LoadResources(){

    }

    public void gentiral(){
        if(controller.running == false)
            return;
        Level+=1;
        while (myfactory.UFO_on.Count < 10){
            myfactory.newUFO();
        }
    }

    public void updatetime(){
        if(controller.running == false)
            return;
        mytime+=1;
        if(mytime>=30){
            mytime=0;
            Level=0;
            Round+=1;
        }
        if(Round == 4){
            Pause();
        }
        Debug.Log(mytime);
    }

    void Update(){
        if(controller.running == false)
            return;
        List<GameObject> ufos = myfactory.UFO_on;
        try{
            foreach(GameObject ufo in ufos) {
                Vector3 v = new Vector3(ufo.transform.localRotation.x,ufo.transform.localRotation.y,ufo.transform.localRotation.z);
                ufo.transform.Translate(v*Time.deltaTime*Round*2);
                if(ufo.transform.position.x > 10 || ufo.transform.position.x < -10){
                    myfactory.freeUFO(ufo);
                }
                if(ufo.transform.position.y > 10 || ufo.transform.position.y < -10){
                    myfactory.freeUFO(ufo);
                }
                if(ufo.transform.position.z < -10){
                    myfactory.freeUFO(ufo);
                }
            }
        }catch{
        }


        if (Input.GetButtonDown("Fire1")) {
			Debug.Log (Input.mousePosition);

			Vector3 mp = Input.mousePosition; 
			Camera ca;
			ca = Camera.main;
			Ray ray = ca.ScreenPointToRay(Input.mousePosition);

			RaycastHit[] hits = Physics.RaycastAll (ray);

			foreach (RaycastHit hit in hits) {
                if(hit.transform.gameObject == null){
                    continue;
                }
                if(hit.transform.gameObject.name == "ufo1(Clone)"){
                    Score += 1;
                }
                if(hit.transform.gameObject.name == "ufo2(Clone)"){
                    Score += 2;
                }
                if(hit.transform.gameObject.name == "ufo3(Clone)"){
                    Score += 3;
                }
				print (hit.transform.gameObject.name);
				if (hit.collider.gameObject.tag.Contains("Finish")) { 
				}
                myfactory.freeUFO(hit.transform.gameObject);
                Debug.Log("on:"+myfactory.UFO_on.Count);
                Debug.Log("off"+myfactory.UFO_off.Count);
			}
		}	

    }
}
