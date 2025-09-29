# Environment Configuration Guide

This document explains how to set up and use environment variables in the Snapdi Flutter application.

## Quick Setup

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your actual values in the `.env` file**
3. **Never commit the `.env` file to version control** (it's already in `.gitignore`)

## Environment Files

- **`.env`** - Your local environment variables (not tracked in git)
- **`.env.example`** - Template file showing all available variables (tracked in git)

## How to Use Environment Variables

### In Dart Code

Use the `Environment` class to access environment variables:

```dart
import 'package:snapdi_app/core/constants/environment.dart';

// API Configuration
String apiUrl = Environment.fullApiUrl;
bool isDebug = Environment.debugMode;

// Feature Flags
if (Environment.enableChatFeature) {
  // Enable chat functionality
}

// Firebase Configuration
String firebaseProjectId = Environment.firebaseProjectId;
```

### Running with Environment Variables

You can override environment variables when running the app:

```bash
# Development
flutter run --dart-define=FLUTTER_ENV=development --dart-define=DEBUG_MODE=true

# Production
flutter run --dart-define=FLUTTER_ENV=production --dart-define=DEBUG_MODE=false

# With custom API URL
flutter run --dart-define=API_BASE_URL=https://staging-api.snapdi.com
```

### Build with Environment Variables

For building releases with specific configurations:

```bash
# Production build
flutter build apk --dart-define=FLUTTER_ENV=production --dart-define=API_BASE_URL=https://api.snapdi.com

# Staging build
flutter build apk --dart-define=FLUTTER_ENV=staging --dart-define=API_BASE_URL=https://staging-api.snapdi.com
```

## Available Environment Variables

### API Configuration
- `API_BASE_URL` - Base URL for your API
- `API_VERSION` - API version (e.g., v1, v2)
- `JWT_SECRET_KEY` - JWT secret for token validation
- `REFRESH_TOKEN_EXPIRY` - Refresh token expiry time
- `ACCESS_TOKEN_EXPIRY` - Access token expiry time

### Firebase Configuration
- `FIREBASE_API_KEY` - Firebase API key
- `FIREBASE_AUTH_DOMAIN` - Firebase auth domain
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `FIREBASE_STORAGE_BUCKET` - Firebase storage bucket
- `FIREBASE_MESSAGING_SENDER_ID` - FCM sender ID
- `FIREBASE_APP_ID` - Firebase app ID

### Google Services
- `GOOGLE_MAPS_API_KEY` - Google Maps API key
- `GOOGLE_PLACES_API_KEY` - Google Places API key

### Payment Services
- `STRIPE_PUBLISHABLE_KEY` - Stripe publishable key
- `PAYPAL_CLIENT_ID` - PayPal client ID

### Social Login
- `GOOGLE_CLIENT_ID` - Google OAuth client ID
- `FACEBOOK_APP_ID` - Facebook app ID
- `APPLE_CLIENT_ID` - Apple Sign-In client ID

### Development Settings
- `FLUTTER_ENV` - Environment (development, staging, production)
- `DEBUG_MODE` - Enable/disable debug mode
- `LOG_LEVEL` - Logging level (debug, info, warning, error)
- `ENABLE_LOGGING` - Enable/disable logging
- `MOCK_API_RESPONSES` - Use mock API responses

### Feature Flags
- `ENABLE_CHAT_FEATURE` - Enable chat functionality
- `ENABLE_VIDEO_CALLS` - Enable video calling
- `ENABLE_LIVE_STREAMING` - Enable live streaming
- `ENABLE_AI_RECOMMENDATIONS` - Enable AI recommendations
- `ENABLE_GEOLOCATION` - Enable geolocation features

### File Upload Settings
- `MAX_IMAGE_SIZE_MB` - Maximum image size in MB
- `MAX_IMAGES_PER_UPLOAD` - Maximum number of images per upload
- `ALLOWED_IMAGE_FORMATS` - Comma-separated list of allowed formats

### Business Configuration
- `PLATFORM_COMMISSION_RATE` - Commission rate (0.15 = 15%)
- `MIN_BOOKING_AMOUNT` - Minimum booking amount
- `MAX_BOOKING_AMOUNT` - Maximum booking amount
- `DEFAULT_COUNTRY` - Default country code
- `DEFAULT_CURRENCY` - Default currency code

## Best Practices

1. **Never commit `.env` files** - They contain sensitive information
2. **Always update `.env.example`** - When adding new variables
3. **Use feature flags** - For gradual feature rollouts
4. **Validate environment** - Call `Environment.validateEnvironment()` on app start
5. **Use different configurations** - For development, staging, and production

## Environment Validation

The app includes built-in environment validation:

```dart
void main() {
  // Validate environment configuration
  if (!Environment.validateEnvironment()) {
    print('ERROR: Invalid environment configuration');
    return;
  }
  
  // Print configuration in debug mode
  Environment.printConfiguration();
  
  runApp(MyApp());
}
```

## CI/CD Integration

For continuous integration and deployment, set environment variables in your CI/CD platform:

### GitHub Actions Example
```yaml
- name: Build Flutter App
  run: flutter build apk --dart-define=FLUTTER_ENV=production --dart-define=API_BASE_URL=${{ secrets.API_BASE_URL }}
```

### Environment Secrets
Store sensitive values as secrets in your CI/CD platform:
- `API_BASE_URL`
- `FIREBASE_API_KEY`
- `STRIPE_PUBLISHABLE_KEY`
- `GOOGLE_MAPS_API_KEY`

## Troubleshooting

### Common Issues

1. **Environment variables not loading**
   - Ensure you're using `--dart-define` when running the app
   - Check that variable names match exactly

2. **App crashes on startup**
   - Call `Environment.validateEnvironment()` to check for missing required variables
   - Check `Environment.printConfiguration()` output for debugging

3. **API calls failing**
   - Verify `API_BASE_URL` is correct
   - Check network permissions in platform-specific configurations

### Debug Environment
```dart
// Add this to your main.dart for debugging
if (Environment.debugMode) {
  Environment.printConfiguration();
}
```