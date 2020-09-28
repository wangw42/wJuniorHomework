using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UserGUI : MonoBehaviour {
	private UserAction action;
	public int status = 0;
	GUIStyle style;
	GUIStyle buttonStyle;

	void Start() {
		action = mainController.getInstance ().currentSceneController as UserAction;

		style = new GUIStyle();
		style.fontSize = 40;
		style.alignment = TextAnchor.MiddleCenter;

		buttonStyle = new GUIStyle("button");
		buttonStyle.fontSize = 30;
	}

	void OnGUI() {
		if (status == 1) {
			GUI.Label(new Rect(Screen.width/2-50, Screen.height/2-85, 100, 50), "Gameover!", style);
			if (GUI.Button(new Rect(Screen.width/2-70, Screen.height/2, 140, 70), "Restart", buttonStyle)) {
				status = 0;
				action.restart ();
			}
		} else if(status == 2) {
			GUI.Label(new Rect(Screen.width/2-50, Screen.height/2-85, 100, 50), "You win!", style);
			if (GUI.Button(new Rect(Screen.width/2-70, Screen.height/2, 140, 70), "Restart", buttonStyle)) {
				status = 0;
				action.restart ();
			}
		}
	}
}

public class mainController : System.Object {
	private static mainController _instance;
	public SceneController currentSceneController { get; set; }

	public static mainController getInstance() {
		if (_instance == null) {
			_instance = new mainController ();
		}
		return _instance;
	}
}

public interface SceneController {
	void loadResources ();
}

public interface UserAction {
	void moveBoat();
	void characterIsClicked(charController characterCtrl);
	void restart();
}

public class moveController: MonoBehaviour {
	
	float move_speed = 50;
	int movePos;	
	Vector3 dest;
	Vector3 middle;

	void Update() {
		//dest 2 <- 1 <- 0 start
		if (movePos == 1) {
			transform.position = Vector3.MoveTowards (transform.position, middle, move_speed * Time.deltaTime);
			if (transform.position == middle) {
				movePos = 2;
			}
		} else if (movePos == 2) {
			transform.position = Vector3.MoveTowards (transform.position, dest, move_speed * Time.deltaTime);
			if (transform.position == dest) {
				movePos = 0;
			}
		}
	}
	
	public void setDestination(Vector3 _dest) {
		dest = _dest;
		middle = _dest;
		if (_dest.y == transform.position.y) {	
			movePos = 2;
		}
		else if (_dest.y < transform.position.y) {	
			middle.y = transform.position.y;
		} else {								
			middle.x = transform.position.x;
		}
		movePos = 1;
	}

	public void reset() {
		movePos = 0;
	}
}

public class clickController : MonoBehaviour {
	UserAction action;
	charController characterController;

	public void setController(charController characterCtrl) {
		characterController = characterCtrl;
	}

	void Start() {
		action = mainController.getInstance ().currentSceneController as UserAction;
	}

	void OnMouseDown() {
		if (gameObject.name == "boat") {
			action.moveBoat ();
		} else {
			action.characterIsClicked (characterController);
		}
	}
}

public class charController {
	GameObject character;
	moveController moveInstance;
	clickController clickController;
	int charType;	// 0->priest, 1->devil

	bool onBoat;
	CoastController coastController;


	public charController(string which_character) {	
		if (which_character == "priest") {
			character = Object.Instantiate (Resources.Load ("Perfabs/Priest", typeof(GameObject)), Vector3.zero, Quaternion.identity, null) as GameObject;
			charType = 0;
		} else {
			character = Object.Instantiate (Resources.Load ("Perfabs/Devil", typeof(GameObject)), Vector3.zero, Quaternion.identity, null) as GameObject;
			charType = 1;
		}
		moveInstance = character.AddComponent (typeof(moveController)) as moveController;

		clickController = character.AddComponent (typeof(clickController)) as clickController;
		clickController.setController (this);
	}

	public void setName(string name) {
		character.name = name;
	}

	public void setPosition(Vector3 pos) {
		character.transform.position = pos;
	}

	public void moveToPosition(Vector3 destination) {
		moveInstance.setDestination(destination);
	}

	public int getType() {	// 0->priest, 1->devil
		return charType;
	}

	public string getName() {
		return character.name;
	}

	public void getOnBoat(BoatController boatCtrl) {
		coastController = null;
		character.transform.parent = boatCtrl.getGameobj().transform;
		onBoat = true;
	}

	public void getOnCoast(CoastController coastCtrl) {
		coastController = coastCtrl;
		character.transform.parent = null;
		onBoat = false;
	}

	public bool isOnBoat() {
		return onBoat;
	}

	public CoastController getCoastController() {
		return coastController;
	}

	public void reset() {
		moveInstance.reset ();
		coastController = (mainController.getInstance ().currentSceneController as PriestsAndDevils).fromCoast;
		getOnCoast (coastController);
		setPosition (coastController.getEmptyPosition ());
		coastController.getOnCoast (this);
	}
}

