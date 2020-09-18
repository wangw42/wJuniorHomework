using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
 
public class Calculator : MonoBehaviour {
 
    Button[] buttons;
    string content;
    public Text contentText;
    public Text board;
	void Start () {
        buttons = new Button[transform.childCount];
        Debug.Log(transform.childCount);
        for (int i = 0; i < buttons.Length; i++)
        {
            buttons[i] = transform.GetChild(i).GetComponent<Button>();
         
        }
        for (int i = 0; i < buttons.Length; i++)
        {
            int temp = i;
            buttons[i].onClick.AddListener(() => Button(buttons[temp]));
        } 
    }
 
    float a;
    float b;
    string oper = null;
    bool isopera = false;
    void Button(Button button)
    {
        board.text+= button.GetComponentInChildren<Text>().text;
 
        if (button.GetComponentInChildren<Text>().text != "+" &&
           button.GetComponentInChildren<Text>().text != "-" &&
           button.GetComponentInChildren<Text>().text != "*" &&
           button.GetComponentInChildren<Text>().text != "/" &&          
           button.GetComponentInChildren<Text>().text != "="&&
           button.GetComponentInChildren<Text>().text != "清空")
        {
           
            if (isopera)
            {
                content += button.GetComponentInChildren<Text>().text;
                contentText.text = content;
               
            }
            else
            {
                content = contentText.text += button.GetComponentInChildren<Text>().text;
            }
          
            
            
        }
        else
        {
            Debug.Log(111);
            if (button.GetComponentInChildren<Text>().text == "+")
            {
                a = float.Parse(content);
                oper = "+";
                isopera = true;
                content = null;
            }
            if (button.GetComponentInChildren<Text>().text == "-")
            {
                a = float.Parse(content);
                oper = "-";
                isopera = true;
                content = null;
            }
            if (button.GetComponentInChildren<Text>().text == "*")
            {
                a = float.Parse(content);
                isopera = true;
                oper = "*";
                content = null;
            }
            if (button.GetComponentInChildren<Text>().text == "/")
            {
                a = float.Parse(content);
                oper = "/";
                isopera = true;
                content = null;
            }
            if (button.GetComponentInChildren<Text>().text == "=")
            {
                contentText.text = null;
            
                b = float.Parse(content);
                if (oper=="+")
                {
                    contentText.text = (a + b).ToString();
                }
                if (oper == "-")
                {
                    contentText.text = (a - b).ToString();
                }
                if (oper == "*")
                {
                    contentText.text = (a * b).ToString();
                }
                if (oper == "/")
                {
                    contentText.text = (a / b).ToString();
                }
                isopera = false;
 
                board.text += contentText.text;
            }
 
            if (button.GetComponentInChildren<Text>().text == "清空")
            {
                oper = null;
                isopera = false;
                content = contentText.text = null;
                board.text = null;
            }
        }
    }
 
    void Update () {
	}
}