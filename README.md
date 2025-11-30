# PSMMS - Preacher and Activity Management System

A Flutter-based mobile application for managing preachers, activities, and payments for religious organizations.

## Features

### 🎯 Activity Management
- **Officer Module**
  - Create, edit, and delete activities
  - Set activity urgency levels (Normal/Urgent)
  - Approve or reject preacher evidence submissions
  - View GPS-verified evidence with photos
  - Interactive Google Maps location picker

- **Preacher Module**
  - Browse and apply for available activities
  - Filter activities (Nearest, Newest, Urgent)
  - Submit evidence with GPS verification
  - Upload minimum 3 photos per activity
  - View activity status (Upcoming, Pending, Approved, Rejected)

### 💰 Payment Management
- Activity payment request management
- Approval workflow
- Payment history tracking
- Preacher-specific payment history

### 🗺️ Location Features
- Google Maps integration for activity locations
- GPS verification for evidence submission
- Automatic address geocoding
- Interactive map picker

## Technology Stack

- **Framework**: Flutter 3.7+
- **State Management**: Provider
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Maps**: Google Maps Flutter
- **Location**: Geolocator & Geocoding

## Getting Started

### Prerequisites

- Flutter SDK (3.7 or higher)
- Dart SDK
- Android Studio / Xcode
- Firebase account
- Google Cloud Platform account (for Maps API)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/psmms.git
   cd psmms
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and place in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place in `ios/Runner/`
   - Enable Authentication, Firestore, and Storage in Firebase Console

4. **Google Maps Setup**
   - Follow instructions in [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md)
   - Get Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in `android/app/src/main/AndroidManifest.xml`
   - Enable Maps SDK for Android, Geocoding API, and Places API

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── activity.dart
│   ├── activity_submission.dart
│   └── payment.dart
├── viewmodels/              # Business logic (Provider)
│   ├── officer_activity_view_model.dart
│   ├── preacher_activity_view_model.dart
│   └── payment_view_model.dart
└── views/                   # UI screens
    ├── activity/
    │   ├── officer/        # Officer screens
    │   ├── preacher/       # Preacher screens
    │   └── widgets/        # Shared widgets (Map picker)
    └── payment/            # Payment screens
```

## Security Notes

⚠️ **IMPORTANT**: Never commit sensitive files:
- `google-services.json`
- `GoogleService-Info.plist`
- API keys in AndroidManifest.xml

These files are ignored by `.gitignore` for security.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please open an issue in the GitHub repository.

