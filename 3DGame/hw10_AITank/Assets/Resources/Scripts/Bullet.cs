using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour {
    public float explosionRadius = 3.0f;
    private TankType tank_type;


    public void setTankType(TankType type)
    {
        tank_type = type;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if(collision.transform.gameObject.tag == "tankEnemy" && this.tank_type == TankType.ENEMY ||
            collision.transform.gameObject.tag == "tankPlayer" && this.tank_type == TankType.PLAYER)
            return;
        
        MyFactory factory = Singleton<MyFactory>.Instance;
        ParticleSystem explosion = factory.getParticleSystem();
        explosion.transform.position = gameObject.transform.position;
        
        Collider[] colliders = Physics.OverlapSphere(gameObject.transform.position, explosionRadius);
        
        foreach(var collider in colliders)
        {

            float distance = Vector3.Distance(collider.transform.position, gameObject.transform.position);
            float damage;

            if (collider.tag == "tankEnemy" && this.tank_type == TankType.PLAYER)
            {
                damage = 1.0f;
                collider.GetComponent<Tank>().setHP(collider.GetComponent<Tank>().getHP() - damage);
            }
            else if(collider.tag == "tankPlayer" && this.tank_type == TankType.ENEMY)
            {
                damage = 1.0f;
                collider.GetComponent<Tank>().setHP(collider.GetComponent<Tank>().getHP() - damage);
            }
            explosion.Play();
        }

        if (gameObject.activeSelf)
        {
            factory.recycleBullet(gameObject);
        }
    }

}
