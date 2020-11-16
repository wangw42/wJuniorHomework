using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class FirstSceneController : MonoBehaviour, SceneController, UserAction{
    public PatrolActionManager patrolActionManager;                
    public PatrolFactory patrolFactory;    

    public UserGUI userGUI;

    public GameObject player;                                      
    public int playerRegion;                                       

    private List<GameObject> pigs;                                      

    private GameState gameState = GameState.START;               
    private List<GameObject> patrols;                              

    public int score; 

    void Start() {
        score = 0;
        Director director = Director.GetInstance();
        director.CurrentSceneController = this;
        
        patrolFactory = Singleton<PatrolFactory>.Instance;
        playerRegion = 5;
        patrolActionManager = gameObject.AddComponent<PatrolActionManager>();
        userGUI = gameObject.AddComponent<UserGUI>() as UserGUI;
        director.SetFPS(30);
        director.leaveSeconds = 60;
        LoadResources();

        for (int i = 0; i < patrols.Count; i++) {
            patrolActionManager.Patrol(patrols[i]);
        }
    }

    public void LoadResources() {
        Instantiate(Resources.Load<GameObject>("Prefabs/Plane"));
        player = Instantiate(Resources.Load("Prefabs/Player"), new Vector3(-1.5f, 0, -1.5f), Quaternion.identity) as GameObject;
        patrols = patrolFactory.GetPatrols();
        pigs = patrolFactory.GetPigs();

        Camera.main.GetComponent<CameraFollowAction>().player = player;
    }

    private void Update() {
        for (int i = 0; i < patrols.Count; i++) {
            patrols[i].GetComponent<PatrolData>().playerRegion = playerRegion;
        }
    }

    void OnEnable() {
        GameEventManager.OnGoalLost += OnGoalLost;
        GameEventManager.OnFollowing += OnFollowing;
        GameEventManager.GameOver += GameOver;
        GameEventManager.Win += Win;
    }

    void OnDisable() {
        GameEventManager.OnGoalLost -= OnGoalLost;
        GameEventManager.OnFollowing -= OnFollowing;
        GameEventManager.GameOver -= GameOver;
        GameEventManager.Win -= Win;
    }

    public void MovePlayer(float translationX, float translationZ) {
        if (translationX != 0 || translationZ != 0) {
            player.GetComponent<Animator>().SetBool("run", true);
        } else {
            player.GetComponent<Animator>().SetBool("run", false);
        }
        translationX *= Time.deltaTime;
        translationZ *= Time.deltaTime;
        
        player.transform.LookAt(new Vector3(player.transform.position.x + translationX, player.transform.position.y, player.transform.position.z + translationZ));
        if (translationX == 0)
            player.transform.Translate(0, 0, Mathf.Abs(translationZ) * 2);
        else if (translationZ == 0)
            player.transform.Translate(0, 0, Mathf.Abs(translationX) * 2);
        else
            player.transform.Translate(0, 0, Mathf.Abs(translationZ) + Mathf.Abs(translationX));

    }

    public void OnGoalLost(GameObject patrol) {
        patrolActionManager.Patrol(patrol);
        score++;
    }

    public void OnFollowing(GameObject patrol) {
        patrolActionManager.Follow(player, patrol);
    }

    public void GameOver() {
        gameState = GameState.LOSE;
        StopAllCoroutines();
        patrolFactory.PausePatrol();
        player.GetComponent<Animator>().SetTrigger("death");
        patrolActionManager.DestroyAllActions();
    }

    public void Win() {
        gameState = GameState.WIN;
        StopAllCoroutines();
        patrolFactory.PausePatrol();
    }

    public int GetScore() {
        return score;
    }

    public void Restart() {
        SceneManager.LoadScene("Scenes/Xunluobing");
    }

    public void Pause() {
        gameState = GameState.PAUSE;
        patrolFactory.PausePatrol();
        player.GetComponent<Animator>().SetBool("pause", true);
        StopAllCoroutines();
    }

    public void Begin() {
        gameState = GameState.RUNNING;
        patrolFactory.StartPatrol();
        player.GetComponent<Animator>().SetBool("pause", false);
        StartCoroutine(Director.GetInstance().CountDown());
    }

    public GameState getGameState() {
        return gameState;
    }

    public void setGameState(GameState gs) {
        gameState = gs;
    }

}
