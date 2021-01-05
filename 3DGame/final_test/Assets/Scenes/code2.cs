using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class code2 : MonoBehaviour
{
    public Transform CubeL;
    public Transform CubeS;
    //public Button button;

    private bool state = false;
    // Start is called before the first frame update
    void Start()
    {
        CubeL.position = new Vector3(0, 2, 0);
        CubeS.position = new Vector3(2, 2, 0);

        Button button = this.GetComponent<Button>();
        button.onClick.AddListener(delegate () {
            this.clickButton();
        });

    }

    // Update is called once per frame
    void Update()
    {
        CubeL.Rotate(Vector3.up * 20 * Time.deltaTime);
        if (state == true)
        {
            
            CubeS.RotateAround(CubeL.position, Vector3.up, 25.5f * Time.deltaTime);
        }
        
    }

    public void clickButton()
    {
        if (state == false)
        {
            state = true;
            Debug.Log(state);
        }else if (state == true)
        {
            state = false;
            Debug.Log(state);
        }
    }
}
