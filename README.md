# cordova-plugin-firebasex-core

Core plugin for the modular FirebaseX Cordova plugin suite. This plugin initializes Firebase and provides shared utilities used by all feature plugins.

## Features

- Firebase initialization (`FIRApp.configure` / `FirebaseApp.initializeApp`)
- Firebase Installations API (get/delete installation ID, get installation token)
- Shared event bus for inter-plugin communication
- Shared preferences/state management
- App lifecycle tracking (foreground/background)
- Message receiver infrastructure

## Installation

```bash
cordova plugin add cordova-plugin-firebasex-core
```

## API

### `FirebasexCore.getInstallationId(success, error)`

Get the Firebase installation ID.

### `FirebasexCore.getInstallationToken(success, error)`

Get the Firebase installation auth token.

### `FirebasexCore.deleteInstallationId(success, error)`

Delete the current Firebase installation ID.

### `FirebasexCore.getId(success, error)`

Alias for `getInstallationId`.

## Plugin Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ANDROID_FIREBASE_CONFIG_FILEPATH` | - | Custom path to google-services.json |
| `IOS_FIREBASE_CONFIG_FILEPATH` | - | Custom path to GoogleService-Info.plist |
| `ANDROID_ICON_ACCENT` | `#FF00FFFF` | Accent color for notification icons |
| `IOS_STRIP_DEBUG` | `false` | Strip debug symbols on iOS |
| `IOS_FIREBASE_SDK_VERSION` | - | Override Firebase iOS SDK version |

## Dependencies

This plugin is a dependency of all other `cordova-plugin-firebasex-*` feature plugins and is automatically installed when any feature plugin is added.
