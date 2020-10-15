using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 动作基类
public class SSAction : ScriptableObject {

    public bool enable = true;                      
    public bool destroy = false;                    

    public GameObject gameobject;                  
    public Transform transform;                     
    public ISSActionCallback callback;          

    protected SSAction() { }                     

    public virtual void Start() {                   
        throw new System.NotImplementedException();
    }

    public virtual void Update() {
        throw new System.NotImplementedException();
    }
}

// 动作管理基类
public class SSActionManager : MonoBehaviour, ISSActionCallback  {

    private Dictionary<int, SSAction> actions = new Dictionary<int, SSAction>();   
    private List<SSAction> waitingAdd = new List<SSAction>();                       
    private List<int> waitingDelete = new List<int>();                                           

    protected void Update() {
        foreach (SSAction ac in waitingAdd) {
            actions[ac.GetInstanceID()] = ac;                                     
        }
        waitingAdd.Clear();

        foreach (KeyValuePair<int, SSAction> kv in actions) {
            SSAction ac = kv.Value;
            if (ac.destroy) {
                waitingDelete.Add(ac.GetInstanceID());
            } else if (ac.enable) {
                ac.Update();
            }
        }

        foreach (int key in waitingDelete) {
            SSAction ac = actions[key];
            actions.Remove(key);
            Destroy(ac);
        }
        waitingDelete.Clear();
    }

    public void RunAction(GameObject gameobject, SSAction action, ISSActionCallback manager) {
        action.gameobject = gameobject;
        action.transform = gameobject.transform;
        action.callback = manager;
        waitingAdd.Add(action);
        action.Start();
    }

    public void SSActionEvent(SSAction source, SSActionEventType events = SSActionEventType.Competeted,
        int intParam = 0, string strParam = null, Object objectParam = null) {

    }
}

// 简单动作实现
public class CCMoveToAction : SSAction{
    public Vector3 target;       
    public float speed;          

    private CCMoveToAction() { }
    public static CCMoveToAction GetSSAction(Vector3 target, float speed) {
        CCMoveToAction action = ScriptableObject.CreateInstance<CCMoveToAction>();
        action.target = target;
        action.speed = speed;
        return action;
    }

    public override void Update() {
        this.transform.position = Vector3.MoveTowards(this.transform.position, target, speed * Time.deltaTime);
        if (this.transform.position == target) {
            this.destroy = true;
            this.callback.SSActionEvent(this); 
        }
    }

    public override void Start() {
    }
}

// 顺序动作组合实现
public class SequenceAction : SSAction, ISSActionCallback{
    public List<SSAction> sequence;    
    public int repeat = -1;           
    public int start = 0;             

    public static SequenceAction GetSSAcition(int repeat, int start, List<SSAction> sequence) {
        SequenceAction action = ScriptableObject.CreateInstance<SequenceAction>();
        action.repeat = repeat;
        action.sequence = sequence;
        action.start = start;
        return action;
    }

    public override void Update() {
        if (sequence.Count == 0) 
            return;
        if (start < sequence.Count)
            sequence[start].Update();     
    }

    public void SSActionEvent(SSAction source, SSActionEventType events = SSActionEventType.Competeted,
        int intParam = 0, string strParam = null, Object objectParam = null) {
        source.destroy = false;          
        this.start++;
        if (this.start >= sequence.Count) {
            this.start = 0;
            if (repeat > 0) 
                repeat--;
            if (repeat == 0) {
                this.destroy = true;               
                this.callback.SSActionEvent(this); 
            }
        }
    }

    public override void Start() {
        foreach (SSAction action in sequence) {
            action.gameobject = this.gameobject;
            action.transform = this.transform;
            action.callback = this;              
            action.Start();
        }
    }

    void OnDestroy()  {
    }
}

// ISSActionCallback接口
public enum SSActionEventType : int { Started, Competeted }
public interface ISSActionCallback{
    void SSActionEvent(SSAction source, SSActionEventType events = SSActionEventType.Competeted,
        int intParam = 0, string strParam = null, Object objectParam = null);
}

// 场景管理
public class SceneActionManager : SSActionManager{

    private CCMoveToAction moveBoatToEndOrStart;     
    private SequenceAction moveRoleToLandorBoat;     

    public Controller sceneController;

    protected void Start() {
        sceneController = (Controller)SSDirector.GetInstance().CurrentScenceController;
        sceneController.actionManager = this;
    }
    public void moveBoat(GameObject boat, Vector3 target, float speed) {
        moveBoatToEndOrStart = CCMoveToAction.GetSSAction(target, speed);
        this.RunAction(boat, moveBoatToEndOrStart, this);
    }

    public void moveRole(GameObject role, Vector3 middle_pos, Vector3 end_pos, float speed) {
        SSAction action1 = CCMoveToAction.GetSSAction(middle_pos, speed);
        SSAction action2 = CCMoveToAction.GetSSAction(end_pos, speed);
        moveRoleToLandorBoat = SequenceAction.GetSSAcition(1, 0, new List<SSAction> { action1, action2 });
        this.RunAction(role, moveRoleToLandorBoat, this);
    }
}

