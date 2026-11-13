using UnityEngine;

public class SafeZonePrototype : MonoBehaviour
{
    public Vector3 center;
    public float radius = 65f;
    public float shrinkPerSecond = 0.15f;
    public float outsideDamagePerSecond = 4f;
    public float minRadius = 12f;

    private void Update()
    {
        radius = Mathf.Max(minRadius, radius - shrinkPerSecond * Time.deltaTime);
        foreach (Health health in FindObjectsOfType<Health>())
        {
            if (Vector3.Distance(health.transform.position, center) > radius)
                health.TakeDamage(outsideDamagePerSecond * Time.deltaTime);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = new Color(0.1f, 0.65f, 1f, 0.8f);
        Gizmos.DrawWireSphere(center, radius);
    }
}