public class CoastController {
	GameObject coast;
	Vector3 from_pos = new Vector3(9,1,0);
	Vector3 to_pos = new Vector3(-9,1,0);
	Vector3[] positions;
	int to_or_from;	// to->-1, from->1
	charController[] passengerPlaner;

	public CoastController(string _to_or_from) {
		positions = new Vector3[] {new Vector3(6.5F,2.25F,0), new Vector3(7.5F,2.25F,0), new Vector3(8.5F,2.25F,0), 
			new Vector3(9.5F,2.25F,0), new Vector3(10.5F,2.25F,0), new Vector3(11.5F,2.25F,0)};

			passengerPlaner = new charController[6];

			if (_to_or_from == "from") {
				coast = Object.Instantiate (Resources.Load ("Perfabs/Stone", typeof(GameObject)), from_pos, Quaternion.identity, null) as GameObject;
				coast.name = "from";
				to_or_from = 1;
			} else {
				coast = Object.Instantiate (Resources.Load ("Perfabs/Stone", typeof(GameObject)), to_pos, Quaternion.identity, null) as GameObject;
				coast.name = "to";
				to_or_from = -1;
			}
		}

		public int getEmptyIndex() {
			for (int i = 0; i < passengerPlaner.Length; i++) {
				if (passengerPlaner [i] == null) {
					return i;
				}
			}
			return -1;
		}

		public Vector3 getEmptyPosition() {
			Vector3 pos = positions [getEmptyIndex ()];
			pos.x *= to_or_from;
			return pos;
		}

		public void getOnCoast(charController characterCtrl) {
			int index = getEmptyIndex ();
			passengerPlaner [index] = characterCtrl;
		}

	public charController getOffCoast(string passenger_name) {	// 0->priest, 1->devil
		for (int i = 0; i < passengerPlaner.Length; i++) {
			if (passengerPlaner [i] != null && passengerPlaner [i].getName () == passenger_name) {
				charController charactorCtrl = passengerPlaner [i];
				passengerPlaner [i] = null;
				return charactorCtrl;
			}
		}
		Debug.Log ("cant find passenger on coast: " + passenger_name);
		return null;
	}

	public int get_to_or_from() {
		return to_or_from;
	}
	public int[] getCharacterNum() {
		int[] count = {0, 0};
		for (int i = 0; i < passengerPlaner.Length; i++) {
			if (passengerPlaner [i] == null)
			continue;
			if (passengerPlaner [i].getType () == 0) {	// 0->priest, 1->devil
				count[0]++;
			} else {
				count[1]++;
			}
		}
		return count;
	}

	public void reset() {
		passengerPlaner = new charController[6];
	}
}

public class BoatController {
	GameObject boat;
	moveController moveInstance;
	Vector3 fromPosition = new Vector3 (5, 1, 0);
	Vector3 toPosition = new Vector3 (-5, 1, 0);
	Vector3[] from_positions;
	Vector3[] to_positions;
	int to_or_from; // to->-1; from->1
	charController[] passenger = new charController[2];

	public BoatController() {
		to_or_from = 1;

		from_positions = new Vector3[] { new Vector3 (4.5F, 1.5F, 0), new Vector3 (5.5F, 1.5F, 0) };
		to_positions = new Vector3[] { new Vector3 (-5.5F, 1.5F, 0), new Vector3 (-4.5F, 1.5F, 0) };

		boat = Object.Instantiate (Resources.Load ("Perfabs/Boat", typeof(GameObject)), fromPosition, Quaternion.identity, null) as GameObject;
		boat.name = "boat";

		moveInstance = boat.AddComponent (typeof(moveController)) as moveController;
		boat.AddComponent (typeof(clickController));
	}


	public void Move() {
		if (to_or_from == -1) {
			moveInstance.setDestination(fromPosition);
			to_or_from = 1;
		} else {
			moveInstance.setDestination(toPosition);
			to_or_from = -1;
		}
	}

	public int getEmptyIndex() {
		for (int i = 0; i < passenger.Length; i++) {
			if (passenger [i] == null) {
				return i;
			}
		}
		return -1;
	}

	public bool isEmpty() {
		for (int i = 0; i < passenger.Length; i++) {
			if (passenger [i] != null) {
				return false;
			}
		}
		return true;
	}

	public Vector3 getEmptyPosition() {
		Vector3 pos;
		int emptyIndex = getEmptyIndex ();
		if (to_or_from == -1) {
			pos = to_positions[emptyIndex];
		} else {
			pos = from_positions[emptyIndex];
		}
		return pos;
	}

	public void GetOnBoat(charController characterCtrl) {
		int index = getEmptyIndex ();
		passenger [index] = characterCtrl;
	}

