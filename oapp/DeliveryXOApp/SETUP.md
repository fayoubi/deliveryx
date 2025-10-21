# DeliveryXOApp - Complete Setup Guide

## Exact Steps to Open and Run the Project in Xcode

Follow these steps precisely to create the Xcode project and run the app in the iOS Simulator.

---

## Prerequisites

- ✅ macOS 13.0 (Ventura) or later
- ✅ Xcode 14.0 or later (from App Store)
- ✅ CocoaPods installed
- ✅ Backend services running

### Install CocoaPods (if not installed)

```bash
sudo gem install cocoapods
```

Verify installation:
```bash
pod --version
# Should output: 1.12.0 or higher
```

---

## Step 1: Create Xcode Project

### 1.1 Open Xcode

Launch Xcode from Applications or Spotlight.

### 1.2 Create New Project

1. **File → New → Project** (or `Cmd + Shift + N`)
2. Choose template:
   - Select **iOS** tab
   - Click **App**
   - Click **Next**

### 1.3 Configure Project

Enter the following details:

| Field | Value |
|-------|-------|
| Product Name | `DeliveryXOApp` |
| Team | *Leave blank or select your team* |
| Organization Identifier | `com.deliveryx` |
| Bundle Identifier | `com.deliveryx.DeliveryXOApp` |
| Interface | **Storyboard** |
| Language | **Swift** |
| Storage | **None** |
| ☐ Use Core Data | *Unchecked* |
| ☐ Include Tests | *Checked* |

Click **Next**.

### 1.4 Save Location

**IMPORTANT:** Navigate to exactly this location:

```
/Users/fahdayoubi/dev/deliveryx/oapp/
```

**Save** the project here. Xcode will create a `DeliveryXOApp` folder.

### 1.5 Close Xcode

Close Xcode completely (`Cmd + Q`). We'll reopen it after setting up CocoaPods.

---

## Step 2: Replace Files with Scaffolding

The scaffolding has already created all necessary files. We need to replace Xcode's default files with our pre-built code.

### 2.1 Navigate to Project Directory

```bash
cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp
```

### 2.2 Verify Files Exist

```bash
ls -la DeliveryXOApp/
```

You should see:
```
AppDelegate.swift
SceneDelegate.swift
Info.plist
LaunchScreen.storyboard
Assets.xcassets/
Models/
Services/
ViewControllers/
Utils/
```

### 2.3 Check Xcode Project Exists

```bash
ls -la *.xcodeproj
```

You should see: `DeliveryXOApp.xcodeproj`

---

## Step 3: Add Files to Xcode Project

### 3.1 Open Xcode Project

```bash
open DeliveryXOApp.xcodeproj
```

### 3.2 Add Source Files

In Xcode:

1. **Right-click** on `DeliveryXOApp` folder (blue icon) in left sidebar
2. Select **Add Files to "DeliveryXOApp"...**
3. Navigate to `/Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp/DeliveryXOApp`
4. Select these folders:
   - ☑️ `Models`
   - ☑️ `Services`
   - ☑️ `ViewControllers`
   - ☑️ `Utils`
5. **Options at bottom:**
   - ☑️ **Copy items if needed** (checked)
   - ☑️ **Create groups** (selected)
   - ☑️ **Add to targets: DeliveryXOApp** (checked)
6. Click **Add**

### 3.3 Replace Default Files

Delete the default ViewController:
1. Find `ViewController.swift` in left sidebar
2. Right-click → **Delete**
3. Choose **Move to Trash**

Replace AppDelegate and SceneDelegate:
1. Select `AppDelegate.swift` in sidebar
2. Press `Delete` key → **Move to Trash**
3. Repeat for `SceneDelegate.swift`
4. Right-click `DeliveryXOApp` folder → **Add Files to "DeliveryXOApp"...**
5. Select `AppDelegate.swift` and `SceneDelegate.swift`
6. **Options:** ☑️ Copy items if needed, ☑️ Add to targets
7. Click **Add**

