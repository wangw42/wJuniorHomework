using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PatrolActionManager : ActionManager, ActionCallback
{
    public PatrolAction patrol;
    public PatrolFollowAction follow;

    public void Patrol(GameObject ptrl) {
        this.patrol = PatrolAction.GetAction(ptrl.transform.position);
        this.RunAction(ptrl, patrol, this);
    }

    public void Follow(GameObject player, GameObject patrol) {
        this.follow = PatrolFollowAction.GetAction(player);
        this.RunAction(patrol, follow, this);
    }

    public void DestroyAllActions() {
        DestroyAll();
    }

    public void ActionEvent(Action source, ActionEventType events = ActionEventType.Completed, int intParam = 0, string strParam = null, object objectParam = null){ }
}
