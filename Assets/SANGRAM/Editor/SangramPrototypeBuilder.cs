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
        WeaponController weapon = player.AddComponent<WeaponController>();
        weapon.aimCamera = camera;

        for (int i = 0; i < 8; i++)
        {
            GameObject bot = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            bot.name = "Practice Enemy";
            bot.tag = "Enemy";
            bot.transform.position = new Vector3(Random.Range(-35f, 35f), 1f,
                Random.Range(18f, 45f));
            bot.GetComponent<Renderer>().sharedMaterial = MakeMaterial(new Color(.55f, .12f, .1f));
            bot.AddComponent<Health>();
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

    private static Material MakeMaterial(Color color)
    {
        Material material = new Material(Shader.Find("Standard"));
        material.color = color;
        return material;
    }
}
#endif
