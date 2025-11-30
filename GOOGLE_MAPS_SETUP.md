# Google Maps Setup Instructions

## Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable these APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Geocoding API**
   - **Places API** (optional, for search suggestions)

4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy your API key

## Configure Android

1. Open `android/app/src/main/AndroidManifest.xml`
2. Add this inside `<application>` tag (replace YOUR_API_KEY):

```xml
<manifest>
    <application>
        <!-- Add this line -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>
    </application>
    
    <!-- Add these permissions if not already present -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```

## Configure iOS (Optional)

1. Open `ios/Runner/AppDelegate.swift`
2. Add at the top:
```swift
import GoogleMaps
```

3. In the `application` function, add:
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

## Test the Map

1. Stop the app if running
2. Run `flutter clean`
3. Run `flutter pub get`
4. Run `flutter run`
5. Go to "Manage Activities" → "Add Activity"
6. Tap on "Target Location" field
7. Map should open with current location

## Features

- **Tap on map** to select location
- **Drag marker** to adjust position
- **Search** for locations using the search bar
- **Current location** button to go to your GPS location
- Address automatically reverse geocoded from coordinates

## Troubleshooting

- **Map not showing**: Check API key is correct and APIs are enabled
- **"Developer Error"**: API key restrictions may be blocking the app
- **Location not working**: Ensure location permissions are granted
- **Search not working**: Enable Geocoding API in Google Cloud Console

## Cost

Google Maps Platform has a free tier:
- $200 free credit per month
- Map loads: $7 per 1000 loads
- Geocoding: $5 per 1000 requests

For development, you're well within the free limits.

## API Key Security

For production:
1. Restrict API key to your app's package name: `com.example.psmms`
2. Add SHA-1 fingerprint restrictions
3. Use environment variables for API keys
4. Never commit API keys to GitHub
