# BookSwap

A Flutter-based mobile marketplace where students can list textbooks they wish to exchange and initiate swap offers with other users.

# DEMO VIDEO LINK
[Demo Link](https://youtu.be/OI-Zd-I6PSo?si=_34Q0ZD-tz2cDsV_)
 

## Features

- **User Authentication**: Email/password and Google Sign-In with email verification
- **Book Listings**: Post, browse, and manage textbook listings with images
- **Swap Offers**: Send and receive swap proposals between users
- **Real-time Chat**: In-app messaging for coordinating exchanges
- **User Profiles**: Manage personal information and view listing history

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Flutter UI Layer                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Screens    │  │   Widgets    │  │    Theme     │      │
│  └──────┬───────┘  └──────────────┘  └──────────────┘      │
└─────────┼───────────────────────────────────────────────────┘
          │
┌─────────┼───────────────────────────────────────────────────┐
│         │          State Management Layer                    │
│  ┌──────▼───────┐                                            │
│  │   Provider   │  (AppState)                                │
│  └──────┬───────┘                                            │
└─────────┼───────────────────────────────────────────────────┘
          │
┌─────────┼───────────────────────────────────────────────────┐
│         │             Service Layer                          │
│  ┌──────▼───────┬──────────┬──────────┬──────────┐          │
│  │ AuthService  │BookService│ChatService│SwapService│        │
│  └──────┬───────┴──────┬───┴──────┬───┴──────┬────┘  gi        │
└─────────┼──────────────┼──────────┼──────────┼──────────────┘
          │              │          │          │
┌─────────┼──────────────┼──────────┼──────────┼──────────────┐
│         │              │          │          │               │
│  ┌──────▼──────┐  ┌────▼────┐  ┌─▼─────┐  ┌─▼─────┐        │
│  │  Firebase   │  │Firebase │  │Firebase│  │Firebase│       │
│  │    Auth     │  │Firestore│  │Firestore│ │Storage│       │
│  └─────────────┘  └─────────┘  └────────┘  └───────┘        │
│                     Firebase Backend                         │
└─────────────────────────────────────────────────────────────┘

Data Models: BookListing, SwapOffer, ChatMessage
```

## Project Structure

```
lib/
├── main.dart                    # App entry point & auth wrapper
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   ├── book_listing.dart
│   ├── swap_offer.dart
│   └── chat_message.dart
├── providers/                   # State management
│   └── app_state.dart
├── screens/                     # UI screens
│   ├── welcome_screen.dart
│   ├── email_verification_screen.dart
│   ├── home_screen.dart
│   ├── browse_listings_screen.dart
│   ├── post_book_screen.dart
│   ├── my_listings_screen.dart
│   ├── my_offers_screen.dart
│   ├── received_offers_screen.dart
│   ├── chats_list_screen.dart
│   ├── chat_screen.dart
│   ├── profile_screen.dart
│   └── settings_screen.dart
├── services/                    # Business logic
│   ├── auth_service.dart
│   ├── book_service.dart
│   ├── swap_service.dart
│   ├── chat_service.dart
│   └── storage_service.dart
└── theme/
    └── app_theme.dart
```

## Prerequisites

- Flutter SDK (3.9.0 or higher)
- Dart SDK (3.9.0 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase account
- Git

## Build Steps

### 1. Clone the Repository

```bash
git clone <repository-url>
cd bookswap
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "bookswap"
3. Enable the following services:
   - Authentication (Email/Password & Google Sign-In)
   - Cloud Firestore
   - Firebase Storage

#### Configure Firebase for Flutter

Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

Configure Firebase:
```bash
flutterfire configure
```

This generates `lib/firebase_options.dart` and platform-specific config files.

#### Firestore Security Rules

Set up Firestore rules in Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    match /books/{bookId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId;
    }
    match /swapOffers/{offerId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.fromUserId || 
         request.auth.uid == resource.data.toUserId);
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.toUserId;
    }
    match /chats/{chatId} {
      allow read, write: if request.auth != null && 
        request.auth.uid in resource.data.participants;
    }
  }
}
```

#### Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /book_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Platform-Specific Setup

#### Android

1. Update `android/app/build.gradle.kts` with minimum SDK version:
```kotlin
minSdk = 21
```

2. Ensure `google-services.json` is in `android/app/` (generated by FlutterFire)

#### iOS

1. Update `ios/Runner/Info.plist` with camera permissions:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to upload book images</string>
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take book photos</string>
```

2. Ensure `GoogleService-Info.plist` is in `ios/Runner/` (generated by FlutterFire)

### 5. Run the App

#### Check for issues:
```bash
flutter doctor
```

#### Run on connected device/emulator:
```bash
flutter run
```

#### Build for production:

Android:
```bash
flutter build apk --release
```

iOS:
```bash
flutter build ios --release
```

## Code Quality

### Run Dart Analyzer

```bash
flutter analyze
```

Expected output: **No issues found!**

### Run Tests

```bash
flutter test
```

### Format Code

```bash
flutter format lib/
```

## Dependencies

### Core
- `flutter`: SDK
- `firebase_core`: ^3.6.0
- `firebase_auth`: ^5.3.1
- `cloud_firestore`: ^5.4.4
- `firebase_storage`: ^12.3.4

### Authentication
- `google_sign_in`: ^6.2.1

### Image Handling
- `image_picker`: ^1.2.0
- `flutter_image_compress`: ^2.1.0

### State Management
- `provider`: ^6.1.2

### UI
- `cupertino_icons`: ^1.0.8

## Security

Sensitive files are excluded from version control via `.gitignore`:
- `google-services.json` (Android Firebase config)
- `GoogleService-Info.plist` (iOS Firebase config)
- `firebase_options.dart` (Generated Firebase options)
- `local.properties` (Android local config)

**Important**: Never commit these files to public repositories.

## Troubleshooting

### Firebase initialization error
- Ensure `flutterfire configure` was run successfully
- Verify Firebase project settings match your app

### Build errors
- Run `flutter clean` then `flutter pub get`
- Check Flutter and Dart SDK versions

### Image picker not working
- Verify platform-specific permissions are configured
- Check device/emulator has camera/gallery access

## Contributing

1. Fork the repository
2. Create a feature branch
3. Run `flutter analyze` to ensure zero warnings
4. Submit a pull request

## License

This project is for educational purposes.
