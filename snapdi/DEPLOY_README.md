# 🚀 Quick Start - Deploy Snapdi App

## For Android (Windows/macOS/Linux)

### First Time Setup (One-time only)

1. **Create signing key**:
   ```powershell
   cd android
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   
2. **Configure signing**:
   ```powershell
   copy key.properties.template key.properties
   notepad key.properties  # Edit with your passwords
   ```

### Build Release APK

```powershell
flutter build apk --release
```

**Output**: `build\app\outputs\flutter-apk\app-release.apk`

### Build for Google Play Store

```powershell
flutter build appbundle --release
```

**Output**: `build\app\outputs\bundle\release\app-release.aab`

---

## For iOS (macOS only)

### Setup

```bash
cd ios
pod install
cd ..
```

### Build

```bash
flutter build ios --release
```

Then in Xcode: **Product → Archive → Distribute App**

---

## 🎯 Using the Helper Script

Run the interactive deployment script:

```powershell
.\deploy.ps1
```

This script will guide you through:
- Creating keystore
- Building APK
- Building AAB
- Building iOS

---

## 📚 Full Documentation

See **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** for complete instructions including:
- App store submission
- Troubleshooting
- Version management
- Security best practices

---

## ✅ Pre-Deploy Checklist

- [ ] Keystore created and backed up
- [ ] `key.properties` configured (not in git)
- [ ] App version updated in `pubspec.yaml`
- [ ] Tested release build on real device
- [ ] App icons updated
- [ ] Screenshots prepared for stores

---

## 🆘 Need Help?

1. Check `DEPLOYMENT_GUIDE.md` for detailed instructions
2. Run `flutter doctor -v` to check your setup
3. Flutter deployment docs: https://docs.flutter.dev/deployment

---

**Current Version**: 1.0.0+1  
**Bundle ID**: com.snapdi.app  
**App Name**: Snapdi
