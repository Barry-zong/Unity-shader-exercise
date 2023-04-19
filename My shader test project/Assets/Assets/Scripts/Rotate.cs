using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
            transform. Rotate(0,degPerSec*0.004f,0);
        }
        if (MDRotationReset == true)
        {
            RotateObject.transform.rotation = Quaternion.identity;
        }
        if (LTRotationReset == true) 
        { 
            transform.transform.rotation = Quaternion.identity;
        }
    }
}
