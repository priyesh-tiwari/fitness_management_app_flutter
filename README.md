# 💪 FitTrack — Frontend

The Flutter frontend for **FitTrack**, a dual-role fitness management app for Trainers and Users. Book sessions, track attendance via QR codes, manage fitness programs, and get AI-powered fitness analysis.

> 🔗 Backend Repository: [fitness_management_app_node](https://github.com/priyesh-tiwari/fitness_management_app_node_backend)
> 📹 Demo Video: [Watch on Google Drive](https://drive.google.com/drive/folders/1Fgwe9mJrx1LMqnw-V07YIWmWLXGMshsn?usp=sharing)

---

## 📱 Screenshots

> _Add screenshots here_

---

## ✨ Features

### 👤 User
- Email/Password signup & login
- Google OAuth2 social login
- Browse and book trainer sessions
- Stripe-powered one-month subscription payment
- QR code scanning for session attendance
- Daily activity tracking
- Push notifications on goal completion (FCM)
- View AI-generated personal fitness analysis
- Profile photo upload

### 🏋️ Trainer
- Manage fitness programs and slots
- Generate QR codes for session validation
- View per-user AI fitness analysis
- Track user attendance
- Manage profile and media uploads

---

## 🧱 Tech Stack

| Purpose | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| SDK | ^3.8.1 |
| State Management | Flutter Riverpod 2.4.9 |
| HTTP Client | http 1.6.0 |
| Auth | JWT + Google Sign-In 6.2.1 |
| Local Storage | Shared Preferences 2.5.3 |
| Push Notifications | Firebase Messaging 16.1.0 + Flutter Local Notifications |
| QR Generation | qr_flutter 4.1.0 |
| QR Scanning | mobile_scanner 7.1.4 |
| Image Picker | image_picker 1.2.1 |
| Calendar | table_calendar 3.2.0 |
| WebView | webview_flutter 4.13.0 |
| Responsive UI | flutter_screenutil 5.9.3 |
| Date Formatting | intl 0.20.2 |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.8.1
- Dart ^3.8.1
- Android Studio or VS Code with Flutter extension
- A running FitTrack backend (local or deployed)
- Firebase project (for FCM push notifications)

### Installation

```bash
git clone https://github.com/priyesh-tiwari/fitness_management_app_flutter.git
cd fitness_management_app_flutter
flutter pub get
```

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add your Android app and download `google-services.json`
3. Place it in `android/app/`

### Run the App

```bash
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎯 App Flow

```
Splash Screen
     ↓
Login / Signup (Email or Google OAuth2)
     ↓
     ├── Trainer Dashboard
     │     ↓
     │   Manage Programs & Slots
     │     ↓
     │   Generate QR for Sessions
     │     ↓
     │   View AI Fitness Analysis per User
     │
     └── User Dashboard
           ↓
         Browse & Book Sessions (Stripe Payment)
           ↓
         Scan QR Code for Attendance
           ↓
         Daily Activity Tracking
           ↓
         Receive Push Notifications on Goal Completion
```

---

## 📲 Key Implementations

### QR Code Attendance
- Trainers generate a unique QR code per session
- Users scan the QR using the in-app scanner (`mobile_scanner`)
- Backend validates the QR against the trainer's program to prevent cross-program access

### Push Notifications (FCM)
- Firebase Cloud Messaging handles push delivery
- Server triggers notifications when a user completes a daily goal
- `flutter_local_notifications` handles foreground display

### Google OAuth2
- One-tap Google Sign-In via `google_sign_in`
- Tokens sent to backend for verification and JWT issuance

### AI Fitness Analysis
- Backend calls OpenAI API to generate per-user fitness insights
- Results displayed in the user and trainer dashboards

---

## 👤 Role-Based UI

| Role | Access |
|---|---|
| User | Book sessions, scan QR, track activity, view AI analysis |
| Trainer | Manage programs/slots, generate QR, view per-user AI analysis |

Role is determined from the JWT payload on login and drives the entire navigation and UI structure.

---

## 🌐 Backend

The backend is deployed on [Render](https://render.com).

> ⚠️ **Cold Start Warning:** The free tier backend may take **30–50 seconds** to respond after a period of inactivity. This is expected — not a bug in the app.

---

## 🙋‍♂️ Author

**Priyesh Tiwari**
- GitHub: [@priyesh-tiwari](https://github.com/priyesh-tiwari)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
