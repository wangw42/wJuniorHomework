using UnityEngine;
using System.Collections;
using System.Globalization;

public class Calculator : MonoBehaviour {

    private Rect calcSize = new Rect(360, 20, 220, 250);
    private float[] registers = new float[2];//2 registers
    private string currentNumber = "0";
    private int calcScreenFontSize = 27;
    private int operationFontSize = 15;
    private string currentOperationToPerform = "";
    private int maxDigits = 11;
    private bool isFirst = true;
    private bool shouldClearScreen = false;

    private string GetCalcInternalsInfo() {
        string info = "";
        info += "Screen: " + currentNumber + "\n";
        info += "Clear Screen?: " + shouldClearScreen + "\n"; 
        for(int i = 0; i < registers.Length; i++ ) {
            info += "Reg[" + i + "] <= " + registers[i] + "\n";
        }
        info += "Current op: " + currentOperationToPerform + "\n";
        info += "Register to use: " + (isFirst?"0":"1");

        return info;
    }



    void Update() {
        getInput();
    }


    void OnGUI() {
        calcSize = GUI.Window(0, calcSize, drawCalc, "Calculator");
    }
    void drawCalc(int windowID) {     
        GUI.Box(new Rect(20,20, calcSize.width-40, 43),"");
        int tmpSize = GUI.skin.GetStyle("Label").fontSize;
        GUI.skin.GetStyle("Label").fontSize = calcScreenFontSize;
        GUI.Label(new Rect(23,18,calcSize.width-40, 37), currentNumber);
        GUI.skin.GetStyle("Label").fontSize = tmpSize;

        tmpSize = GUI.skin.GetStyle("Label").fontSize;
        GUI.skin.GetStyle("Label").fontSize = operationFontSize;
        GUI.Label(new Rect(130,42,calcSize.width-42, 37), currentOperationToPerform);
        GUI.skin.GetStyle("Label").fontSize = tmpSize;
        
        if(GUI.Button(new Rect(8, 70, 47, 30), "C")) {
            clearCal();
        }
        if(GUI.Button(new Rect(61, 70, 47, 30), "+/-")) {
            if(currentNumber != "0") {
                if(currentNumber[0] != '-')
                    currentNumber = currentNumber.Insert(0,"-");
                else
                    currentNumber = currentNumber.Remove(0,1);
            }
        }

        if(GUI.Button(new Rect(165, 141, 47, 30), "+"))
            pressBut("+");
        if(GUI.Button(new Rect(165, 106, 47, 30), "-")) 
            pressBut("-");
        if(GUI.Button(new Rect(113, 70, 47, 30), "/")) 
            pressBut("/");
        if(GUI.Button(new Rect(165, 70, 47, 30), "x"))
            pressBut("x");
        
        if(GUI.Button(new Rect(8, 176, 47, 30), "1")) 
            addNum("1");
        if(GUI.Button(new Rect(61, 176, 47, 30), "2")) 
            addNum("2");
        if(GUI.Button(new Rect(113, 176, 47, 30), "3")) 
            addNum("3");
        if(GUI.Button(new Rect(8, 141, 47, 30), "4")) 
            addNum("4");                
        if(GUI.Button(new Rect(61, 141, 47, 30), "5")) 
            addNum("5");                
        if(GUI.Button(new Rect(113, 141, 47, 30), "6")) 
            addNum("6");
        if(GUI.Button(new Rect(8, 106, 47, 30), "7")) 
            addNum("7");
        if(GUI.Button(new Rect(61, 106, 47, 30), "8")) 
            addNum("8");
        if(GUI.Button(new Rect(113, 106, 47, 30), "9"))  
            addNum("9");
        if(GUI.Button(new Rect(8, 212, 100, 30), "0"))
            addNum("0");
        
        if(GUI.Button(new Rect(113, 212, 47, 30), ".")) {
            if(!currentNumber.Contains(".") || shouldClearScreen)
                addNum(".");
        }

        if(GUI.Button(new Rect(165, 176, 47, 66), "=")) {
            calculate();  
        }
        GUI.DragWindow();
    }

    private void pressBut(string op) {
        storeCur(0);
        isFirst = false;
        shouldClearScreen = true;
        currentOperationToPerform = op;
    }

