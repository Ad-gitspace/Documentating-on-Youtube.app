# Task: UI/UX Enhancements & Media Experience

## 🎯 Objective
Fix layout issues in landscape mode and improve the post-upload user experience by integrating a native video preview.

## 🛠 Context & Background
The app's layout breaks in landscape mode due to fixed-size headers and footers. Users currently receive a link after upload instead of a direct video preview.

## 📋 Requirements & Fixes

### 1. Landscape Layout Optimization (Ref: Error-3)
- **Issue:** Main screen content is hidden/stuck behind the header and footer in landscape mode.
- **Goal:** Implement a responsive layout that adapts to orientation changes.
- **Details:**
    - Wrap main content in a `SingleChildScrollView` or use `CustomScrollView`.
    - Use `MediaQuery` to adjust header/footer heights or hide certain elements when `orientation == Orientation.landscape`.
    - Ensure `MainShell` and `docs_nav_bar` do not overlap critical content.

### 2. YouTube iFrame Integration (Ref: Feature-1)
- **Issue:** Successfully uploaded videos show links instead of a preview.
- **Goal:** Embed the `youtube_player_flutter` (or equivalent) for an in-app viewing experience.
- **Details:**
    - Update `VideoDetailScreen` or the success state in `HomeScreen` to include an iFrame player.
    - Automatically load the `videoId` returned by the `YouTubeService` after a successful upload.

### 3. Glassmorphism Consistency
- **Goal:** Ensure all new UI elements adhere to the "DocsMe" visual standard.
- **Details:**
    - Apply `BackdropFilter` and the primary gold (`#D19A03`) accents to the new video player container and custom metadata forms.

## 🔍 Validation Criteria
- [ ] The app is fully usable in landscape mode without content clipping.
- [ ] After a successful upload, a video player appears and plays the uploaded video.
- [ ] UI remains consistent with the "DocsMe" glassmorphism style defined in `GEMINI.md`.

## 📂 Relevant Files
- `lib/screens/main_shell.dart`
- `lib/screens/video_detail_screen.dart`
- `lib/widgets/glass_card.dart`
- `lib/widgets/docs_nav_bar.dart`
