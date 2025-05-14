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

    public float currentDistance = 0.0f;

    private Transform target;
    private Quaternion startRotation;
    private Vector3 startPosition;
    private float totalDollyDistance;

    void Start()
    {
        /*Vector3 angles = transform.eulerAngles;
        x = angles.y;
        y = angles.x;*/

        if (target == null)
        {
            target = GetComponent<Transform>();
        }

        startRotation = this.transform.rotation;

        startPosition = this.transform.position;
        currentDistance = 0.0f;

        totalDollyDistance = Mathf.Abs(minDolly) + Mathf.Abs(maxDolly);
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
    }

    [ContextMenu("Reset")]
    private void Reset()
    {
        transform.Translate(startPosition - transform.position);
        transform.rotation = startRotation;
        currentDistance = 0.0f;
    }
}