# FileSalvage — iOS File Recovery App

A complete iOS application for detecting and restoring deleted files, photos, videos, documents, contacts, and more.

## 📋 Overview

FileSalvage provides a full-featured file recovery experience on iOS with:
- Multi-type file scanning (Photos, Videos, Documents, Contacts, Audio)
- Three scan depth modes (Quick / Deep / Full)
- Animated radar-style scan UI
- File selection with recovery chance indicators
- Multiple recovery destinations (Camera Roll, Files App, iCloud)
- Session history tracking

---

## 🗂 Project Structure

```
FileRecoveryApp/
├── Sources/
│   └── FileRecoveryApp.swift       # @main app entry point
│
├── Models/
│   └── RecoverableFile.swift       # Data models: RecoverableFile, ScanResult, RecoverySession
│
├── Services/
│   ├── FileScanner.swift           # Core scanning engine
│   └── FileRecoveryService.swift   # Recovery orchestration
│
├── ViewModels/
│   └── ScanViewModel.swift         # ObservableObject state management + RecoveryStore
│
├── Views/
│   ├── ContentView.swift           # Root navigation / state router
│   ├── HomeView.swift              # Landing screen with scan launcher
│   ├── ScanningView.swift          # Animated active scan screen
│   ├── ResultsView.swift           # Filterable file list with selection
│   └── RecoveryViews.swift         # Recovery progress, destination picker, completion
│
├── Utils/
│   └── Extensions.swift            # Color(hex:), button styles, shimmer, haptics
│
├── Resources/
│   └── Info.plist                  # App permissions & metadata
│
└── Package.swift                   # SPM configuration
```

---

## 🚀 Setup Instructions

### 1. Create Xcode Project

1. Open Xcode → New Project → iOS App
2. Product Name: `FileSalvage`
3. Interface: **SwiftUI**
4. Language: **Swift**
5. Minimum Deployment: **iOS 16.0**

### 2. Add Source Files

Copy all `.swift` files into your Xcode project groups matching the folder structure above.

### 3. Configure Info.plist

Add these keys to your `Info.plist` (required for App Store):

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>FileSalvage scans your photo library to detect and recover deleted photos and videos.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>FileSalvage saves recovered photos back to your photo library.</string>

<key>NSContactsUsageDescription</key>
<string>FileSalvage scans contacts to help recover deleted contact data.</string>
```

### 4. Enable Capabilities (Xcode → Target → Signing & Capabilities)

- ✅ **iCloud** (for iCloud Drive recovery destination)
- ✅ **Background Modes** → Background Processing
- ✅ **Photo Library** entitlement

### 5. Build & Run

Target a real device — the Photos framework requires a physical iPhone/iPad for full functionality.

---

## 🏗 Architecture

### MVVM Pattern

```
View ←──────→ ViewModel ←──────→ Service Layer
  │              │                    │
ContentView   ScanViewModel       FileScanner
HomeView      RecoveryStore       FileRecoveryService
ResultsView        │
                Published
                @StateObject
```

### Data Flow

```
User taps "Start Scan"
    → ScanViewModel.startScan()
    → FileScanner.startScan(depth:)
    → [async] Scans Photos, Documents, Contacts, Fragments
    → FileScannerDelegate callbacks update @Published state
    → UI re-renders reactively via SwiftUI
    → User selects files → taps Recover
    → FileRecoveryService.recoverFiles(...)
    → Progress callbacks update UI
    → RecoveryStore.addSession() persists history
```

---

## 📱 Key Features

### Scan Engine (`FileScanner.swift`)
- **Photo Library scan**: Fetches PHAssets including limited/synced sources
- **Recently Deleted album**: Accesses iOS system trash album
- **Document directories**: Scans app containers for recoverable files
- **Contacts**: Identifies potentially deleted contacts via CNContactStore
- **Fragment analysis**: Detects partially overwritten files
- **iCloud trash**: Scans iCloud Drive deleted items

### Recovery Service (`FileRecoveryService.swift`)
- Per-file-type recovery strategies
- Progress reporting with per-file granularity
- Multiple destinations: Camera Roll, Files App folder, iCloud
- Storage space validation before recovery
- Cancellable operations

### File Metadata
Each `RecoverableFile` tracks:
- File type, name, size
- Deletion timestamp
- Original path
- Recovery probability (0–100%)
- Fragment count (fragmented files harder to recover)
- PHAsset local identifier for direct media re-import

---

## 🔒 Privacy & iOS Limitations

### What IS possible on stock iOS:
| Feature | Status |
|---|---|
| Scan Photos Library | ✅ Full access with permission |
| Access Recently Deleted album | ✅ iOS 14.0+ |
| Scan app's own Documents dir | ✅ Always available |
| Recover via PHPhotoLibrary | ✅ With permission |
| iCloud Drive trash | ✅ With iCloud entitlement |
| Contacts read/restore | ✅ With permission |

### What requires special handling:
| Feature | Notes |
|---|---|
| Other apps' files | ❌ iOS sandbox prevents this |
| SMS/iMessage recovery | ⚠️ Only from backups |
| Low-level storage scan | ❌ Not available on stock iOS |
| Full disk image analysis | ❌ Requires macOS + iTunes backup |

### For deeper recovery (backup-based):
To recover files beyond what iOS exposes, process iTunes/Finder backups on macOS using the backup path:
```
~/Library/Application Support/MobileSync/Backup/
```

---

## 🎨 Design System

| Token | Value |
|---|---|
| Background | `#0A0E1A` |
| Surface | `#141928` |
| Border | `#2A3352` |
| Primary | `#4ECDC4` |
| Text Primary | `#FFFFFF` |
| Text Muted | `#8892A4` |
| Success | `#10B981` |
| Warning | `#F59E0B` |
| Error | `#FF6B6B` |

---

## 📦 Dependencies

Zero external dependencies — built entirely with:
- **SwiftUI** — UI framework
- **Photos (PhotoKit)** — Media library access
- **Contacts (ContactsUI)** — Address book access
- **Foundation** — File system, networking
- **Combine** — Reactive state (via @Published)

---

## 🧪 Testing

```swift
// Example unit test for RecoverableFile
import XCTest
@testable import FileRecoveryApp

class RecoverableFileTests: XCTestCase {
    func testFormattedSize() {
        let file = RecoverableFile(name: "test.jpg", fileType: .photo, size: 1_500_000)
        XCTAssertEqual(file.formattedSize, "1.5 MB")
    }

    func testRecoveryChanceLabel() {
        let excellent = RecoverableFile(name: "a.jpg", fileType: .photo, size: 100, recoveryChance: 0.95)
        XCTAssertEqual(excellent.recoveryChanceLabel, "Excellent")

        let low = RecoverableFile(name: "b.jpg", fileType: .photo, size: 100, recoveryChance: 0.1)
        XCTAssertEqual(low.recoveryChanceLabel, "Low")
    }
}
```

---

## 📄 License

MIT License — free to use and modify for personal and commercial projects.
