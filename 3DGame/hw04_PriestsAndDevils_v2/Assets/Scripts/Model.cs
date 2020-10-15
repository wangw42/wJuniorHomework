using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface ISceneController{
    void LoadResources();
}

public interface IUserAction {
    void MoveBoat();                                   
    void Restart();                                    
    void MoveRole(RoleModel role);                     
    int Check();                                       
}

public class SSDirector : System.Object{
    private static SSDirector _instance;
    public ISceneController CurrentScenceController { get; set; }
    public static SSDirector GetInstance() {
        if (_instance == null) {
            _instance = new SSDirector();
        }
        return _instance;
    }
}


public class LandController{
    GameObject land;                                
    Vector3[] positions;                            
    int land_sign;                                
    RoleModel[] roles = new RoleModel[6];          

    public LandController(string land_mark) {
        positions = new Vector3[] {new Vector3(7, 2, 30), new Vector3(9, 2, 30), new Vector3(11, 2, 30),
            new Vector3(13, 2, 30), new Vector3(15, 2, 30), new Vector3(17, 2, 30)};
        if (land_mark == "start") {
            land = Object.Instantiate(Resources.Load("Prefabs/Land", typeof(GameObject)), new Vector3(12, 0, 30), Quaternion.identity) as GameObject;
            land_sign = 1;
        } else {
            land = Object.Instantiate(Resources.Load("Prefabs/Land", typeof(GameObject)), new Vector3(-12, 0, 30), Quaternion.identity) as GameObject;
            land_sign = -1;
        }
    }

    public int GetEmptyNumber() {
        for (int i = 0; i < roles.Length; i++) {
            if (roles[i] == null)
                return i;
        }
        return -1;
    }

    public int GetLandSign() { 
        return land_sign;
    }

    public Vector3 GetEmptyPosition() {
        Vector3 pos = positions[GetEmptyNumber()];
        pos.x = land_sign * pos.x;                  
        return pos;
    }

    public void AddRole(RoleModel role) {
        roles[GetEmptyNumber()] = role;
    }

    public RoleModel DeleteRoleByName(string role_name) { 
        for (int i = 0; i < roles.Length; i++) {
            if (roles[i] != null && roles[i].GetName() == role_name) {
                RoleModel role = roles[i];
                roles[i] = null;
                return role;
            }
        }
        return null;
    }

    public int[] GetObjectsNum() {
        //count[0]是牧师数，count[1]是魔鬼数
        int[] count = { 0, 0 };                    
        for (int i = 0; i < roles.Length; i++) {
            if (roles[i] != null) {
                if (roles[i].GetSign() == 0)
                    count[0]++;
                else
                    count[1]++;
            }
        }
        return count;
    }

    public void Reset() {
        roles = new RoleModel[6];
    }
}

public class BoatController{
    GameObject boat;                                          
    Vector3[] start_empty_pos;                                    // 船在开始陆地的空位位置
    Vector3[] end_empty_pos;                                      // 船在结束陆地的空位位置
    // Move move;                                                    
    Click click;
    int boat_sign = 1;                                            // 船在开始还是结束陆地(1-开始、-1-结束)
    RoleModel[] roles = new RoleModel[2];                        
    public float move_speed = 200;                               
    public GameObject getGameObject() {                         
        return boat; 
    }                     

    public BoatController(){
        boat = Object.Instantiate(Resources.Load("Prefabs/Boat", typeof(GameObject)), new Vector3(4, 0, 30), Quaternion.identity) as GameObject;
        boat.name = "boat";
        click = boat.AddComponent(typeof(Click)) as Click;
        click.SetBoat(this);
        start_empty_pos = new Vector3[] { new Vector3(5, 1, 30), new Vector3(3, 1, 30) };
        end_empty_pos = new Vector3[] { new Vector3(-3, 1, 30), new Vector3(-5, 1, 30) };
    }

    public bool IsEmpty() {
        for (int i = 0; i < roles.Length; i++) {
            if (roles[i] != null)
                return false;
        }
        return true;
    }

    public Vector3 BoatMoveToPosition() {   
        if (boat_sign == -1) {
            boat_sign = -boat_sign;  
            return new Vector3(4, 0, 30);  
        } else {
            boat_sign = -boat_sign;  
            return new Vector3(-4, 0, 30);
        }
    }

    public int GetBoatSign(){ 
        return boat_sign;
    }

    public RoleModel DeleteRoleByName(string role_name) {
        for (int i = 0; i < roles.Length; i++) {
            if (roles[i] != null && roles[i].GetName() == role_name) {
                RoleModel role = roles[i];
                roles[i] = null;
                return role;
            }
        }
        return null;
    }