    private void clearCal() {
        isFirst = true;
        shouldClearScreen = true;
        currentOperationToPerform = "";
        currentNumber = "0";
        for(int i = 0; i < registers.Length; i++)
            registers[i] = 0;
    }

    private void calculate() {
        switch(currentOperationToPerform) {
        case "+":
            if(currentNumber != "NaN")
                currentNumber = (registers[0] + registers[1]).ToString();
            break;
        case "-":
            if(currentNumber != "NaN")
                currentNumber = (registers[0] - registers[1]).ToString();
            break;
        case "x":
            if(currentNumber != "NaN")
                currentNumber = (registers[0] * registers[1]).ToString();
        break;
        case "/":
            if(currentNumber != "NaN")
                currentNumber = (registers[1] != 0) ? (registers[0] / registers[1]).ToString()   :   "NaN";
            break;
        case "":
            break;
        default:
            Debug.LogError("Unknown operation: " + currentOperationToPerform);
            break;
        }
        storeCur(0);
        isFirst = true;
        shouldClearScreen = true;
    }

    private void storeCur(int regNumber) {
        registers[regNumber] = float.Parse(currentNumber, CultureInfo.InvariantCulture.NumberFormat);
    }

    private void addNum(string s) {
        if((currentNumber == "0") || shouldClearScreen)
            currentNumber = (s == ".") ? "0." : s;
        else 
            if(currentNumber.Length < maxDigits)
                currentNumber += s;

        if(shouldClearScreen)
            shouldClearScreen = false;
        storeCur(isFirst ? 0 : 1);
    }

    private void getInput() {
        if(Input.GetKeyDown(KeyCode.Keypad0) || Input.GetKeyDown(KeyCode.Alpha0))
            addNum("0");
        if(Input.GetKeyDown(KeyCode.Keypad1) || Input.GetKeyDown(KeyCode.Alpha1))
            addNum("1");
        if(Input.GetKeyDown(KeyCode.Keypad2) || Input.GetKeyDown(KeyCode.Alpha2))
            addNum("2");
        if(Input.GetKeyDown(KeyCode.Keypad3) || Input.GetKeyDown(KeyCode.Alpha3))
            addNum("3");
        if(Input.GetKeyDown(KeyCode.Keypad4) || Input.GetKeyDown(KeyCode.Alpha4))
            addNum("4");
        if(Input.GetKeyDown(KeyCode.Keypad5) || Input.GetKeyDown(KeyCode.Alpha5))
            addNum("5");
        if(Input.GetKeyDown(KeyCode.Keypad6) || Input.GetKeyDown(KeyCode.Alpha6))
            addNum("6");
        if(Input.GetKeyDown(KeyCode.Keypad7) || Input.GetKeyDown(KeyCode.Alpha7))
            addNum("7");
        if(Input.GetKeyDown(KeyCode.Keypad8) || Input.GetKeyDown(KeyCode.Alpha8))
            addNum("8");
        if(Input.GetKeyDown(KeyCode.Keypad9) || Input.GetKeyDown(KeyCode.Alpha9))
            addNum("9");

        if(Input.GetKeyDown(KeyCode.C))
            clearCal();

        if(Input.GetKeyDown(KeyCode.KeypadPeriod) || Input.GetKeyDown(KeyCode.Period))
           if(!currentNumber.Contains(".") || shouldClearScreen)
               addNum(".");

        if(Input.GetKeyDown(KeyCode.KeypadDivide) || Input.GetKeyDown(KeyCode.Slash))
            pressBut("/");
        if(Input.GetKeyDown(KeyCode.KeypadMultiply) || Input.GetKeyDown(KeyCode.Asterisk))
            pressBut("*");
        if(Input.GetKeyDown(KeyCode.KeypadPlus) || Input.GetKeyDown(KeyCode.Plus))
            pressBut("+");
        if(Input.GetKeyDown(KeyCode.KeypadMinus) || Input.GetKeyDown(KeyCode.Minus))
            pressBut("-");

        if(Input.GetKeyDown(KeyCode.Return) || Input.GetKeyDown(KeyCode.KeypadEnter))
            calculate();
    }
}