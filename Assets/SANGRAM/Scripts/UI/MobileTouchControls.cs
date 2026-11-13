using UnityEngine;
using UnityEngine.EventSystems;

// Shared touch state read by player and weapon scripts.
public static class SangramMobileInput
{
    public static Vector2 Move, Look;
    public static bool Sprint, JumpPressed, Fire, ReloadPressed;
    public static void ResetFrameInput() { Look = Vector2.zero; JumpPressed = false; ReloadPressed = false; }
}

public class MobileJoystick : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler
{
    public float radius = 70f;
    private RectTransform rect;
    private int pointerId = int.MinValue;
    private void Awake() { rect = transform as RectTransform; }
    public void OnPointerDown(PointerEventData e) { pointerId = e.pointerId; OnDrag(e); }
    public void OnDrag(PointerEventData e)
    {
        if (e.pointerId != pointerId || rect == null) return;
        Vector2 p;
        if (RectTransformUtility.ScreenPointToLocalPointInRectangle(rect, e.position, e.pressEventCamera, out p))
            SangramMobileInput.Move = Vector2.ClampMagnitude(p / Mathf.Max(1f, radius), 1f);
    }
    public void OnPointerUp(PointerEventData e) { if (e.pointerId == pointerId) { pointerId = int.MinValue; SangramMobileInput.Move = Vector2.zero; } }
}

public class MobileLookArea : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler
{
    public float sensitivity = .12f;
    private int pointerId = int.MinValue;
    private Vector2 previous;
    public void OnPointerDown(PointerEventData e) { pointerId = e.pointerId; previous = e.position; }
    public void OnDrag(PointerEventData e)
    {
        if (e.pointerId != pointerId) return;
        Vector2 now = e.position;
        SangramMobileInput.Look += (now - previous) * sensitivity;
        previous = now;
    }
    public void OnPointerUp(PointerEventData e) { if (e.pointerId == pointerId) pointerId = int.MinValue; }
}

public enum MobileAction { Fire, Jump, Sprint, Reload }
public class MobileActionButton : MonoBehaviour, IPointerDownHandler, IPointerUpHandler
{
    public MobileAction action;
    public void OnPointerDown(PointerEventData e) { Set(true); }
    public void OnPointerUp(PointerEventData e) { Set(false); }
    private void Set(bool down)
    {
        switch (action)
        {
            case MobileAction.Fire: SangramMobileInput.Fire = down; break;
            case MobileAction.Jump: if (down) SangramMobileInput.JumpPressed = true; break;
            case MobileAction.Sprint: SangramMobileInput.Sprint = down; break;
            case MobileAction.Reload: if (down) SangramMobileInput.ReloadPressed = true; break;
        }
    }
}