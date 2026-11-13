using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class ThirdPersonController : MonoBehaviour
{
    public Transform cameraTransform;
    public float walkSpeed = 4.5f;
    public float sprintSpeed = 7f;
    public float jumpHeight = 1.25f;
    public float gravity = -22f;
    public float lookSensitivity = 2.2f;

    private CharacterController controller;
    private float verticalVelocity;
    private float yaw;
    private float pitch;

    private void Awake()
    {
        controller = GetComponent<CharacterController>();
        yaw = transform.eulerAngles.y;
    }

    private void Update()
    {
        if (cameraTransform == null && Camera.main != null)
            cameraTransform = Camera.main.transform;

        HandleLook();
        HandleMovement();
        SangramMobileInput.ResetFrameInput();
    }

    private void HandleLook()
    {
        if (cameraTransform == null) return;
        Vector2 touchLook = SangramMobileInput.Look;
        yaw += Input.GetAxis("Mouse X") * lookSensitivity + touchLook.x;
        pitch = Mathf.Clamp(pitch - Input.GetAxis("Mouse Y") * lookSensitivity - touchLook.y, -25f, 65f);
        transform.rotation = Quaternion.Euler(0f, yaw, 0f);
        cameraTransform.rotation = Quaternion.Euler(pitch, yaw, 0f);
    }

    private void HandleMovement()
    {
        Vector2 inputMove = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
        if (SangramMobileInput.Move.sqrMagnitude > 0.001f) inputMove = SangramMobileInput.Move;
        float x = inputMove.x;
        float z = inputMove.y;
        Vector3 forward = cameraTransform
            ? Vector3.ProjectOnPlane(cameraTransform.forward, Vector3.up).normalized
            : transform.forward;
        Vector3 right = cameraTransform
            ? Vector3.ProjectOnPlane(cameraTransform.right, Vector3.up).normalized
            : transform.right;
        Vector3 move = Vector3.ClampMagnitude(forward * z + right * x, 1f);

        float speed = (Input.GetKey(KeyCode.LeftShift) || SangramMobileInput.Sprint) ? sprintSpeed : walkSpeed;
        if (controller.isGrounded && verticalVelocity < 0f) verticalVelocity = -2f;
        if (controller.isGrounded && (Input.GetButtonDown("Jump") || SangramMobileInput.JumpPressed))
            verticalVelocity = Mathf.Sqrt(jumpHeight * -2f * gravity);

        verticalVelocity += gravity * Time.deltaTime;
        controller.Move((move * speed + Vector3.up * verticalVelocity) * Time.deltaTime);

        if (move.sqrMagnitude > 0.02f)
            transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(move), 14f * Time.deltaTime);
    }
}
