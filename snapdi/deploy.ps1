# Snapdi App - Quick Deployment Script
# Run this script from the project root directory

Write-Host "=== Snapdi App Deployment Helper ===" -ForegroundColor Cyan
Write-Host ""

# Check if running from correct directory
if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "ERROR: Please run this script from the project root directory" -ForegroundColor Red
    exit 1
}

# Check Flutter installation
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
flutter doctor -v

Write-Host ""
Write-Host "=== Deployment Options ===" -ForegroundColor Cyan
Write-Host "1. Setup Android keystore (first time only)"
Write-Host "2. Build Android APK (Release)"
Write-Host "3. Build Android App Bundle (AAB for Play Store)"
Write-Host "4. Build iOS (macOS only)"
Write-Host "5. Clean and rebuild"
Write-Host "6. Exit"
Write-Host ""

$choice = Read-Host "Select an option (1-6)"

switch ($choice) {
    "1" {
        Write-Host "Creating Android keystore..." -ForegroundColor Yellow
        cd android
        
        if (Test-Path "upload-keystore.jks") {
            Write-Host "WARNING: Keystore already exists!" -ForegroundColor Red
            $overwrite = Read-Host "Overwrite existing keystore? (yes/no)"
            if ($overwrite -ne "yes") {
                Write-Host "Cancelled." -ForegroundColor Yellow
                cd ..
                exit 0
            }
        }
        
        Write-Host "Follow the prompts to create your keystore..." -ForegroundColor Green
        keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
        
        if (Test-Path "upload-keystore.jks") {
            Write-Host "Keystore created successfully!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Next steps:" -ForegroundColor Yellow
            Write-Host "1. Copy key.properties.template to key.properties"
            Write-Host "2. Edit key.properties with your passwords"
            Write-Host ""
            
            if (Test-Path "key.properties.template") {
                $createProps = Read-Host "Create key.properties now? (yes/no)"
                if ($createProps -eq "yes") {
                    Copy-Item "key.properties.template" "key.properties"
                    Write-Host "key.properties created! Please edit it with your passwords." -ForegroundColor Green
                    notepad "key.properties"
                }
            }
        }
        cd ..
    }
    
    "2" {
        Write-Host "Building Android APK (Release)..." -ForegroundColor Yellow
        
        # Check if keystore is configured
        if (-not (Test-Path "android/key.properties")) {
            Write-Host "WARNING: key.properties not found. Build will use debug signing." -ForegroundColor Yellow
            $continue = Read-Host "Continue? (yes/no)"
            if ($continue -ne "yes") {
                exit 0
            }
        }
        
        flutter clean
        flutter pub get
        flutter build apk --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Build successful!" -ForegroundColor Green
            Write-Host "APK location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
            
            $openFolder = Read-Host "Open output folder? (yes/no)"
            if ($openFolder -eq "yes") {
                explorer "build\app\outputs\flutter-apk"
            }
        } else {
            Write-Host "Build failed! Check errors above." -ForegroundColor Red
        }
    }
    
    "3" {
        Write-Host "Building Android App Bundle (AAB)..." -ForegroundColor Yellow
        
        # Check if keystore is configured
        if (-not (Test-Path "android/key.properties")) {
            Write-Host "ERROR: key.properties not found. AAB requires release signing." -ForegroundColor Red
            Write-Host "Please run option 1 to create keystore first." -ForegroundColor Yellow
            exit 1
        }
        
        flutter clean
        flutter pub get
        flutter build appbundle --release
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Build successful!" -ForegroundColor Green
            Write-Host "AAB location: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Cyan
            
            $openFolder = Read-Host "Open output folder? (yes/no)"
            if ($openFolder -eq "yes") {
                explorer "build\app\outputs\bundle\release"
            }
        } else {
            Write-Host "Build failed! Check errors above." -ForegroundColor Red
        }
    }
    
    "4" {
        Write-Host "Building iOS..." -ForegroundColor Yellow
        
        if ($env:OS -notlike "*Windows*") {
            Write-Host "Installing iOS dependencies..." -ForegroundColor Yellow
            cd ios
            pod install
            cd ..
            
            flutter clean
            flutter pub get
            flutter build ios --release
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "Build successful!" -ForegroundColor Green
                Write-Host "To create archive: Open Xcode > Product > Archive" -ForegroundColor Cyan
            } else {
                Write-Host "Build failed! Check errors above." -ForegroundColor Red
            }
        } else {
            Write-Host "ERROR: iOS builds require macOS with Xcode" -ForegroundColor Red
        }
    }
    
    "5" {
        Write-Host "Cleaning and rebuilding..." -ForegroundColor Yellow
        flutter clean
        flutter pub get
        Write-Host "Clean complete! Run flutter build to create release builds." -ForegroundColor Green
    }
    
    "6" {
        Write-Host "Goodbye!" -ForegroundColor Cyan
        exit 0
    }
    
    default {
        Write-Host "Invalid option" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "For detailed deployment instructions, see DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
