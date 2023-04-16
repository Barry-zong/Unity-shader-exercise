using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    // Start is called before the first frame update
    public float degPerSec = 60.0f;
    public bool RotateON = false;

    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (RotateON == true)
        {
            transform.Rotate(this.transform.up, degPerSec * Time.deltaTime);
        }
    }
}
