using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneController : MonoBehaviour,IUserAction{
    public GameObject player;
    private int enemyCount = 5;
    private bool gameOver = false;
    private GameObject[] enemys;
    private MyFactory myFactory;
    public GameDirector director;

    private void Awake()
    {
        director = GameDirector.getInstance();
        director.currentSceneController = this;
        enemys = new GameObject[enemyCount];
        gameOver = false;
        myFactory = Singleton<MyFactory>.Instance;
       
    }
   
    void Start () {
        player = myFactory.getPlayer();
        for (int i = 0; i < enemyCount; i++)
            enemys[i]=myFactory.getEnemys();
            
        Player.destroyEvent += setGameOver;
    }
	
	// Update is called once per frame
	void Update () {
        Camera.main.transform.position = new Vector3(player.transform.position.x, 18, player.transform.position.z);
    }

    public GameObject getPlayer()
    {
        return player;
    }

    public bool getGameOver()
    {
        return gameOver;
    }

    public void setGameOver()
    {
        gameOver = true;
    }

    public void moveForward()
    {
        player.GetComponent<Player>().moveForward();
    }

    public void moveBackWard()
    {
        player.GetComponent<Player>().moveBackWard();
    }


    public void turn(float offsetX)
    {
        player.GetComponent<Player>().turn(offsetX);
    }

    public void shoot()
    {
        player.GetComponent<Player>().shoot(TankType.PLAYER);
    }

}
