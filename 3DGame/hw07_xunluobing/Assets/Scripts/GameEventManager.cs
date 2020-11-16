using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameEventManager : MonoBehaviour{
    public delegate void EscapeEvent(GameObject patrol);
    public static event EscapeEvent OnGoalLost;

    public delegate void FollowEvent(GameObject patrol);
    public static event FollowEvent OnFollowing;

    public delegate void GameOverEvent();
    public static event GameOverEvent GameOver;

    public delegate void WinEvent();
    public static event WinEvent Win;

    public void PlayerEscape(GameObject patrol) {
        if (OnGoalLost != null) {
            OnGoalLost(patrol);
        }
    }

    public void FollowPlayer(GameObject patrol) {
        if (OnFollowing != null) {
            OnFollowing(patrol);
        }
    }

    public void OnPlayerCatched() {
        if (GameOver != null) {
            GameOver();
        }
    }

    public void TimeIsUP() {
        if (Win != null) {
            Win();
        } 
    }
}
