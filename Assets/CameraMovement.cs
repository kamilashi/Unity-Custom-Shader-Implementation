using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.ProBuilder;
using static UnityEngine.GraphicsBuffer;

public class CameraMovement : MonoBehaviour
{
    public float maxYawClose = 45.0f;
    public float maxPitchClose = 20.0f;

    public float maxYawFar = 5.0f;
    public float maxPitchFar = 5.0f;

    public float rotationSpeed = 5f;

    public float dollySpeed = 0.0001f;
    public float minDolly = -5.0f;
    public float maxDolly = 5.0f;

    private float currentDistance = 0.0f;

    private Transform target;
    private Quaternion startRotation;
    private Vector3 startPosition;
    private float totalDollyDistance;

    private bool isUiHidden = false;
    private GUIStyle labelStyle;

    void Start()
    {
        labelStyle = new GUIStyle();
        labelStyle.normal.textColor = Color.black; // Set your desired font color here

        if (target == null)
        {
            target = GetComponent<Transform>();
        }

        startRotation = this.transform.rotation;

        startPosition = this.transform.position;
        currentDistance = 0.0f;

        totalDollyDistance = Mathf.Abs(minDolly) + Mathf.Abs(maxDolly);

        QualitySettings.vSyncCount = 0; 
        Application.targetFrameRate = 60; 
    }

    void Update()
    {
        Vector2 screenCenter = new Vector2(Screen.width / 2f, Screen.height / 2f);
        Vector2 mouseOffset = (Vector2)Mouse.current.position.ReadValue() - screenCenter;

        // Normalize to -1 to 1
        float normX = Mathf.Clamp(mouseOffset.x / screenCenter.x, -1f, 1f);
        float normY = Mathf.Clamp(mouseOffset.y / screenCenter.y, -1f, 1f);

        // Convert to target angles
        float lerpValue = Mathf.Abs(currentDistance - minDolly) / totalDollyDistance; // 0 - fully zoomed out, 1 - fully zoomed in
        float yaw = normX * Mathf.Lerp(maxYawFar, maxYawClose, lerpValue);
        float pitch = normY * Mathf.Lerp(maxPitchFar, maxPitchClose, lerpValue);

        // Build target rotation from offsets
        Quaternion targetRotation = Quaternion.Euler(pitch, yaw, 0f) * startRotation;

        // Smoothly rotate camera
        transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, Time.deltaTime * rotationSpeed);

        float dollyDirection = Keyboard.current.wKey.IsPressed() ? 1.0f : Keyboard.current.sKey.IsPressed() ? -1.0f : 0.0f;
        float newDistance = currentDistance;

        if (dollyDirection != 0.0f)
        {
            newDistance = newDistance + dollyDirection * dollySpeed * Time.deltaTime;

            newDistance = Mathf.Clamp(newDistance, minDolly, maxDolly);


            if (newDistance != currentDistance) 
            {
                transform.Translate(0f, 0f, newDistance - currentDistance, Space.Self);
                currentDistance = newDistance;
            }
        }

        if(Keyboard.current.hKey.wasPressedThisFrame)
        {
            isUiHidden = !isUiHidden;

            Cursor.visible = !isUiHidden;
        }
    }

    [ContextMenu("Reset")]
    private void Reset()
    {
        transform.position = startPosition;
        transform.rotation = startRotation;
        currentDistance = 0.0f;
    }

    [ExecuteAlways]
    private void OnGUI()
    {
        if(isUiHidden)
        {
            return;
        }

        float right_screen_offset = 40;
        float element_width = 170;
        float element_height = 30;
        float vertical_interval = 35;
        float screep_pos_y_from_top = 35;
        int ui_element_no = 0;
        float screen_width = Screen.width;

        if (GUI.Button(new Rect(screen_width - element_width - right_screen_offset, screep_pos_y_from_top + ui_element_no++ * vertical_interval, element_width, element_height), "Reset Camera"))
        {
            // call event
            Reset();
        }

        GUI.Label(new Rect(screen_width - element_width - right_screen_offset, screep_pos_y_from_top + ui_element_no++ * vertical_interval, element_width, element_height), "Press H to hide/unhide UI", labelStyle);

        GUI.Label(new Rect(screen_width - element_width - right_screen_offset, screep_pos_y_from_top + ui_element_no++ * vertical_interval, element_width, element_height), "Press W / S to dolly", labelStyle);
    }
}