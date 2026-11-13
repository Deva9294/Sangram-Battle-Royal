using System.Collections;
using UnityEngine;

public class WeaponController : MonoBehaviour
{
    public Camera aimCamera;
    public float damage = 25f;
    public float range = 120f;
    public float fireRate = 8f;
    public int magazineSize = 30;
    public int reserveAmmo = 120;
    public float reloadSeconds = 1.6f;

    private int ammo;
    private float nextShot;
    private bool reloading;

    private void Start()
    {
        ammo = magazineSize;
        if (aimCamera == null) aimCamera = Camera.main;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.R)) StartCoroutine(Reload());
        if (Input.GetButton("Fire1") && Time.time >= nextShot && !reloading) Fire();
    }

    private void Fire()
    {
        if (ammo <= 0)
        {
            if (reserveAmmo > 0) StartCoroutine(Reload());
            return;
        }

        ammo--;
        nextShot = Time.time + 1f / Mathf.Max(0.1f, fireRate);
        if (aimCamera == null) return;

        if (Physics.Raycast(aimCamera.transform.position, aimCamera.transform.forward,
            out RaycastHit hit, range))
        {
            Health health = hit.collider.GetComponentInParent<Health>();
            if (health != null) health.TakeDamage(damage);
        }
    }

    private IEnumerator Reload()
    {
        if (reloading || ammo == magazineSize || reserveAmmo <= 0) yield break;
        reloading = true;
        yield return new WaitForSeconds(reloadSeconds);
        int loaded = Mathf.Min(magazineSize - ammo, reserveAmmo);
        ammo += loaded;
        reserveAmmo -= loaded;
        reloading = false;
    }
}
