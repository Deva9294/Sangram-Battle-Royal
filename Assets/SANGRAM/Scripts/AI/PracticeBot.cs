using UnityEngine;

public class PracticeBot : MonoBehaviour
{
    public Transform target;
    public float moveSpeed = 1.8f;
    public float attackDistance = 12f;
    public float damage = 8f;
    public float attackInterval = 1.4f;
    private float nextAttack;

    private void Update()
    {
        if (target == null)
        {
            ThirdPersonController player = FindObjectOfType<ThirdPersonController>();
            if (player != null) target = player.transform;
        }
        if (target == null) return;

        Vector3 delta = target.position - transform.position;
        delta.y = 0f;
        if (delta.sqrMagnitude > 0.1f)
            transform.rotation = Quaternion.Slerp(transform.rotation,
                Quaternion.LookRotation(delta), 4f * Time.deltaTime);

        if (delta.magnitude > 3f)
            transform.position += transform.forward * moveSpeed * Time.deltaTime;
        else if (Time.time >= nextAttack)
        {
            nextAttack = Time.time + attackInterval;
            Health health = target.GetComponent<Health>();
            if (health != null) health.TakeDamage(damage);
        }
    }
}
