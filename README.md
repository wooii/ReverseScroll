# ReverseScroll

**ReverseScroll** is a macOS menu bar app that reverses mouse scroll direction while keeping trackpad scrolling unaffected.

## Features

- **Selective Scroll Reversal**: Reverses scrolling for the mouse only, leaving trackpad settings unchanged.
- **Minimal Design**: Simple, menu bar access with an option to quit.
- **Lightweight**: Uses under 20 MB of memory.
- **Open Source**: Free to download or build from source.

## Installation

1. **[Download the app](https://github.com/wooii/ReverseScroll/releases/latest/download/ReverseScroll.zip)**.

2. Unzip the file, move the app to your **Applications** folder, and launch it.

3. **Enable App Execution**:
   - On first launch, macOS may block the app as it’s unsigned. To allow it:
     - Go to **System Settings** > **Privacy & Security** > **Security**.
     - Click **Open Anyway** next to the ReverseScroll warning.
   - Relaunch the app, and it will prompt for Accessibility Permissions. Grant permissions within 10 seconds, or the app will close automatically.
   - After granting Accessibility Permissions, the app will add itself to **Login Items** for automatic startup at login.

## Build from source

Requires macOS 15.1+ and Xcode.

```bash
open ReverseScroll.xcodeproj
```

Press ⌘R to run. Signing is ad-hoc ("Sign to Run Locally"), so no Apple
Developer account or certificate is needed. The app runs from the menu bar;
grant Accessibility permission when prompted.

Command line:

```bash
xcodebuild -project ReverseScroll.xcodeproj -target ReverseScroll -configuration Release build
```

## License

MIT
