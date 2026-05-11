# Task: Data Persistence & Authentication Lifecycle

## 🎯 Objective
Resolve issues related to OAuth session persistence, local/cloud data storage for video history, and template management. Implement user profile customization.

## 🛠 Context & Background
The app currently loses all state (video history, templates) upon restart or logout. Additionally, OAuth permissions are requested every time the user logs in, even if previously granted.

## 📋 Requirements & Fixes

### 1. OAuth Persistence (Ref: Error-4)
- **Issue:** User is prompted for permissions (app name, YouTube activity) on every login.
- **Goal:** Implement silent sign-in and persistent token management.
- **Details:** 
    - Verify `AuthService` properly utilizes `google_sign_in`'s silent sign-in capabilities.
    - Ensure that once scopes are granted, they are remembered. 
    - Check if the `clientId` or `scopes` are being handled in a way that forces re-authentication.

### 2. Video History & Template Persistence (Ref: Error-5, Error-6)
- **Issue:** Closing the app wipes video history. "Save Template" button fails to persist data to Firebase.
- **Goal:** Implement a hybrid persistence strategy (Local + Cloud).
- **Details:**
    - **Local:** Use `shared_preferences` or `sqflite` for immediate local cache of video history.
    - **Cloud:** Fix `FirebaseService` to ensure upload metadata and user templates are correctly pushed to Firestore.
    - **Sync:** On app start, sync local state with Firestore to ensure data is available after re-installation.

### 3. User Profile Customization (Ref: Feature-2)
- **Goal:** Add functionality to change the user's display name within the app.
- **Details:**
    - Update `AuthService` and `FirebaseService` to handle custom user metadata.
    - Create a method to update the `displayName` in the Firestore `users` collection.

## 🔍 Validation Criteria
- [ ] User can close and reopen the app without being prompted for OAuth permissions (if already signed in).
- [ ] Video history persists across app restarts.
- [ ] "Save Template" successfully writes to Firestore and the data remains after logout/login.
- [ ] User name change is reflected in the UI and persisted in the database.

## 📂 Relevant Files
- `lib/services/auth_service.dart`
- `lib/services/firebase_service.dart`
- `lib/screens/settings_screen.dart`
