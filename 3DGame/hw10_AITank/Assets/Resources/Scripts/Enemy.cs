using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Enemy : Tank {

    public delegate void RecycleEnemy(GameObject enemy);

    public static event RecycleEnemy recycleEnemy;

    private Vector3 player_position;

    private bool gameover;

    private void Start()
    {
        player_position = GameDirector.getInstance().currentSceneController.getPlayer().transform.position;
        StartCoroutine(shoot());
    }

    void Update() {
        player_position = GameDirector.getInstance().currentSceneController.getPlayer().transform.position;
        gameover = GameDirector.getInstance().currentSceneController.getGameOver();
        if (!gameover){
            if (getHP() <= 0 && recycleEnemy != null)
                recycleEnemy(this.gameObject);
            else{
                NavMeshAgent agent = gameObject.GetComponent<NavMeshAgent>();
                agent.SetDestination(player_position);
            }
        }else{
            NavMeshAgent agent = gameObject.GetComponent<NavMeshAgent>();
            agent.velocity = Vector3.zero;
            agent.ResetPath();
        }
    }
    IEnumerator shoot(){
        while (!gameover){
            for(float i =1;i> 0; i -= Time.deltaTime)
                yield return 0;
            
            if(Vector3.Distance(player_position,gameObject.transform.position) < 14)
                shoot(TankType.ENEMY);
            
        }
    }
}