### 3.4 Verify Project Structure

Your Xcode project should now show:

```
DeliveryXOApp/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Models/
│   ├── Store.swift
│   ├── Location.swift
│   ├── OperatingHours.swift
│   ├── Menu.swift
│   ├── Collection.swift
│   └── Product.swift
├── Services/
│   ├── APIClient.swift
│   ├── RestaurantService.swift
│   ├── MenuService.swift
│   └── MediaService.swift
├── ViewControllers/
│   └── Onboarding/
│       ├── StoreSetupViewController.swift
│       ├── LocationSetupViewController.swift
│       ├── CollectionSelectionViewController.swift
│       ├── ProductCreationViewController.swift
│       └── ReviewSubmitViewController.swift
├── Utils/
│   └── Constants.swift
├── Assets.xcassets
├── LaunchScreen.storyboard
└── Info.plist
```

### 3.5 Close Xcode Again

Close Xcode (`Cmd + Q`) before installing CocoaPods.

---

## Step 4: Install CocoaPods Dependencies

### 4.1 Navigate to Project Root

```bash
cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp
```

### 4.2 Verify Podfile Exists

```bash
cat Podfile
```

Should show dependencies for Alamofire, SDWebImage, SnapKit, etc.

### 4.3 Install Pods

```bash
pod install
```

**Expected output:**
```
Analyzing dependencies
Downloading dependencies
Installing Alamofire (5.8.1)
Installing SDWebImage (5.18.11)
Installing SnapKit (5.6.0)
Installing SVProgressHUD (2.3.1)
Installing SwiftyJSON (5.0.2)
Installing YPImagePicker (5.3.0)
Generating Pods project
Integrating client project

[✓] Pod installation complete! There are 6 dependencies from the Podfile.
```

### 4.4 Verify Workspace Created

```bash
ls -la *.xcworkspace
```

Should show: `DeliveryXOApp.xcworkspace`

---

## Step 5: Open Project in Xcode

**CRITICAL:** From now on, **always open the .xcworkspace file**, never the .xcodeproj file.

### 5.1 Open Workspace

```bash
open DeliveryXOApp.xcworkspace
```

Or from Xcode:
- File → Open...
- Navigate to `/Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp`
- Select `DeliveryXOApp.xcworkspace`
- Click **Open**

### 5.2 Verify Pods Integration

In Xcode left sidebar, you should now see:
- `DeliveryXOApp` (your app)
- `Pods` (dependencies)

---

## Step 6: Configure Build Settings

### 6.1 Select Project

1. Click `DeliveryXOApp` (blue icon) at top of left sidebar
2. Select `DeliveryXOApp` under **TARGETS** (not PROJECTS)

### 6.2 Signing & Capabilities

1. Click **Signing & Capabilities** tab
2. **Automatically manage signing**: ☑️ Checked
3. **Team**: Select your Apple ID or leave blank (will prompt later)

### 6.3 Build Settings

1. Click **Build Settings** tab
2. Search for "iOS Deployment Target"
3. Ensure it's set to **iOS 15.0**

---

## Step 7: Start Backend Services

### 7.1 Open New Terminal

Keep Xcode open, open a new Terminal window.

### 7.2 Navigate to Backend

```bash
cd /Users/fahdayoubi/dev/deliveryx/oapp
```

### 7.3 Start Docker Services

```bash
docker-compose up -d
```

### 7.4 Verify Services Running

```bash
docker ps
```

Should show 6 containers running:
- `deliveryx-traefik` (port 80)
- `deliveryx-restaurant` (port 8081)
- `deliveryx-menu` (port 8082)
- `deliveryx-approval` (port 8083)
- `deliveryx-media` (port 8084)
- `deliveryx-postgres` (port 5432)

### 7.5 Test API

```bash
curl http://localhost/api/v1/stores
```

Should return: `[]` (empty array) or existing stores.

---

## Step 8: Build the App

