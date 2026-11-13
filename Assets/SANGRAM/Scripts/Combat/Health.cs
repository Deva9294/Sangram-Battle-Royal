using UnityEngine;
using UnityEngine.Events;

public class Health : MonoBehaviour
{
    public float maxHealth = 100f;
    public UnityEvent onDeath;
    public float Current { get; private set; }

    private void Awake() => Current = maxHealth;

    public void TakeDamage(float amount)
    {
        if (Current <= 0f) return;
        Current = Mathf.Max(0f, Current - Mathf.Max(0f, amount));
        if (Current <= 0f)
        {
            onDeath?.Invoke();
            if (CompareTag("Enemy")) Destroy(gameObject, 1.5f);
        }
    }

    public void Heal(float amount)
    {
        if (Current > 0f) Current = Mathf.Min(maxHealth, Current + Mathf.Max(0f, amount));
    }
}
