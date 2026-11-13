using UnityEngine;

public class ThirdPersonCameraRig : MonoBehaviour
{
    public Transform target;
    public Vector3 offset = new Vector3(0f, 2.4f, -4.5f);
    public float followSharpness = 12f;

    private void LateUpdate()
    {
        if (target == null) return;
        Vector3 desired = target.position + target.rotation * offset;
        transform.position = Vector3.Lerp(transform.position, desired,
            1f - Mathf.Exp(-followSharpness * Time.deltaTime));
        // Rotation is owned by ThirdPersonController so mouse/touch look is not overwritten.
    }
}