    public int GetEmptyNumber() {
        for (int i = 0; i < roles.Length; i++) {
            if (roles[i] == null) {
                return i;
            }
        }
        return -1;
    }

    public Vector3 GetEmptyPosition() {
        Vector3 pos;
        if (boat_sign == -1)
            pos = end_empty_pos[GetEmptyNumber()];
        else
            pos = start_empty_pos[GetEmptyNumber()];
        return pos;
    }

    public void AddRole(RoleModel role) {
        roles[GetEmptyNumber()] = role;
    }

    public GameObject GetBoat(){ 
        return boat;
    }

    public int[] GetObjectsNum() {
        int[] count = { 0, 0 };
        for (int i = 0; i < roles.Length; i++) {
            if (roles[i] == null)
                continue;
            if (roles[i].GetSign() == 0)
                count[0]++;
            else
                count[1]++;
        }
        return count;
    }

    public void Reset() {    
        if (boat_sign == -1)
            BoatMoveToPosition();
        boat.transform.position = new Vector3 (4, 0, 30);
        roles = new RoleModel[2];
    }
}

public class RoleModel{
    GameObject role;
    int role_sign;             //0为牧师，1为恶魔
    Click click;
    bool on_boat;              
    LandController land_model = (SSDirector.GetInstance().CurrentScenceController as Controller).land_start;

    public float move_speed = 200;          
    public GameObject getGameObject() {     
        return role; 
    }     
    public RoleModel(string role_name) {
        if (role_name == "priest") {
            role = Object.Instantiate(Resources.Load("Prefabs/Priest", typeof(GameObject)), Vector3.zero, Quaternion.Euler(0, -90, 0)) as GameObject;
            role_sign = 0;
        } else {
            role = Object.Instantiate(Resources.Load("Prefabs/Devil", typeof(GameObject)), Vector3.zero, Quaternion.Euler(0, -90, 0)) as GameObject;
            role_sign = 1;
        }
        click = role.AddComponent(typeof(Click)) as Click;
        click.SetRole(this);
    }

    public int GetSign() { 
        return role_sign;
    }
    public LandController GetLandController(){
        return land_model;
    }
    public string GetName() { 
        return role.name;
    }
    public bool IsOnBoat() { 
        return on_boat;
    }
    public void SetName(string name) { 
        role.name = name;
    }
    public void SetPosition(Vector3 pos) { 
        role.transform.position = pos;
    }

    public void GoLand(LandController land) {  
        role.transform.parent = null;
        land_model = land;
        on_boat = false;
    }

    public void GoBoat(BoatController boat) {
        role.transform.parent = boat.GetBoat().transform;
        land_model = null;          
        on_boat = true;
    }

    public void Reset() {
        land_model = (SSDirector.GetInstance().CurrentScenceController as Controller).land_start;
        GoLand(land_model);
        SetPosition(land_model.GetEmptyPosition());
        land_model.AddRole(this);
    }
}

public class Click : MonoBehaviour{
    IUserAction action;
    RoleModel role = null;
    BoatController boat = null;
    public void SetRole(RoleModel role) {
        this.role = role;
    }
    public void SetBoat(BoatController boat) {
        this.boat = boat;
    }
    void Start() {
        action = SSDirector.GetInstance().CurrentScenceController as IUserAction;
    }
    void OnMouseDown() {
        if (boat == null && role == null) 
            return;
        if (boat != null)
            action.MoveBoat();
        else if(role != null)
            action.MoveRole(role);
    }
}

// 添加裁判类
public class Judgement{
    private LandController land_start;
    private LandController land_end;
    private BoatController boat; 

    public Judgement(LandController lstart, LandController lend, BoatController b) {
        this.land_start = lstart;
        this.land_end = lend;
        this.boat = b;
    }

    public int Check() {
        int start_priest = 0;
        int start_devil = 0;
        int end_priest = 0;
        int end_devil = 0;

        start_priest += (land_start.GetObjectsNum())[0];
        end_priest += (land_end.GetObjectsNum())[0];
        start_devil += (land_start.GetObjectsNum())[1];
        end_devil += (land_end.GetObjectsNum())[1];

        // win
        if (end_priest + end_devil == 6)        
            return 3;

        int[] boat_num = boat.GetObjectsNum();

        if (boat.GetBoatSign() == 1) {             // on destination
            start_priest += boat_num[0];
            start_devil += boat_num[1];
        } else {                                   // at start                               
            end_priest += boat_num[0];
            end_devil += boat_num[1];
        }

        // lose
        if ((start_priest > 0 && start_priest < start_devil) || (end_priest > 0 && end_priest < end_devil)) { //失败
            return 2;
        }
        // not finish
        return 1;                           
    }
}
