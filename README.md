# mobile_app

A Flutter mobile app used by the Philty frontend. This README documents
how to run the app locally and common troubleshooting steps for assets
and the image picker (the most frequent source of issues when running
on a physical device).

## Important notes - Running the project

```powershell
flutter clean
flutter pub get
flutter run
```

After that do a full restart on device (`flutter run` or stop/start
the app). This ensures the asset is bundled into the app binary.

## Image picker (gallery/camera) permissions

The project uses `image_picker` for selecting a company logo. To use
the picker on real devices you must add the required permissions:

- Android (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
<!-- On Android 13+ you may need: -->
<!-- <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" /> -->
```

- iOS (`ios/Runner/Info.plist`):

```xml
<key>NSCameraUsageDescription</key>
<string>Needed to take profile photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Needed to pick images for your profile</string>
```
# Anwar Was Here
Follow the `image_picker` package documentation for platform-specific
details: https://pub.dev/packages/image_picker

## Common problems & troubleshooting

- Problem: Image shows in Chrome but not on physical phone.
  - Cause: Asset not bundled (missing `assets:` entry) or app not restarted.
  - Fix: Add the asset to `pubspec.yaml` (see above), run `flutter pub get`,
    then `flutter clean` and `flutter run` (full restart).

- Problem: Console shows `Unable to load asset: images/your.png`
  - Fix: Confirm the file path is correct, capitalization matches, and
    there is no leading `/` in the asset name. Update `pubspec.yaml` and
    run `flutter pub get`.

- Problem: ImagePicker fails on Android/iOS.
  - Fix: Ensure required permissions are present in the platform files
    (AndroidManifest/Info.plist) and that the `image_picker` dependency
    is in `pubspec.yaml`. If testing on Android emulator or iOS simulator,
    verify the simulator supports gallery/camera or use the device.


## Run locally (quick)

```powershell
# fetch deps
flutter pub get

# run on default device (or supply -d <deviceId>)
flutter run
```

If anything still fails, check the device logs (Android `adb logcat` or
`flutter run` console) and paste the error here and I will help debug it.
