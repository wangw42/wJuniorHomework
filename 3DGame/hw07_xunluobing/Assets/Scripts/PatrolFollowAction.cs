using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PatrolFollowAction : Action
{
    private float speed = 1.5f;          
    private GameObject player;           
    private PatrolData data;            

    public static PatrolFollowAction GetAction(GameObject player) {
        PatrolFollowAction action = CreateInstance<PatrolFollowAction>();
        action.player = player;
        return action;
    }

    public override void Start() {
        data = this.gameObject.GetComponent<PatrolData>();
    }

    public override void Update() {
        if (Director.GetInstance().CurrentSceneController.getGameState().Equals(GameState.RUNNING)) {
            transform.position = Vector3.MoveTowards(this.transform.position, player.transform.position, speed * Time.deltaTime);
            this.transform.LookAt(player.transform.position);
            if (data.isFollowing && (!(data.isPlayerInRange && data.patrolRegion == data.playerRegion) || data.isCollided)) {
                this.destroy = true;
                this.enable = false;
                this.callback.ActionEvent(this);
                this.gameObject.GetComponent<PatrolData>().isFollowing = false;
                Singleton<GameEventManager>.Instance.PlayerEscape(this.gameObject);
            }
        }
    }
}
