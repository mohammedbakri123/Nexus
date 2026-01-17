# 🎮 NEXUS - Future of Gaming

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10.4-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.10.4-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-Private-red)

**A modern, high-performance Flutter application for discovering and managing your favorite video games**

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Configuration](#-configuration) • [Performance](#-performance)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Project Structure](#-project-structure)
- [Performance Optimizations](#-performance-optimizations)
- [Platform Support](#-platform-support)
- [Contributing](#-contributing)
- [License](#-license)

## 🎯 Overview

NEXUS is a beautifully designed Flutter application that provides gamers with a comprehensive platform to discover, explore, and manage their favorite video games. Built with performance and user experience in mind, it leverages the [RAWG Video Games Database API](https://rawg.io/apidocs) to deliver real-time game information, ratings, and details.

### Key Highlights

- ⚡ **High Performance**: Optimized with image caching, parallel data loading, and efficient state management
- 🎨 **Modern UI**: Sleek neon-themed design with smooth animations and transitions
- 📱 **Cross-Platform**: Runs seamlessly on Android, iOS, Linux, macOS, and Windows
- 💾 **Offline Support**: Local database storage for favorites and user preferences
- 🔍 **Smart Search**: Debounced search functionality for instant results

## ✨ Features

### 🏠 Home Screen
- **Featured Games**: Discover top-rated games with stunning visuals
- **Trending Now**: Infinite scroll through the latest trending games
- **Smart Search**: Real-time search with debouncing for optimal performance
- **Personalized Welcome**: Customized greeting with user's name

### ⭐ Favorites
- **Game Collection**: Save and organize your favorite games
- **Quick Access**: Fast retrieval with parallel data loading
- **Pull to Refresh**: Easy updates with swipe-to-refresh functionality

### 🎮 Game Details
- **Comprehensive Information**: Detailed game descriptions, ratings, and genres
- **Hero Images**: High-quality game artwork and screenshots
- **Interactive UI**: Draggable bottom sheet for smooth navigation
- **One-Tap Favorites**: Instantly add or remove games from your collection

### ⚙️ Settings
- **Theme Toggle**: Switch between light and dark modes
- **User Preferences**: Customize your experience
- **Profile Management**: Edit your profile information

## 🛠 Tech Stack

### Core Technologies
- **Flutter 3.10.4+** - Cross-platform UI framework
- **Dart 3.10.4+** - Programming language

### Key Dependencies
- `provider` - State management
- `http` - HTTP client for API requests
- `cached_network_image` - Efficient image caching
- `sqflite` - SQLite database for mobile platforms
- `sqflite_common_ffi` - SQLite for desktop platforms
- `shared_preferences` - Persistent key-value storage

### API Integration
- [RAWG Video Games Database API](https://rawg.io/apidocs) - Game data and information

## 📦 Installation

### Prerequisites

Ensure you have the following installed:
- Flutter SDK (3.10.4 or higher)
- Dart SDK (3.10.4 or higher)
- Android Studio / Xcode (for mobile development)
- Git

### Clone the Repository

```bash
git clone https://github.com/yourusername/nexus.git
cd nexus
```

### Install Dependencies

```bash
flutter pub get
```

### Run the Application

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android    # Android
flutter run -d ios        # iOS
flutter run -d linux      # Linux
flutter run -d macos      # macOS
flutter run -d windows    # Windows
```

### Build Release

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Desktop
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

## ⚙️ Configuration

### API Key Setup

To use the RAWG API, you need to obtain an API key:

1. Visit [RAWG.io](https://rawg.io/) and create an account
2. Navigate to your API settings to get your API key
3. Update the API key in the project:

**Option 1: Update `lib/core/constants/api_constants.dart`**
```dart
class ApiConstants {
  static const String rawgBaseUrl = 'https://api.rawg.io/api';
  static const String rawgApiKey = 'YOUR_API_KEY_HERE';
}
```

**Option 2: Use Environment Variables (Recommended for Production)**
```dart
// Add to your environment configuration
static const String rawgApiKey = String.fromEnvironment('RAWG_API_KEY');
```

Then run with:
```bash
flutter run --dart-define=RAWG_API_KEY=your_api_key_here
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/          # API constants and configuration
│   ├── navigation/         # Navigation and routing logic
│   ├── providers/          # State management providers
│   ├── storage/            # Database and session management
│   └── theme/              # App themes and color schemes
├── features/
│   ├── auth/               # Authentication pages
│   ├── favorites/          # Favorites management
│   ├── home/               # Home screen and game listing
│   ├── notifications/      # Notifications page
│   ├── profile/            # User profile management
│   ├── settings/           # Settings page
│   └── splash/             # Splash screen
├── shared/
│   ├── models/             # Data models (GameModel, UserModel)
│   └── widgets/            # Reusable widgets
└── main.dart               # Application entry point
```

## ⚡ Performance Optimizations

NEXUS is built with performance as a priority. Here are the key optimizations implemented:

### Image Optimization
- **Cached Network Images**: All game images are cached locally using `cached_network_image`
- **Placeholder Loading**: Smooth loading states with placeholders
- **Error Handling**: Graceful fallbacks for failed image loads

### Data Loading
- **Parallel Processing**: Favorites page loads games in parallel instead of sequentially
- **Pagination**: Infinite scroll with efficient pagination
- **Debounced Search**: 500ms debounce prevents excessive API calls

### UI Optimization
- **RepaintBoundary**: Expensive widgets are wrapped to prevent unnecessary repaints
- **Const Constructors**: Maximum use of const widgets to reduce rebuilds
- **IndexedStack**: Efficient tab navigation without rebuilding entire pages

### Memory Management
- **Proper Disposal**: Controllers and timers are properly disposed
- **Lazy Loading**: Images and data load on-demand
- **Efficient State Management**: Minimal state updates with Provider

## 🖥 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android  | ✅ Fully Supported | API 21+ |
| iOS      | ✅ Fully Supported | iOS 12+ |
| Linux    | ✅ Fully Supported | x64 |
| macOS    | ✅ Fully Supported | x64, ARM64 |
| Windows  | ✅ Fully Supported | x64 |

## 🎨 Design Principles

- **Neon Theme**: Modern dark theme with vibrant accent colors
- **Smooth Animations**: Fluid transitions between screens
- **Responsive Layout**: Adapts to different screen sizes
- **Accessibility**: Follows Material Design guidelines

## 🔮 Future Enhancements

- [ ] User authentication with Firebase
- [ ] Social features (reviews, ratings, sharing)
- [ ] Game recommendations based on preferences
- [ ] Wishlist functionality
- [ ] Release date tracking and notifications
- [ ] Advanced filtering and sorting options
- [ ] Multi-language support
- [ ] Cloud sync for favorites across devices

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Write meaningful commit messages
- Ensure all tests pass before submitting
- Update documentation as needed

## 📄 License

This project is private and proprietary. All rights reserved.

## 👤 Author

**Mohammed**

- Project: [NEXUS](https://github.com/yourusername/nexus)

## 🙏 Acknowledgments

- [RAWG Video Games Database](https://rawg.io/) for providing the game data API
- Flutter team for the amazing framework
- All contributors and users of this project

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ Star this repo if you find it helpful!

</div>
