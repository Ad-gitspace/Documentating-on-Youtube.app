# Task: YouTube Upload Core Logic & Resilience

## 🎯 Objective
Stabilize the video upload process, handle network interruptions gracefully, and prevent duplicate uploads. Enhance the metadata injection flow.

## 🛠 Context & Background
The app experiences `ClientException` (connection abort) and `SocketException` (DNS failure) during resumable uploads. There is also a logic flaw where videos already present on YouTube are re-uploaded.

## 📋 Requirements & Fixes

### 1. Resumable Upload Resilience (Ref: Error-1)
- **Issue:** `ClientException: Software caused connection abort` and `SocketException: Failed host lookup`.
- **Goal:** Implement robust retry logic and resumable upload state management.
- **Details:**
    - Enhance `YouTubeService` to catch these specific exceptions.
    - Implement an exponential backoff strategy for retries.
    - Ensure the `resumable_upload` URI is persisted so that if the app crashes, it can resume from the last byte instead of restarting.

### 2. Duplicate Upload Prevention (Ref: Error-2)
- **Issue:** Video starts uploading even if it's already on YouTube.
- **Goal:** Implement an idempotency check or pre-upload verification.
- **Details:**
    - Before starting an upload, check the local `upload_manager` state or query YouTube API for recently uploaded videos with matching metadata/hash.
    - If a match is found, skip the upload and link to the existing video ID.

### 3. Flexible Metadata Injection (Ref: Feature-3)
- **Goal:** Provide a "Fast Upload" (default) vs "Custom Edit" metadata flow.
- **Details:**
    - The UI should show a "Fast Upload" button using saved templates.
    - A secondary "Edit Details" option should allow the user to modify the Title, Description, and Tags before the upload starts.
    - Ensure the `UploadManager` can handle both pre-defined and user-overridden metadata.

## 🔍 Validation Criteria
- [ ] Upload survives a temporary network disconnect (simulated via Airplane mode).
- [ ] Attempting to upload the same video twice results in a "Already Uploaded" notification or a skip.
- [ ] User can successfully toggle between "Fast" and "Custom" metadata modes.

## 📂 Relevant Files
- `lib/services/youtube_service.dart`
- `lib/services/upload_manager.dart`
- `lib/screens/home_screen.dart`
