# FCSIT AdvisorBot

A Flutter mobile application for the FCSIT AdvisorBot, a RAG-based academic advisory chatbot for students of FCSIT UNIMAS.

> **Note:** This repository contains the Flutter frontend only. The chatbot backend is in a separate repository — you will need it running before the app can answer queries.

## Features

- Ask general academic-related queries (programme structure, academic rules, graduation requirements, credit transfer, etc.)
- Source citations provided in chatbot responses
- GPA / CGPA calculator tool
- Available on **Android** and **Web**

## Prerequisites

1. Flutter SDK (version 3.32.4 or later)
2. For Android: An Android device running Android 13.0 or later
3. For Web: Google Chrome
4. The [AdvisorBot backend](https://github.com/cst023/FCSIT-AdvisorBot) running locally or deployed to the cloud

## Setup

**1. Clone the repository**

```bash
git clone https://github.com/cst023/FCSIT-AdvisorBot-Mobile-App.git
cd FCSIT-AdvisorBot-Mobile-App
```

**2. Install dependencies**

```bash
flutter pub get
```

**3. Configure the backend URL**

Open `lib/features/chat/data/services/chat_api_service.dart` and update the URLs:

```dart
static const String _localUrl = 'http://192.168.x.x:8000'; // your machine's LAN IP
static const String _cloudUrl = 'https://your-backend.run.app'; // your Cloud Server URL (if deployed on cloud)
static const bool _useCloud = false; // set to true to use cloud backend
```

- Find your LAN IP by running `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
- Your Android device and development machine must be on the **same Wi-Fi network** for local mode
- Web always uses `_cloudUrl` regardless of the `_useCloud` flag

## Running the App

**Android**

Connect your Android device, then:

```bash
flutter run
```

**Web (Chrome)**

```bash
flutter run -d chrome
```

## Building the App

**Android APK**

```bash
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

**Web**

```bash
flutter build web --release --base-href "/fcsit_advisorbot_web/"
```

## Web Deployment (GitHub Pages)

A `Makefile` is included for deploying the web build to GitHub Pages.

**Prerequisites:**
- GNU Make installed (`choco install make` on Windows)
- A separate GitHub repository is created for the web deployment (e.g. `fcsit_advisorbot_web`)

**One-time setup** — edit the `Makefile` and set your GitHub username:

```makefile
GITHUB_USER = your-github-username
```

**Deploy:**

```bash
make deploy
```

Then go to your deployment repository on GitHub → **Settings** → **Pages** → set source branch to `main`.

Your web app will be live at `https://your-username.github.io/fcsit_advisorbot_web/`.

## Project Structure

```
lib/
  core/
    constants/        # app colours and strings
    theme/            # app theme
    utils/            # date formatter
  features/
    chat/
      data/
        models/       # ChatMessage, ApiResponse
        services/     # ChatApiService (HTTP + health check)
      presentation/
        providers/    # ChatProvider (state + persistence + health polling)
        screens/      # ChatScreen
        widgets/      # MessageBubble, TypingIndicator, ChatInputBar, StatusBanner
    gpa_calculator/
      data/models/    # CourseEntry (grade lookup table)
      presentation/
        providers/    # GpaProvider (GPA/CGPA calculation logic)
        screens/      # GpaCalculatorScreen
        widgets/      # CourseTable, ResultRow
```

## Related Repository

- [AdvisorBot Backend](https://github.com/cst023/FCSIT-AdvisorBot)
