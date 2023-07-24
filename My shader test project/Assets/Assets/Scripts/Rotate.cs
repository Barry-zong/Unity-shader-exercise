using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class Rotate : MonoBehaviour
{
    // Start is called before the first frame update
    public GameObject RotateObject;
    public float degPerSec = 60.0f;
    public bool ModelRotateON = false;
    public bool MDRotationReset = false;
    public bool LightRotateON = false;
    public bool LTRotationReset = false;

    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (ModelRotateON == true)
        {
            RotateObject.transform.Rotate(this.transform.up, degPerSec * Time.deltaTime);
        }
        if (LightRotateON == true) 
        { 
            LigRotate();
        }
        if (MDRotationReset == true)
        {
            LigResete();
        }
        if (LTRotationReset == true) 
        { 
            transform.transform.rotation = Quaternion.identity;
        }
    }
    public void LigRotate()
    {
       transform. Rotate(0,degPerSec*0.004f,0);
    }
    public void LigResete()
    {
       RotateObject.transform.rotation = Quaternion.identity;
    }
}
