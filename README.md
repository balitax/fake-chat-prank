# Fake Chat Simulator

A WhatsApp-style fake chat conversation creator built with Flutter. Create realistic-looking chat screenshots for entertainment purposes.

## Features

### Core
- Create and manage multiple chat conversations
- Add, edit, insert, and delete messages
- Toggle sender (me / other) with long-press on send button
- Auto-reply simulation with configurable delay and typing indicator
- Edit contact profile (name, photo, online status, last seen text)
- Full-screen preview mode with screenshot export
- Light and dark mode with WhatsApp-accurate theming
- Persistent storage using SharedPreferences

### Premium Features (unlocked via rewarded ads for 6 hours)
- **Chat Themes** - 6 color presets (Default, Ocean Blue, Rose Pink, Midnight Purple, Sunset Orange, Forest Green)
- **Custom Backgrounds** - Pick an image from gallery as chat background
- **Remove Watermark** - Export screenshots without watermark
- **Group Chat Mode** - Add multiple participants with unique name colors, sender names displayed above bubbles

### Ads Integration (Google AdMob)
- **App Open Ad** - Shown on app launch and resume from background
- **Banner Ad** - Displayed at the bottom of the home screen
- **Interstitial Ad** - Shown before opening preview screen
- **Rewarded Ad** - Watch to unlock premium features for 6 hours

## Tech Stack

- **Flutter** 3.8+
- **Dart** 3.8+
- **State Management** - StatefulWidget (local state)
- **Storage** - SharedPreferences
- **Ads** - google_mobile_ads
- **Screenshot** - screenshot package
- **Image Picker** - image_picker

## Project Structure

```
lib/
├── main.dart                     # App entry, home screen, theme toggle
├── models/
│   ├── models.dart               # Barrel export
│   ├── chat_profile_model.dart   # Contact profile (name, avatar, status)
│   ├── chat_project_model.dart   # Chat project (messages, theme, group, bg)
│   ├── message_model.dart        # Message (text, sender, status, group member)
│   └── group_member_model.dart   # Group chat member (name, color)
├── screens/
│   ├── screens.dart              # Barrel export
│   ├── chat_editor_screen.dart   # Main editor with live preview
│   ├── chat_preview_screen.dart  # Full-screen preview + screenshot
│   └── settings_screen.dart      # App settings + premium status
├── services/
│   ├── services.dart             # Barrel export
│   ├── storage_service.dart      # SharedPreferences CRUD
│   ├── screenshot_service.dart   # Screenshot capture + save
│   └── ad_service.dart           # AdMob singleton (all ad types + premium timer)
├── theme/
│   └── app_theme.dart            # WhatsApp light/dark themes + ChatTheme presets
└── widgets/
    ├── widgets.dart              # Barrel export
    ├── chat_bubble.dart          # Message bubble with tail painter
    ├── chat_header.dart          # WhatsApp-style chat header
    ├── message_input_panel.dart  # Input field with send/mic toggle
    ├── typing_indicator.dart     # Animated three-dot indicator
    ├── banner_ad_widget.dart     # Reusable banner ad widget
    └── premium_lock_overlay.dart # Premium lock + rewarded ad dialog
```

## Setup

```bash
# Clone and install dependencies
git clone <repo-url>
cd fake-chat
flutter pub get

# Run on device/emulator
flutter run
```

### AdMob Configuration

The app uses **Google test Ad Unit IDs** by default. To use production ads:

1. Replace the App ID in `android/app/src/main/AndroidManifest.xml`
2. Replace the Ad Unit IDs in `lib/services/ad_service.dart`

## Disclaimer

This app is designed for entertainment purposes only. Any conversations created are fictional and should not be used to deceive or mislead others.
