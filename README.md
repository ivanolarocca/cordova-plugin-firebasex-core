# cordova-plugin-firebasex-core [![Latest Stable Version](https://img.shields.io/npm/v/cordova-plugin-firebasex-core.svg)](https://www.npmjs.com/package/cordova-plugin-firebasex-core)

Core plugin for the [modular FirebaseX Cordova plugin suite](https://github.com/dpa99c/cordova-plugin-firebasex#modular-plugins). 

This plugin wraps the [Firebase SDK](https://firebase.google.com/docs/reference) and provides core functionality such as Firebase initialization, the Installations API, and shared utilities used by all feature plugins.

Supported platforms: Android and iOS

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Features](#features)
- [Installation](#installation)
  - [Plugin variables](#plugin-variables)
    - [Android & iOS](#android--ios)
    - [Android only](#android-only)
    - [iOS only](#ios-only)
- [Build environment notes](#build-environment-notes)
  - [Android-specific](#android-specific)
    - [Specifying Android library versions](#specifying-android-library-versions)
    - [AndroidX](#androidx)
  - [iOS-specific](#ios-specific)
    - [Specifying iOS library versions](#specifying-ios-library-versions)
    - [Cocoapods](#cocoapods)
    - [Out-of-date pods](#out-of-date-pods)
    - [Strip debug symbols](#strip-debug-symbols)
- [Firebase config setup](#firebase-config-setup)
- [API](#api)
  - [Installations](#installations)
    - [getInstallationId](#getinstallationid)
    - [getInstallationToken](#getinstallationtoken)
    - [deleteInstallationId](#deleteinstallationid)
    - [registerInstallationIdChangeListener](#registerinstallationidchangelistener)
  - [Miscellaneous](#miscellaneous)
    - [registerApplicationDidBecomeActiveListener](#registerapplicationdidbecomeactivelistener)
    - [registerApplicationDidEnterBackgroundListener](#registerapplicationdidenterbackgroundlistener)
    - [Debug mode](#debug-mode)
- [Reporting issues](#reporting-issues)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Features

- Firebase initialization (`FIRApp.configure` / `FirebaseApp.initializeApp`)
- Firebase Installations API (get/delete installation ID, get installation token)
- Shared event bus for inter-plugin communication
- Shared preferences/state management
- App lifecycle tracking (foreground/background)
- Message receiver infrastructure

This plugin is a dependency of all other `cordova-plugin-firebasex-*` feature plugins and is automatically installed when any feature plugin is added.

# Installation

Install the plugin by adding it to your project's config.xml:

```xml
<plugin name="cordova-plugin-firebasex-core" spec="latest" />
```

or by running:

```
cordova plugin add cordova-plugin-firebasex-core
```

## Plugin variables

The following Cordova plugin variables are supported by the plugin.
Note that these must be set at plugin installation time. If you wish to change plugin variables, you'll need to uninstall the plugin and reinstall it with the new variable values.

### Android & iOS

-   `ANDROID_FIREBASE_CONFIG_FILEPATH` - sets a custom filepath to `google-services.json` file as a path relative to the project root
    -   e.g. `--variable ANDROID_FIREBASE_CONFIG_FILEPATH="resources/android/google-services.json"`
-   `IOS_FIREBASE_CONFIG_FILEPATH` - sets a custom filepath to `GoogleService-Info.plist` file as a path relative to the project root
    -   e.g. `--variable IOS_FIREBASE_CONFIG_FILEPATH="resources/ios/GoogleService-Info.plist"`

### Android only

The following plugin variables are used to specify the Firebase SDK versions as Gradle dependencies on Android:

-   `ANDROID_FIREBASE_CORE_VERSION` => `com.google.firebase:firebase-core`
-   `ANDROID_FIREBASE_INSTALLATIONS_VERSION` => `com.google.firebase:firebase-installations`
-   `ANDROID_GSON_VERSION` => `com.google.code.gson:gson`

See [Specifying Android library versions](#specifying-android-library-versions) for more info.

### iOS only

-   `IOS_FIREBASE_SDK_VERSION` - a specific version of the Firebase iOS SDK to set in the Podfile.
    -   If not specified, the default version defined in `<pod>` elements in the `plugin.xml` will be used.
-   `IOS_STRIP_DEBUG` - prevents symbolification of all libraries included via Cocoapods. See [Strip debug symbols](#strip-debug-symbols) for more info.
    -   e.g. `--variable IOS_STRIP_DEBUG=true`
    -   Defaults to `false` if not specified.

# Build environment notes

## Android-specific

### Specifying Android library versions

This plugin depends on various components such as the Firebase SDK which are pulled in at build-time by Gradle on Android.
By default this plugin pins specific versions of these in [its `plugin.xml`](https://github.com/dpa99c/cordova-plugin-firebasex-core/blob/master/plugin.xml) where you can find the currently pinned versions as `<preference>`'s.

The Android defaults can be overridden at plugin installation time by specifying plugin variables as command-line arguments, for example:

    cordova plugin add cordova-plugin-firebasex-core --variable ANDROID_FIREBASE_INSTALLATIONS_VERSION=17.0.0

Or you can specify them as plugin variables in your `config.xml`, for example:

```xml
<plugin name="cordova-plugin-firebasex-core" spec="latest">
    <variable name="ANDROID_FIREBASE_INSTALLATIONS_VERSION" value="17.0.0" />
</plugin>
```

### AndroidX

This plugin has been migrated to use [AndroidX (Jetpack)](https://developer.android.com/jetpack/androidx/migrate) which is the successor to the [Android Support Library](https://developer.android.com/topic/libraries/support-library/index).

The `cordova-android@9` platform adds implicit support for AndroidX so (if you haven't already done so) you should update to this platform version:

    cordova platform rm android && cordova platform add android@latest

and enable AndroidX by setting the following preference in your `config.xml`:

    <preference name="AndroidXEnabled" value="true" />

If your project includes any plugins which are dependent on the legacy Android Support Library, you should add [cordova-plugin-androidx-adapter](https://github.com/dpa99c/cordova-plugin-androidx-adapter) to your project which will dynamically migrate any plugin code from the Android Support Library to AndroidX equivalents:

    cordova plugin add cordova-plugin-androidx-adapter

## iOS-specific

Please ensure you have the latest Xcode release version installed to build your app.

### Specifying iOS library versions

This plugin depends on various components such as the Firebase SDK which are pulled in at build-time by Cocoapods on iOS.
This plugin pins specific versions of these in [its `plugin.xml`](https://github.com/dpa99c/cordova-plugin-firebasex-core/blob/master/plugin.xml) where you can find the currently pinned iOS versions in the `<pod>`'s.

To override the version of the Firebase iOS SDK, use the `IOS_FIREBASE_SDK_VERSION` plugin variable:

    cordova plugin add cordova-plugin-firebasex-core --variable IOS_FIREBASE_SDK_VERSION=9.1.0

### Cocoapods

This plugin relies on Cordova support for the [CocoaPods dependency manager](https://cocoapods.org/) in order to satisfy the iOS Firebase SDK library dependencies.

Please make sure you have `cocoapods@>=1.11.2` installed in your iOS build environment - setup instructions can be found [here](https://cocoapods.org/).

If building your project in Xcode, you need to open `YourProject.xcworkspace` (not `YourProject.xcodeproj`) so both your Cordova app project and the Pods project will be loaded into Xcode.

### Out-of-date pods

If you receive a build error such as this:

    None of your spec sources contain a spec satisfying the dependencies: `Firebase/Core (~> 6.1.0), Firebase/Core (= 6.1.0, ~> 6.1.0)`.

Make sure your local Cocoapods repo is up-to-date by running `pod repo update` then run `pod install` in `/your_project/platforms/ios/`.

### Strip debug symbols

If your iOS app build contains too many debug symbols (i.e. because you include lots of libraries via a Cocoapods), you might get an error when you upload your binary to App Store Connect, e.g.:

    ITMS-90381: Too many symbol files

To prevent this, you can set the `IOS_STRIP_DEBUG` plugin variable which prevents symbolification of all libraries included via Cocoapods:

    cordova plugin add cordova-plugin-firebasex-core --variable IOS_STRIP_DEBUG=true

Note: if you enable this setting, any crashes that occur within libraries included via Cocoapods will not be recorded in Crashlytics or other crash reporting services.

# Firebase config setup

Download your Firebase configuration files, `GoogleService-Info.plist` for iOS and `google-services.json` for android, and place them in the root folder of your cordova project.
Check out this [firebase article](https://support.google.com/firebase/answer/7015592) for details on how to download the files.

```
- My Project/
    platforms/
    plugins/
    www/
    config.xml
    google-services.json       <--
    GoogleService-Info.plist   <--
    ...
```

Or you can set custom location for your platform configuration files using plugin variables in your `config.xml`:

```
<plugin name="cordova-plugin-firebasex-core">
    <variable name="ANDROID_FIREBASE_CONFIG_FILEPATH" value="resources/android/google-services.json" />
    <variable name="IOS_FIREBASE_CONFIG_FILEPATH" value="resources/ios/GoogleService-Info.plist" />
</plugin>
```

IMPORTANT: The Firebase SDK requires the configuration files to be present and valid, otherwise your app will crash on boot or Firebase features won't work.

# API

## Installations

Exposes API methods of the [Firebase Installations SDK](https://firebase.google.com/docs/projects/manage-installations).

### getInstallationId

[Returns the current Firebase installation ID (FID)](https://firebase.google.com/docs/projects/manage-installations#retrieve_client_identifers).

**Parameters**:

-   {function} success - callback function to call on successfully completed the function call.
    Will be passed the {string} Firebase installation ID.
-   {function} error - callback function which will be passed a {string/object} error message as an argument.

```javascript
FirebasexCore.getInstallationId(
    function (id) {
        console.log("Got installation ID: " + id);
    },
    function (error) {
        console.error("Failed to get installation ID", error);
    }
);
```

### getInstallationToken

[Returns the JWT auth token](https://firebase.google.com/docs/projects/manage-installations#retrieve-fis-token) for the current Firebase installation ID (FID).

**Parameters**:

-   {function} success - callback function to call on successfully completed the function call.
    Will be passed the {string} Firebase installation token.
-   {function} error - callback function which will be passed a {string/object} error message as an argument.

```javascript
FirebasexCore.getInstallationToken(
    function (token) {
        console.log("Got installation token: " + token);
    },
    function (error) {
        console.error("Failed to get installation token", error);
    }
);
```

### deleteInstallationId

[Deletes the current Firebase installation ID (FID)](https://firebase.google.com/docs/projects/manage-installations#delete-fid).

**Parameters**:

-   {function} success - callback function to call on successfully completed the function call.
-   {function} error - callback function which will be passed a {string/object} error message as an argument.

```javascript
FirebasexCore.deleteInstallationId(
    function () {
        console.log("Deleted installation ID");
    },
    function (error) {
        console.error("Failed to delete installation ID", error);
    }
);
```

### registerInstallationIdChangeListener

Registers a Javascript function to invoke when [Firebase Installation ID changes](https://firebase.google.com/docs/projects/manage-installations#monitor-id-lifecycle).

iOS only.

**Parameters**:

-   {function} fn - callback function to invoke when installation ID changes.
    -   Will be a passed a single {string} argument which is the new installation ID.

Example usage:

```javascript
FirebasexCore.registerInstallationIdChangeListener(function (installationId) {
    console.log("New installation ID: " + installationId);
});
```

## Miscellaneous

Functions unrelated to any specific Firebase SDK component.

### registerApplicationDidBecomeActiveListener

Registers a Javascript function to invoke when the iOS application becomes active after being in the background.

-   iOS only.

**Parameters**:

-   {function} fn - callback function to invoke when application becomes active

Example usage:

```javascript
FirebasexCore.registerApplicationDidBecomeActiveListener(function () {
    console.log("Application became active");
});
```

### registerApplicationDidEnterBackgroundListener

Registers a Javascript function to invoke when the iOS application is sent to the background.

-   iOS only.

**Parameters**:

-   {function} fn - callback function to invoke when application is sent to the background

Example usage:

```javascript
FirebasexCore.registerApplicationDidEnterBackgroundListener(function () {
    console.log("Application send to background");
});
```

### Debug mode
Enable debug mode to use DebugView.
You can find detailed information [here](https://firebase.google.com/docs/analytics/debugview?hl=es-419#android)
#### Android
1) Connect your developer Android device via USB.
2) Allow the connection on the device.
3) Open your terminal and run
   `adb devices -l`
4) If your device appears run
   `adb shell setprop debug.firebase.analytics.app PACKAGE.NAME`

Now your device is in debug Mode.

Disable it using
`adb shell setprop debug.firebase.analytics.app .none.`

#### iOS
Find information [here](https://firebase.google.com/docs/analytics/debugview?hl=es-419#android)

# Reporting issues

Before opening a bug issue, please check the [existing issues](https://github.com/dpa99c/cordova-plugin-firebasex-core/issues) to see if a similar issue already exists.

When creating a new issue:
-   Include your Cordova CLI version, platform versions, and plugin version.
-   Include full verbose console output (`cordova build <platform> --verbose`).
-   Reproduce the issue using the [example project](https://github.com/dpa99c/cordova-plugin-firebasex-test) if possible.
