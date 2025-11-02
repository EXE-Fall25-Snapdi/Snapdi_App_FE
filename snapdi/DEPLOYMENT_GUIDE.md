# Snapdi App - Deployment Guide

## 📱 App Configuration Summary

### Application IDs
- **Android**: `com.snapdi.app`
- **iOS**: `com.snapdi.app`
- **App Name**: Snapdi
- **Version**: 1.0.0+1

### Backend API
- **Production API**: `https://snapdi-api-7cmuvhzaxa-as.a.run.app`
- **Hosted On**: Google Cloud Run
- **Protocol**: HTTPS (SSL Enabled)
- **Region**: Asia Southeast

---

## 🔐 Android Deployment Setup

### Step 1: Create a Keystore (First time only)

Open PowerShell and run:

```powershell
cd android
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You'll be prompted for:
- Keystore password (create a strong password)
- Key password (can be the same as keystore password)
- Your name and organization details

**IMPORTANT**: Save your passwords securely! You'll need them for all future releases.

### Step 2: Configure Signing

1. Copy `key.properties.template` to `key.properties`:
   ```powershell
   cd android
   copy key.properties.template key.properties
   ```

2. Edit `android/key.properties` with your actual values:
   ```properties
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```

3. **NEVER commit `key.properties` or `*.jks` files to git!** They're already in `.gitignore`

### Step 3: Build Release APK

```powershell
# Navigate to project root
cd E:\University\Semester8_Fall2025\EXE201\Snapdi\Snapdi_App\snapdi

# Build APK
flutter build apk --release

# Or build split APKs (smaller file size)
flutter build apk --split-per-abi --release
```

Output location: `build/app/outputs/flutter-apk/app-release.apk`

### Step 4: Build Android App Bundle (AAB) for Play Store

```powershell
flutter build appbundle --release
```

Output location: `build/app/outputs/bundle/release/app-release.aab`

**Note**: Google Play Store requires AAB format for new apps.

---

## 🍎 iOS Deployment Setup

### Prerequisites
- macOS with Xcode installed
- Apple Developer Account ($99/year)
- CocoaPods installed

### Step 1: Install Dependencies

```bash
cd ios
pod install
cd ..
```

### Step 2: Configure Signing in Xcode

1. Open iOS project:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. In Xcode:
   - Select **Runner** in the project navigator
   - Go to **Signing & Capabilities** tab
   - Check **Automatically manage signing**
   - Select your **Team** (Apple Developer account)
   - Xcode will automatically provision the app

### Step 3: Build Release IPA

```bash
# Build for iOS
flutter build ios --release

# Or build and archive in Xcode:
# Product > Archive
```

### Step 4: Distribute via App Store Connect

1. In Xcode: **Product > Archive**
2. Once archived, click **Distribute App**
3. Choose **App Store Connect**
4. Follow the wizard to upload to TestFlight/App Store

---

## 🚀 Testing Release Builds

### Android
```powershell
# Install release APK on connected device
flutter install --release

# Or manually install APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
# Run on connected iOS device
flutter run --release
```

---

## 📋 Pre-Deployment Checklist

### ✅ Android
- [ ] Keystore created and secured
- [ ] `key.properties` configured (not committed to git)
- [ ] App icons updated (`android/app/src/main/res/mipmap-*/ic_launcher.png`)
- [ ] App name correct in `AndroidManifest.xml` (✅ Already set to "Snapdi")
- [ ] Bundle ID correct: `com.snapdi.app` (✅ Already configured)
- [ ] Permissions reviewed in `AndroidManifest.xml` (✅ Internet, Camera, Storage, Location)
- [ ] ProGuard rules configured (✅ Already set up)
- [ ] Test release build on multiple devices
- [ ] Version number updated in `pubspec.yaml`

### ✅ iOS
- [ ] Bundle ID correct: `com.snapdi.app` (✅ Already configured)
- [ ] Display name set to "Snapdi" (✅ Already set)
- [ ] App icons added in `Assets.xcassets`
- [ ] Privacy permissions configured in `Info.plist` (✅ Location usage description added)
- [ ] Apple Developer account active
- [ ] Certificates and provisioning profiles valid
- [ ] Test release build on multiple devices
- [ ] Version number matches Android

---

## 📦 App Store Submission

### Google Play Store
1. Build AAB: `flutter build appbundle --release`
2. Go to [Google Play Console](https://play.google.com/console)
3. Create new application
4. Upload AAB to **Production** or **Internal Testing**
5. Fill in store listing (description, screenshots, etc.)
6. Complete content rating questionnaire
7. Set pricing and distribution
8. Submit for review

### Apple App Store
1. Build and archive in Xcode
2. Upload to App Store Connect
3. Go to [App Store Connect](https://appstoreconnect.apple.com)
4. Fill in app information and screenshots
5. Submit for TestFlight (optional beta testing)
6. Submit for App Store review

---

## 🔄 Updating Version Numbers

Before each release, update in `pubspec.yaml`:

```yaml
version: 1.0.1+2  # Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

- **Version name**: 1.0.1 (user-visible)
- **Build number**: 2 (increments with each build)

---

## 🐛 Troubleshooting

### Android: "No key with alias 'upload' found"
- Check `key.properties` has correct `keyAlias`
- Verify keystore file path is correct

### Android: ProGuard errors
- Check `proguard-rules.pro` for missing keep rules
- Add specific keep rules for models/libraries causing issues

### iOS: Signing errors
- Ensure Apple Developer account is active
- Try manual signing in Xcode
- Regenerate provisioning profiles

### Build fails with network errors
- Check internet connection
- Clear Flutter cache: `flutter clean`
- Re-download dependencies: `flutter pub get`

---

## 📱 Current App Permissions

### Android
- ✅ Internet access (API calls)
- ✅ Network state (connectivity check)
- ✅ Camera (photo upload)
- ✅ Storage/Media (image selection)
- ✅ Location (find nearby photographers)

### iOS
- ✅ Location when in use (finding photographers)

---

## 🔒 Security Notes

1. **NEVER** commit these files:
   - `android/key.properties`
   - `android/*.jks` or `android/*.keystore`
   - Any file containing passwords or API keys

2. Keep backups of:
   - Keystore file (`upload-keystore.jks`)
   - Keystore passwords
   - Apple Developer account credentials

3. Store credentials securely (password manager)

---

## 📞 Support

For deployment issues:
- Check Flutter documentation: https://docs.flutter.dev/deployment
- Android deployment: https://docs.flutter.dev/deployment/android
- iOS deployment: https://docs.flutter.dev/deployment/ios

---

## 🎯 Quick Commands Reference

```powershell
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build Android APK
flutter build apk --release

# Build Android AAB
flutter build appbundle --release

# Build iOS
flutter build ios --release

# Run release mode
flutter run --release

# Check for issues
flutter doctor -v
```

---

**Last Updated**: November 1, 2025
**App Version**: 1.0.0+1
