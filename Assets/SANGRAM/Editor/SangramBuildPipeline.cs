#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEngine;

public static class SangramBuildPipeline
{
    public static void BuildAndroid()
    {
        SangramPrototypeBuilder.Build();
        const string scenePath = "Assets/SANGRAM/Scenes/SANGRAM_Prototype.unity";
        if (!File.Exists(scenePath))
            throw new FileNotFoundException("Prototype scene generation failed.", scenePath);

        EditorBuildSettings.scenes = new[]
        {
            new EditorBuildSettingsScene(scenePath, true)
        };

        PlayerSettings.companyName = "DevaCore Studio";
        PlayerSettings.productName = "SANGRAM";
        PlayerSettings.applicationIdentifier = "in.devacore.sangram";
        PlayerSettings.defaultInterfaceOrientation = UIOrientation.LandscapeLeft;
        PlayerSettings.SetScriptingBackend(BuildTargetGroup.Android, ScriptingImplementation.IL2CPP);
        PlayerSettings.Android.targetArchitectures = AndroidArchitecture.ARM64;
        PlayerSettings.Android.minSdkVersion = AndroidSdkVersions.AndroidApiLevel24;

        Directory.CreateDirectory("build/Android");
        BuildPlayerOptions options = new BuildPlayerOptions
        {
            scenes = new[] { scenePath },
            locationPathName = "build/Android/SANGRAM.apk",
            target = BuildTarget.Android,
            options = BuildOptions.None
        };
        BuildReport report = BuildPipeline.BuildPlayer(options);
        if (report.summary.result != BuildResult.Succeeded)
            throw new System.Exception("Android build failed: " + report.summary.result +
                " (" + report.summary.totalErrors + " errors)");
        Debug.Log("SANGRAM APK created: " + options.locationPathName);
    }
}
#endif