### 8.1 Select Simulator

In Xcode toolbar (top):
1. Click device selector (shows "iPhone 15 Pro" or similar)
2. Choose any iOS 15.0+ simulator:
   - **iPhone 15 Pro** (recommended)
   - iPhone 14
   - iPhone SE (3rd generation)

### 8.2 Build

Press `Cmd + B` or **Product → Build**

**First build may take 2-3 minutes** (compiling pods).

### 8.3 Check for Errors

Build should succeed with:
```
Build Succeeded
```

If you see errors, check:
- All files added to target
- Pods properly installed
- Workspace (not project) is open

---

## Step 9: Run the App

### 9.1 Run in Simulator

Press `Cmd + R` or **Product → Run**

### 9.2 Wait for Simulator

- iOS Simulator will launch (takes 30-60 seconds first time)
- App will install
- App will launch automatically

### 9.3 Verify App Launched

You should see the first onboarding screen:
- Title: "Set Up Your Restaurant"
- Form fields for restaurant details
- A "Continue" button at bottom

---

## Exact Commands Summary

Here's the complete command sequence:

```bash
# 1. Navigate to project
cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp

# 2. Install pods
pod install

# 3. Open workspace in Xcode
open DeliveryXOApp.xcworkspace

# In another terminal:

# 4. Start backend
cd /Users/fahdayoubi/dev/deliveryx/oapp
docker-compose up -d

# 5. Verify backend
curl http://localhost/api/v1/stores

# Back in Xcode:
# 6. Select simulator (iPhone 15 Pro)
# 7. Press Cmd + R to run
```

---

## Troubleshooting

### Error: "No such module 'Alamofire'"

**Solution:**
```bash
cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp
pod deintegrate
pod install
```

Then restart Xcode and open `.xcworkspace` file.

### Error: "Signing for 'DeliveryXOApp' requires a development team"

**Solution:**
1. Xcode → Settings → Accounts
2. Add your Apple ID (free account works)
3. Project → Signing & Capabilities → Team → Select your account

### Build Fails: "Missing file"

**Solution:**
1. Check all Swift files are added to target:
   - Select file in sidebar
   - Right sidebar → Target Membership
   - Ensure "DeliveryXOApp" is checked

### Simulator Doesn't Launch

**Solution:**
```bash
# Reset simulator
xcrun simctl erase all

# Restart Xcode
killall Xcode
```

### Backend Not Responding

**Solution:**
```bash
# Check if running
docker ps

# Restart services
docker-compose restart

# Check logs
docker logs deliveryx-traefik
```

---

## Project Structure in Xcode

After setup, your Xcode workspace will look like:

```
DeliveryXOApp.xcworkspace
├── DeliveryXOApp (Target)
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   ├── Models/ (6 files)
│   ├── Services/ (4 files)
│   ├── ViewControllers/Onboarding/ (5 files)
│   ├── Utils/ (1 file)
│   └── Resources/
└── Pods (Dependencies)
    ├── Alamofire
    ├── SDWebImage
    ├── SnapKit
    ├── SVProgressHUD
    ├── SwiftyJSON
    └── YPImagePicker
```

---

## What Happens When You Run

1. **Launch Screen** appears (blue "DeliveryX" text)
2. **StoreSetupViewController** loads
3. App connects to `http://localhost/api/v1`
4. Ready for onboarding flow!

---

## Success Criteria

✅ You're ready when:
1. Xcode opens `DeliveryXOApp.xcworkspace` without errors
2. Build succeeds (`Cmd + B`)
3. App runs in simulator (`Cmd + R`)
4. First screen shows "Set Up Your Restaurant"
5. Backend responds to `curl http://localhost/api/v1/stores`

---

## Next Steps

- Start onboarding flow by filling out the restaurant form
- Test full flow: Store → Location → Collections → Products → Review → Submit
- Check backend via Postman to verify data creation
- Add UI enhancements to view controllers

Happy coding! 🚀
