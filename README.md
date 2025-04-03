# Salah Reminder App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.31.0-blue.svg" alt="Flutter Version">       
  <img src="https://img.shields.io/badge/Dart-3.8.0-blue.svg" alt="Dart Version">
  <img src="https://img.shields.io/badge/License-BSD_3--Clause-blue.svg" alt="License">
</div>

## 📱 Overview

Salah Reminder is a Flutter application designed to help Muslims never miss their prayer times.
It provides accurate prayer timings based on your location, customizable congregation times for your local mosque, and elegant notifications to remind you when it's time to pray.

## ✨ Features

- **Accurate Prayer Times**: Fetch precise prayer times based on your location using the Aladhan API
- **Location Detection**: Automatically detect user's current location or manually set a location
- **Custom Congregation Times**: Set and save congregation times for your local mosque
- **Elegant UI**: Clean, intuitive interface with both light and dark theme support
- **Prayer Notifications**: Receive timely notifications before prayer times and congregation times
- **Offline Support**: Save prayer times locally for offline access using Hive database        
- **Animated Splash Screen**: Beautiful Lottie animation on app launch
- **Qibla Direction**: Built-in Qibla compass feature

## 🛠️ Technologies & Frameworks

### Core
- **Flutter SDK**: >=3.2.3
- **Dart**: Latest stable version

### Dependencies
- **State Management**
  - Provider (^6.0.5)

- **UI Components**
  - Google Fonts (^6.1.0)
  - Lottie (^2.7.0)
  - Material Design

- **Core Features**
  - Adhan (^2.0.0-nullsafety.2)
  - Flutter Qiblah (^2.2.0)
  - Geolocator (^10.1.0)
  - Flutter Local Notifications (^16.3.0)

- **Data Management**
  - Shared Preferences (^2.2.2)
  - HTTP (^1.1.0)
  - intl (^0.18.1)

## 🌍 APIs

- [**Aladhan API**](https://aladhan.com/prayer-times-api): For fetching accurate prayer times  
- **Location Services**: For detecting user's current location

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.2.3 or higher)
- Dart SDK (latest stable)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/AnsAsghar/torbaaz_salah_reminder.git
   ```

2. Navigate to the project directory
   ```bash
   cd torbaaz_salah_reminder
   ```

3. Install dependencies
   ```bash
   flutter pub get
   ```

4. Run the app
   ```bash
   flutter run
   ```

## 🗃️ Project Structure

```
lib/
├── main.dart              # Application entry point
├── models/                # Data models
├── providers/            # State management
├── screens/              # UI screens
├── services/             # Services for APIs, notifications, etc.
├── theme/               # Theme configuration
├── utils/               # Utility functions
└── widgets/             # Reusable UI components
```

## ⚙️ Configuration

1. **Location Permissions**
   - The app requires location permissions for accurate prayer times
   - Enable location services on your device

2. **Notifications**
   - Allow notifications for prayer time reminders
   - Customize notification settings in the app

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## 👏 Acknowledgements

- [Aladhan API](https://aladhan.com/prayer-times-api) for providing prayer time data
- [Flutter Team](https://flutter.dev/) for the amazing framework
- [Lottie](https://airbnb.design/lottie/) for the beautiful animations
- Special thanks to the creators of the Adhan library
- Inspired by the need for a modern, reliable prayer time application

## 📧 Contact

Anas Asghar - [@AnsAsghar](https://github.com/AnsAsghar)

Project Link: [https://github.com/AnsAsghar/torbaaz_salah_reminder](https://github.com/AnsAsghar/torbaaz_salah_reminder) 