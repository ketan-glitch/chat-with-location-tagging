# Chat with Location Tagging

A Flutter chat application demonstrating word-level Google Places Autocomplete inside message input, with location tagging, highlighted place text, and map preview inside chat messages.

---

## ✨ Features

- Login & Registration (mock)
- Home screen with dummy chat users
- One-to-one chat UI
- In-memory messages
- Google Places Autocomplete while typing
- Detects only the currently typed word
- Replace active word with selected place
- Highlighted location text inside message
- Map preview with pinned location
- Clean Architecture + BLoC

---

## 🧱 Architecture

```

Presentation → BLoC
Domain → UseCases & Entities
Data → Repositories & DataSources

````

State management: flutter_bloc  
Dependency injection: get_it  

---

## 🔑 Requirements

- Flutter 3+
- Google Maps Platform API Key with:
  - Places API
  - Maps SDK for Android
  - Maps SDK for iOS

---

## ⚙️ Setup

1. Clone repository

```bash
git clone <repo-url>
cd chat_with_location_tagging
````

2. Install dependencies

```bash
flutter pub get
```

3. Add Google API Key

`lib/core/config/env.dart`

```dart
const String googlePlacesApiKey = "YOUR_KEY";
```

4. Android setup

`android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_KEY"/>
```

5. iOS setup

`ios/Runner/AppDelegate.swift`

```swift
GMSServices.provideAPIKey("YOUR_KEY")
```

6. Run app

```bash
flutter run
```

---

## 🗺 How It Works

* User types message
* Last active word is detected
* Places Autocomplete runs on that word
* User selects suggestion
* Word replaced, cursor preserved
* On send → place lat/lng fetched
* Message shows highlighted place + map preview

---

## 📄 License

MIT License