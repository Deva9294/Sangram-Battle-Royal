# Android APK build checklist

1. Install Unity 2022.3 LTS through Unity Hub.
2. Add Android Build Support, Android SDK & NDK Tools, and OpenJDK.
3. Open the project and switch Build Settings to Android.
4. Player Settings:
   - Company: DevaCore Studio
   - Product: SANGRAM
   - Package: in.devacore.sangram
   - Default orientation: Landscape
   - Scripting backend: IL2CPP for release (Mono can be used for quick editor/device development where supported)
   - Target architectures: ARM64 for Play distribution
5. Add the generated prototype scene to Build Settings.
6. Build an APK for local testing. For Play Store distribution, configure signing credentials securely and build an Android App Bundle.
7. Test on physical devices, including low-memory Android phones.

Do not commit keystores, passwords, signing files, or private service credentials.
