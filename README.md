# Lynx Linking Module

Native module for LynxJS that provides linking utilities.

## Android Setup

1. Copy the Android sources to your project
2. Register the module in `MainApplication.kt`:

```kotlin
override fun onCreate() {
    super.onCreate()

    com.hextok.lynxlinking.LynxLinkingAdapter().init(this)
}
```

## iOS Setup

1. Copy the iOS sources to your project
2. Register the module in your Lynx setup:

```objective-c
#import "LynxLinkingModule.h"

[globalConfig registerModule:LynxLinkingModule.class];
```

## Usage

```typescript
import LynxLinking from "lynx-js-linking";

// Open URL
await LynxLinking.openURL("https://example.com");

// Open app settings
await LynxLinking.openSettings();

// Send intent (Android) / URL scheme (iOS)
await LynxLinking.sendIntent("tel:+1234567890");

// Share text
await LynxLinking.share("Hello!", { dialogTitle: "Share" });

// Share file
await LynxLinking.share("file:///path/to/file.pdf", {
  mimeType: "application/pdf",
  dialogTitle: "Share Document",
});
```

## File Sharing Setup

### Android

Add to `AndroidManifest.xml`:

```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

Create `res/xml/file_paths.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-path name="external_files" path="." />
    <external-files-path name="external_files_path" path="." />
</paths>
```
