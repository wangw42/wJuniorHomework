using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum TankType { PLAYER , ENEMY};
public class MyFactory : MonoBehaviour {

    public GameObject player;
    public GameObject enemy;
    public GameObject bullet;
    private GameObject role;

    public ParticleSystem explosion;

    private List<GameObject> current_tanks;
    private List<GameObject> dead_tanks;
    private List<GameObject> current_bullets;
    private List<GameObject> used_bullets;
    private List<ParticleSystem> particles;

    private void Awake()
    {
        current_tanks = new List<GameObject>();
        dead_tanks = new List<GameObject>();
        current_bullets = new List<GameObject>();
        used_bullets = new List<GameObject>();
        particles = new List<ParticleSystem>();

        role = GameObject.Instantiate<GameObject>(player) as GameObject;
        role.SetActive(true);
        role.transform.position = Vector3.zero;
    }
    // Use this for initialization
    void Start () {
        Enemy.recycleEnemy += recycleEnemy;
    }
	
	// Update is called once per frame
	public GameObject getPlayer()
    {      
        return role;
    }

    public GameObject getEnemys()
    {
        GameObject new_tank = null;
        if (dead_tanks.Count <= 0) {
            new_tank = GameObject.Instantiate<GameObject>(enemy) as GameObject;
            current_tanks.Add(new_tank);
            new_tank.transform.position = new Vector3(Random.Range(-100, 100), 0, Random.Range(-100, 100));
        }else {
            new_tank = dead_tanks[0];
            dead_tanks.RemoveAt(0);
            current_tanks.Add(new_tank);
        }
        new_tank.SetActive(true);
        return new_tank;
    }

    public GameObject getBullets(TankType type)
    {
        GameObject new_bullet;
        if(used_bullets.Count <= 0){
            new_bullet = GameObject.Instantiate<GameObject>(bullet) as GameObject;
            current_bullets.Add(new_bullet);
            new_bullet.transform.position = new Vector3(Random.Range(-100, 100), 0, Random.Range(-100, 100));
        } else {
            new_bullet = used_bullets[0];
            used_bullets.RemoveAt(0);
            current_bullets.Add(new_bullet);
        }
        new_bullet.GetComponent<Bullet>().setTankType(type);
        new_bullet.SetActive(true);
        return new_bullet;
    }

    public ParticleSystem getParticleSystem()
    {
        foreach(var particle in particles)
        {
            if (!particle.isPlaying)
            {
                return particle;
            }
        }
        ParticleSystem newPS = GameObject.Instantiate<ParticleSystem>(explosion);
        particles.Add(newPS);
        return newPS;
    }

    public void recycleEnemy(GameObject enemyTank) {
        current_tanks.Remove(enemyTank);
        dead_tanks.Add(enemyTank);
        enemyTank.GetComponent<Rigidbody>().velocity = Vector3.zero;
        enemyTank.SetActive(false);
    }

    public void recycleBullet(GameObject Bullet) {
        current_bullets.Remove(Bullet);
        used_bullets.Add(Bullet);
        Bullet.GetComponent<Rigidbody>().velocity = Vector3.zero;
        Bullet.SetActive(false);
    }
}
