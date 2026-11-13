#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

public static class SangramPrototypeBuilder
{
    [MenuItem("Tools/SANGRAM/Create Prototype Scene")]
    public static void Build()
    {
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);

        GameObject ground = GameObject.CreatePrimitive(PrimitiveType.Plane);
        ground.name = "Training Ground";
        ground.transform.localScale = new Vector3(18f, 1f, 18f);
        ground.GetComponent<Renderer>().sharedMaterial = MakeMaterial(new Color(.28f, .34f, .24f));

        for (int i = 0; i < 18; i++)
        {
            GameObject cover = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cover.name = "Village Cover";
            cover.transform.position = new Vector3(Mathf.Sin(i * 2.4f) * 22f, 1f,
                Mathf.Cos(i * 2.4f) * 22f);
            cover.transform.localScale = new Vector3(Random.Range(2f, 5f),
                Random.Range(1.5f, 3.5f), Random.Range(2f, 5f));
            cover.GetComponent<Renderer>().sharedMaterial = MakeMaterial(new Color(.42f, .32f, .22f));
        }

        GameObject player = GameObject.CreatePrimitive(PrimitiveType.Capsule);
        player.name = "SANGRAM Player";
        player.tag = "Player";
        player.transform.position = new Vector3(0f, 1f, 0f);
        Object.DestroyImmediate(player.GetComponent<CapsuleCollider>());
        CharacterController character = player.AddComponent<CharacterController>();
        character.height = 2f;
        character.radius = .42f;
        player.AddComponent<Health>();

        GameObject cameraObject = new GameObject("Main Camera");
        cameraObject.tag = "MainCamera";
        Camera camera = cameraObject.AddComponent<Camera>();
        camera.fieldOfView = 65f;
        ThirdPersonCameraRig rig = cameraObject.AddComponent<ThirdPersonCameraRig>();
        rig.target = player.transform;
        ThirdPersonController controller = player.AddComponent<ThirdPersonController>();
        controller.cameraTransform = camera.transform;
        BuildMobileHud();
        WeaponController weapon = player.AddComponent<WeaponController>();
        weapon.aimCamera = camera;

        for (int i = 0; i < 8; i++)
        {
            GameObject bot = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            bot.name = "Practice Enemy";
            bot.transform.position = new Vector3(Random.Range(-35f, 35f), 1f,
                Random.Range(18f, 45f));
            bot.GetComponent<Renderer>().sharedMaterial = MakeMaterial(new Color(.55f, .12f, .1f));
            Health botHealth = bot.AddComponent<Health>();
            botHealth.destroyOnDeath = true;
            bot.AddComponent<PracticeBot>();
        }

        GameObject zoneObject = new GameObject("Prototype Safe Zone");
        SafeZonePrototype zone = zoneObject.AddComponent<SafeZonePrototype>();
        zone.center = Vector3.zero;

        GameObject sunObject = new GameObject("Sun");
        Light sun = sunObject.AddComponent<Light>();
        sun.type = LightType.Directional;
        sun.transform.rotation = Quaternion.Euler(50f, -30f, 0f);
        sun.intensity = 1.2f;

        EditorSceneManager.SaveScene(scene, "Assets/SANGRAM/Scenes/SANGRAM_Prototype.unity");
        AssetDatabase.SaveAssets();
        EditorUtility.DisplayDialog("SANGRAM",
            "Prototype scene created. Press Play to test.", "OK");
    }


    private static void BuildMobileHud()
    {
        GameObject root = new GameObject("SANGRAM Mobile HUD");
        Canvas canvas = root.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        CanvasScaler scaler = root.AddComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920, 1080);
        root.AddComponent<GraphicRaycaster>();
        if (Object.FindObjectOfType<EventSystem>() == null)
        {
            GameObject es = new GameObject("EventSystem");
            es.AddComponent<EventSystem>();
            es.AddComponent<StandaloneInputModule>();
        }
        RectTransform look = MakeHudPanel(canvas.transform, "Look Area", new Vector2(.48f, 0f), new Vector2(1f, 1f), new Color(1,1,1,.015f));
        look.gameObject.AddComponent<MobileLookArea>();
        RectTransform stick = MakeHudPanel(canvas.transform, "Movement Joystick", new Vector2(.04f,.07f), new Vector2(.22f,.38f), new Color(.05f,.08f,.12f,.42f));
        stick.gameObject.AddComponent<MobileJoystick>();
        MakeHudButton(canvas.transform, "FIRE", MobileAction.Fire, new Vector2(.84f,.28f), new Vector2(.96f,.48f));
        MakeHudButton(canvas.transform, "JUMP", MobileAction.Jump, new Vector2(.75f,.08f), new Vector2(.84f,.23f));
        MakeHudButton(canvas.transform, "SPRINT", MobileAction.Sprint, new Vector2(.23f,.08f), new Vector2(.34f,.20f));
        MakeHudButton(canvas.transform, "RELOAD", MobileAction.Reload, new Vector2(.86f,.53f), new Vector2(.96f,.65f));
    }

    private static RectTransform MakeHudPanel(Transform parent, string name, Vector2 min, Vector2 max, Color color)
    {
        GameObject go = new GameObject(name, typeof(RectTransform), typeof(Image));
        go.transform.SetParent(parent, false);
        RectTransform rect = go.GetComponent<RectTransform>();
        rect.anchorMin = min; rect.anchorMax = max; rect.offsetMin = Vector2.zero; rect.offsetMax = Vector2.zero;
        go.GetComponent<Image>().color = color;
        return rect;
    }

    private static void MakeHudButton(Transform parent, string label, MobileAction action, Vector2 min, Vector2 max)
    {
        RectTransform rect = MakeHudPanel(parent, label + " Button", min, max, new Color(.04f,.12f,.22f,.78f));
        rect.gameObject.AddComponent<MobileActionButton>().action = action;
        GameObject textGo = new GameObject("Label", typeof(RectTransform), typeof(Text));
        textGo.transform.SetParent(rect, false);
        RectTransform tr = textGo.GetComponent<RectTransform>();
        tr.anchorMin = Vector2.zero; tr.anchorMax = Vector2.one; tr.offsetMin = Vector2.zero; tr.offsetMax = Vector2.zero;
        Text t = textGo.GetComponent<Text>();
        t.text = label; t.alignment = TextAnchor.MiddleCenter; t.color = Color.white;
        t.font = Resources.GetBuiltinResource<Font>("Arial.ttf"); t.fontSize = 24; t.fontStyle = FontStyle.Bold; t.raycastTarget = false;
    }

    private static Material MakeMaterial(Color color)
    {
        Material material = new Material(Shader.Find("Standard"));
        material.color = color;
        return material;
    }
}
#endif
