# DocsMe ⚡

![Flutter](https://img.shields.io/badge/Flutter-3.41.9-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.11.5-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-Proprietary-D19A03)

**DocsMe** is a premium, high-performance Flutter application designed for professional creators to automate their daily YouTube documenting workflow. It streamlines the entire process from capture to upload, wrapped in a sophisticated glassmorphic interface.

---

## 🚀 Vision

Documenting your daily journey should be effortless. DocsMe simplifies the creator's workflow by providing a dedicated, secure, and aesthetically refined tool that handles the complexities of YouTube API interactions. We focus on the "Upload Utility," allowing you to focus on the content.

## ✨ Key Features

- **⚡ Instant Capture**: High-definition camera interface with integrated controls optimized for rapid content creation.
- **🛡️ Secure Auth**: Robust Google OAuth 2.0 integration with specialized YouTube Data API scopes for maximum security.
- **💎 Glassmorphic UI**: A modern, frosted-glass design language utilizing advanced Flutter rendering techniques for a premium feel.
- **📦 Workflow Automation**: One-tap uploads with customizable metadata templates, intelligent auto-titling, and flexible metadata injection.
- **🛡️ Upload Resilience**: Robust retry logic with exponential backoff to handle connection drops, and intelligent duplicate prevention.
- **📊 Creator Dashboard**: Centralized management of your upload history, processing status, and channel metrics.

---

## ⚖️ Compliance & Legal

DocsMe is built with Google OAuth 2.0 verification in mind. We provide professional, pre-formatted HTML legal documents in the `/Rights & Policies` directory:

- **Landing Page**: `index.html`
- **Privacy Policy**: `PrivacyPolicy.html`
- **Terms of Service**: `TermsOfService.html`

These documents are styled with the DocsMe "Gold Standard" aesthetic and are ready for hosting on **GitHub Pages**, **Netlify**, or **Firebase Hosting** to satisfy Google's App Verification requirements.

---

## 🎨 Visual Identity: The "DocsMe" Palette

DocsMe adheres to a signature **Gold Standard** color language:
- **Primary Gold (#D19A03)**: Brand identity and primary call-to-action elements.
- **Sage Green (#6F8F3F)**: Success indicators and completed workflow states.
- **Sky Blue (#68BBFF)**: Interactive highlights and secondary informative elements.
- **Deep Charcoal (#141311)**: The sophisticated foundation of our high-contrast dark mode.

---

## 🛠️ Architecture & Tech Stack

The project is built on a modular, service-oriented architecture designed for reliability and scale:

- **Core Layer**: Centralized design system tokens and global configurations.
- **Service Layer**: Decoupled, asynchronous business logic for YouTube Data API v3 and OAuth 2.0.
- **UI Layer**: Composable, atomic widgets and state-aware screens built with a glassmorphism design language.

---

## 🏗️ Getting Started

### Prerequisites
- **Flutter SDK**: `^3.11.5`
- **Google Cloud Platform**: An active project with **YouTube Data API v3** enabled.
- **OAuth Credentials**: A valid `client_secret.json` configured for your target platforms.

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/docsme.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure native platforms:** 
   Add your Google Client IDs to the Android (`google-services.json`) and iOS (`GoogleService-Info.plist`) configurations.
4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 📄 License
© 2026 DocsMe. All rights reserved. A professional utility for professional creators.