	public charController GetOffBoat(string passenger_name) {
		for (int i = 0; i < passenger.Length; i++) {
			if (passenger [i] != null && passenger [i].getName () == passenger_name) {
				charController charactorCtrl = passenger [i];
				passenger [i] = null;
				return charactorCtrl;
			}
		}
		return null;
	}

	public GameObject getGameobj() {
		return boat;
	}

	public int get_to_or_from() { 
		return to_or_from;
	}

	public int[] getCharacterNum() {
		int[] count = {0, 0};
		for (int i = 0; i < passenger.Length; i++) {
			if (passenger [i] == null)
			continue;
			if (passenger [i].getType () == 0) {	
				count[0]++;
			} else {
				count[1]++;
			}
		}
		return count;
	}

	public void reset() {
		moveInstance.reset ();
		if (to_or_from == -1) {
			Move ();
		}
		passenger = new charController[2];
	}
}

public class PriestsAndDevils : MonoBehaviour, SceneController, UserAction {

	readonly Vector3 water_pos = new Vector3(0,0.5F,0);


	UserGUI userGUI;

	public CoastController fromCoast;
	public CoastController toCoast;
	public BoatController boat;
	private charController[] characters;

	void Awake() {
		mainController director = mainController.getInstance ();
		director.currentSceneController = this;
		userGUI = gameObject.AddComponent <UserGUI>() as UserGUI;
		characters = new charController[6];
		loadResources ();
	}

	public void loadResources() {
		GameObject water = Instantiate (Resources.Load ("Perfabs/Water", typeof(GameObject)), water_pos, Quaternion.identity, null) as GameObject;
		water.name = "water";

		fromCoast = new CoastController ("from");
		toCoast = new CoastController ("to");
		boat = new BoatController ();

		loadCharacter ();
	}

	private void loadCharacter() {
		for (int i = 0; i < 3; i++) {
			charController cha = new charController ("priest");
			cha.setName("priest" + i);
			cha.setPosition (fromCoast.getEmptyPosition ());
			cha.getOnCoast (fromCoast);
			fromCoast.getOnCoast (cha);

			characters [i] = cha;
		}

		for (int i = 0; i < 3; i++) {
			charController cha = new charController ("devil");
			cha.setName("devil" + i);
			cha.setPosition (fromCoast.getEmptyPosition ());
			cha.getOnCoast (fromCoast);
			fromCoast.getOnCoast (cha);

			characters [i+3] = cha;
		}
	}


	public void moveBoat() {
		if (boat.isEmpty ())
		return;
		boat.Move ();
		userGUI.status = check_game_over ();
	}

	public void characterIsClicked(charController characterCtrl) {
		if (characterCtrl.isOnBoat ()) {
			CoastController whichCoast;
			if (boat.get_to_or_from () == -1) { // to->-1; from->1
				whichCoast = toCoast;
			} else {
				whichCoast = fromCoast;
			}

			boat.GetOffBoat (characterCtrl.getName());
			characterCtrl.moveToPosition (whichCoast.getEmptyPosition ());
			characterCtrl.getOnCoast (whichCoast);
			whichCoast.getOnCoast (characterCtrl);

		} else {									// character on coast
			CoastController whichCoast = characterCtrl.getCoastController ();

			if (boat.getEmptyIndex () == -1) {		// boat is full
				return;
			}

			if (whichCoast.get_to_or_from () != boat.get_to_or_from ())	// boat is not on the side of character
			return;

			whichCoast.getOffCoast(characterCtrl.getName());
			characterCtrl.moveToPosition (boat.getEmptyPosition());
			characterCtrl.getOnBoat (boat);
			boat.GetOnBoat (characterCtrl);
		}
		userGUI.status = check_game_over ();
	}

	int check_game_over() {	// 0->not finish, 1->lose, 2->win
		int from_priest = 0;
		int from_devil = 0;
		int to_priest = 0;
		int to_devil = 0;

		int[] fromCount = fromCoast.getCharacterNum ();
		from_priest += fromCount[0];
		from_devil += fromCount[1];

		int[] toCount = toCoast.getCharacterNum ();
		to_priest += toCount[0];
		to_devil += toCount[1];

		if (to_priest + to_devil == 6)		// win
		return 2;

		int[] boatCount = boat.getCharacterNum ();
		if (boat.get_to_or_from () == -1) {	// boat at toCoast
			to_priest += boatCount[0];
			to_devil += boatCount[1];
		} else {	// boat at fromCoast
			from_priest += boatCount[0];
			from_devil += boatCount[1];
		}
		if (from_priest < from_devil && from_priest > 0) {		// lose
			return 1;
		}
		if (to_priest < to_devil && to_priest > 0) {
			return 1;
		}
		return 0;			// not finish
	}

	public void restart() {
		boat.reset ();
		fromCoast.reset ();
		toCoast.reset ();
		for (int i = 0; i < characters.Length; i++) {
			characters [i].reset ();
		}
	}
}
