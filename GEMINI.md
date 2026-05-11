# DocsMe: Engineering & Workflow Guidelines

This document defines the architectural standards and operational workflows for the **DocsMe** project. It serves as the definitive source of truth for developers to ensure consistency, quality, and maintainability across the codebase.

## 🏗 Project Architecture

DocsMe follows a **Layered Service-Oriented Architecture** to maintain a clean separation of concerns.

### 1. Core Layer (`lib/core/`)
- **Theme:** Centralized design system in `app_theme.dart` and `app_colors.dart`.
- **Constants:** Global configurations, API endpoints, and static string keys.
- **Purpose:** Provide a unified source for styling and global state that doesn't change frequently.

### 2. Service Layer (`lib/services/`)
- **AuthService:** Manages Google OAuth 2.0 via `google_sign_in`. It handles session persistence, silent sign-in, and granular scope management (`youtube.upload`, `youtube.readonly`).
- **YouTubeService:** A high-level wrapper around the `googleapis/youtube/v3.dart` library. It handles media stream preparation, chunked uploads, and metadata (snippet/status) construction.
- **Purpose:** Encapsulate complex external API logic away from the UI.

### 3. UI Layer (`lib/screens/` & `lib/widgets/`)
- **Main Shell:** Orchestrates top-level navigation using a custom `docs_nav_bar`.
- **Glassmorphism:** All UI elements should adhere to the "Glass Card" aesthetic using `BackdropFilter` and custom blur parameters.
- **State Management:** Currently utilizes standard `StatefulWidget` lifecycles for simplicity. Any significant state complexity should be moved to a dedicated state management solution (e.g., Bloc or Provider).

---

## 🎨 UI & Visual Identity: The "DocsMe" Standard

The visual experience of DocsMe is built on a high-contrast, premium aesthetic that combines modern glassmorphism with a distinctive color palette.

### Color Palette
- **Primary Gold (`#D19A03`):** Used for primary actions, brand highlights, and active states.
- **Success Sage (`#6F8F3F`):** Used for completed uploads and positive feedback loops.
- **Accent Sky Blue (`#68BBFF`):** Used for secondary highlights and informative indicators.
- **Background Charcoal (`#141311`):** The foundation for our dark-themed interface.

### UI Principles
- **Glassmorphism:** Use `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)` for cards and navigation bars to create a "frosted glass" effect.
- **Elevation:** Avoid standard shadows. Use subtle border gradients or inner glows to define depth.
- **Typography:** Leverage `GoogleFonts` (primarily Montserrat or similar) to maintain a clean, professional look.
- **Icons:** Use the custom brand logo `lib/assets/logo2.png` for splash screens and about sections.

---

## 🔄 Core Workflows

### Authentication Flow
1. **Silent Initialization:** At startup, `AuthService.init()` checks for an existing session.
2. **Interactive Sign-In:** `LoginScreen` triggers the interactive OAuth flow.
3. **Scope Validation:** Before sensitive operations (like uploading), `getAuthenticatedClient()` ensures the user has granted the specific `youtube.upload` scope, prompting if necessary.

### Video Upload Flow
1. **Source Selection:** Video is obtained via the custom camera interface or system gallery.
2. **Metadata Injection:** Users provide or the system generates title/description templates.
   - **Flexible Options:** A Bottom Sheet prompts the user to choose "Fast Upload", "Edit Details" (custom title, description, tags), or "Save for Later".
3. **Stream Upload:** `YouTubeService` initiates the upload, returning a `Video ID` upon success.
   - **Resilience:** Built-in exponential backoff for network interruptions (`SocketException`, connection aborts).
   - **Duplicate Prevention:** `UploadManager` verifies the file path against the queue to prevent accidental re-uploads.
4. **Progress Tracking:** The UI listens to the upload stream to provide real-time feedback.

---

## 🔐 Security & Sensitive Data

- **API Credentials:** NEVER commit `client_secret.json`, `google-services.json`, or `GoogleService-Info.plist` to version control. These are managed locally and should be listed in `.gitignore`.
- **Android Signing:** The project uses a custom release key defined in `android/key.properties`. This file and any `.jks` files are ignored by Git. New environments must recreate `key.properties` with the correct credentials to build the app.
- **OAuth Scopes:** Always use the least-privileged scope necessary. Request incremental scopes only when a specific feature (e.g., uploading) is triggered.

## 🛠 Standard Developer Workflow

Every task or feature implementation MUST follow this rigorous execution cycle:

### STEP 1: Research & Baseline
- **Code Audit:** Read the relevant service or screen file to understand the current logic.
- **Dependency Check:** Identify how the change impacts existing layers (Core, Service, UI).
- **Baseline Validation:** Run `flutter analyze`. The task cannot proceed until the workspace is in a "No Issues" state.

### STEP 2: Decompose & Strategy
- **Mental Model:** Break the task into discrete sub-tasks (e.g., 1. Add API model, 2. Update service, 3. Implement UI).
- **Design Alignment:** For UI changes, verify they strictly use the **"DocsMe"** palette (`AppColors.primary`) and glassmorphism standards.

### STEP 3: Implementation (Complete & Idiomatic)
- **Production-Ready Code:** Never use `TODO`, placeholders, or stub functions. Every function must have a full implementation.
- **Naming Conventions:** 
  - Variables/Functions: `camelCase` (e.g., `fetchLatestUploads`).
  - Classes: `PascalCase`.
  - Files: `kebab-case.dart`.
- **Error Handling:** Wrap all external I/O and API calls in robust `try-catch` blocks. Surface actionable, user-friendly error messages.

### STEP 4: Validation & Finalization
- **Verify Fix:** Manually test the change against edge cases (e.g., network loss, revoked permissions).
- **Final Cleanliness:** Run `flutter analyze` again. Zero warnings/errors is the only acceptable state for completion.

---

## 📝 Code Quality Standards

### ASYNC/AWAIT
- Always `await` Promises; never "fire and forget" unless explicitly documented.
- Surface actionable error messages (e.g., "Upload failed: Invalid video format" instead of "Error: 400").

### UI & FRONTEND
- **Design Defaults:** Use CSS-like custom properties defined in `AppColors`.
- **Accessibility:** Use semantic HTML-equivalent Flutter widgets and ensure proper contrast.
- **Animations:** Keep transitions under 300ms for responsiveness.

---

## 📂 Project Structure Map

- `lib/services/`: Backend logic & API wrappers.
- `lib/screens/`: Feature-specific views (Camera, Home, Library).
- `lib/widgets/`: Atomic, reusable UI components (Glass cards, Nav bars).
- `lib/core/`: Theming and shared constants.
- `Rights & Policies/`: Legal documents (HTML) for Google OAuth verification and public hosting.
- `ex-files/`: Reference assets and legacy documentation.

---

## ⚖️ Legal & Compliance

DocsMe requires Google OAuth 2.0 verification. The following assets are maintained for compliance:

- **index.html**: The application's public landing page.
- **PrivacyPolicy.html**: Detailed data usage, storage, and user rights (YouTube API compliant).
- **TermsOfService.html**: User agreement and YouTube TOS integration.

### Deployment Standards
- These files are designed for static hosting (GitHub Pages, Netlify, or Firebase Hosting).
- Any changes to YouTube scopes in `AuthService` MUST be reflected in `PrivacyPolicy.html`.
