using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Controller : MonoBehaviour, ISceneController, IUserAction{
    public LandController land_start;            
    public LandController land_end;              
    public BoatController boat;                  
    private Judgement Judgement;                 
    private RoleModel[] roles;             
    UserGUI user_gui;

    public SceneActionManager actionManager; 

    void Start () {
        SSDirector director = SSDirector.GetInstance();
        director.CurrentScenceController = this;
        user_gui = gameObject.AddComponent<UserGUI>() as UserGUI;
        LoadResources();

        actionManager = gameObject.AddComponent<SceneActionManager>() as SceneActionManager;    
    }
	
    public void LoadResources() {        
        GameObject water = Instantiate(Resources.Load("Prefabs/Water", typeof(GameObject)), new Vector3(0, -1, 30), Quaternion.identity) as GameObject;
        water.name = "water";       
        land_start = new LandController("start");
        land_end = new LandController("end");
        boat = new BoatController();
        roles = new RoleModel[6];

        for (int i = 0; i < 3; i++) {
            RoleModel role = new RoleModel("priest");
            role.SetName("priest" + i);
            role.SetPosition(land_start.GetEmptyPosition());
            role.GoLand(land_start);
            land_start.AddRole(role);
            roles[i] = role;
        }

        for (int i = 0; i < 3; i++) {
            RoleModel role = new RoleModel("devil");
            role.SetName("devil" + i);
            role.SetPosition(land_start.GetEmptyPosition());
            role.GoLand(land_start);
            land_start.AddRole(role);
            roles[i + 3] = role;
        }

        Judgement = new Judgement(land_start, land_end, boat);
    }

    public void MoveBoat() {               
        if (boat.IsEmpty() || user_gui.sign != 1) 
            return;
        actionManager.moveBoat(boat.getGameObject(), boat.BoatMoveToPosition(), boat.move_speed);
    }

    public void MoveRole(RoleModel role) {   
        if (user_gui.sign != 1) 
            return;

        if (role.IsOnBoat()) {              
            LandController land;
            if (boat.GetBoatSign() == -1)
                land = land_end;
            else
                land = land_start;
            boat.DeleteRoleByName(role.GetName());
            Vector3 end_pos = land.GetEmptyPosition();
            Vector3 middle_pos = new Vector3(role.getGameObject().transform.position.x, end_pos.y, end_pos.z);
            actionManager.moveRole(role.getGameObject(), middle_pos, end_pos, role.move_speed);
            
            role.GoLand(land);
            land.AddRole(role);
        } else {                      
            LandController land = role.GetLandController();
            if (boat.GetEmptyNumber() == -1 || land.GetLandSign() != boat.GetBoatSign()) 
                return;   

            land.DeleteRoleByName(role.GetName());
            Vector3 end_pos = boat.GetEmptyPosition();
            Vector3 middle_pos = new Vector3(end_pos.x, role.getGameObject().transform.position.y, end_pos.z);
            actionManager.moveRole(role.getGameObject(), middle_pos, end_pos, role.move_speed);
            
            role.GoBoat(boat);
            boat.AddRole(role);
        }

        user_gui.sign = Judgement.Check();
        if (user_gui.sign != 1) {
            Restart();
        }
    }

    public void Restart() {
        land_start.Reset();
        land_end.Reset();
        boat.Reset();
        for (int i = 0; i < 6; i++) {
            roles[i].Reset();
        }
    }

    public int Check() {
        return 1;
    }
}