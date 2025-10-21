# DeliveryXOApp - Quick Start Guide

## Exact Commands to Open and Run in Xcode

Follow these commands in order to get the app running.

---

## ⚠️ IMPORTANT: First-Time Setup

You need to create the Xcode project file ONE TIME using Xcode GUI.

### Create Project (ONE TIME ONLY)

1. **Open Xcode**
2. **File → New → Project**
3. Choose **iOS → App**
4. Configure:
   - Product Name: `DeliveryXOApp`
   - Organization Identifier: `com.deliveryx`
   - Interface: **Storyboard**
   - Language: **Swift**
5. **Save to:** `/Users/fahdayoubi/dev/deliveryx/oapp/`
6. **Close Xcode**

---

## Step-by-Step Commands

### 1. Install CocoaPods (if needed)

```bash
sudo gem install cocoapods
```

### 2. Navigate to Project

```bash
cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp
```

### 3. Install Dependencies

```bash
pod install
```

**Expected output:**
```
Installing Alamofire (5.8.1)
Installing SDWebImage (5.18.11)
...
[✓] Pod installation complete!
```

### 4. Open Workspace in Xcode

```bash
open DeliveryXOApp.xcworkspace
```

**⚠️ CRITICAL:** Always open `.xcworkspace`, never `.xcodeproj` after running `pod install`.

### 5. Add Source Files to Xcode (ONE TIME)

In Xcode:

1. Right-click `DeliveryXOApp` folder (left sidebar)
2. **Add Files to "DeliveryXOApp"...**
3. Select folders: `Models`, `Services`, `ViewControllers`, `Utils`
4. Options:
   - ☑️ Copy items if needed
   - ☑️ Create groups
   - ☑️ Add to targets: DeliveryXOApp
5. Click **Add**

Delete default `ViewController.swift`:
- Right-click `ViewController.swift` → Delete → Move to Trash

Replace `AppDelegate.swift` and `SceneDelegate.swift`:
- Delete existing files
- Add Files → Select new `AppDelegate.swift` and `SceneDelegate.swift`

### 6. Start Backend Services

Open a new terminal:

```bash
cd /Users/fahdayoubi/dev/deliveryx/oapp
docker-compose up -d
```

Verify:
```bash
docker ps
curl http://localhost/api/v1/stores
```

### 7. Select Simulator

In Xcode toolbar:
- Click device selector
- Choose **iPhone 15 Pro**

### 8. Build & Run

Press `Cmd + R` or click ▶️ Play button

---

## After First Setup

Once you've done the above setup, future runs only require:

```bash
# Terminal 1: Start backend
cd /Users/fahdayoubi/dev/deliveryx/oapp
docker-compose up -d

# Terminal 2: Open Xcode
cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp
open DeliveryXOApp.xcworkspace
```

Then in Xcode: `Cmd + R`

---

## Complete Command Sequence

```bash
# ONE TIME SETUP (after creating Xcode project)

# 1. Navigate
cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp

# 2. Install pods
pod install

# 3. Open workspace
open DeliveryXOApp.xcworkspace

# (Add files in Xcode GUI as described above)

# 4. Start backend (new terminal)
cd /Users/fahdayoubi/dev/deliveryx/oapp
docker-compose up -d

# 5. In Xcode: Cmd + R to run
```

---

## Verify Everything Works

### ✅ Success Checklist

- [ ] `pod install` completes without errors
- [ ] `DeliveryXOApp.xcworkspace` opens in Xcode
- [ ] Xcode shows `Pods` project in sidebar
- [ ] Build succeeds (Cmd + B)
- [ ] Simulator launches
- [ ] App shows "Set Up Your Restaurant" screen
- [ ] Backend responds to `curl http://localhost/api/v1/stores`

---

## Troubleshooting

### Error: "No such module 'Alamofire'"

```bash
cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp
pod deintegrate
pod install
open DeliveryXOApp.xcworkspace
```

### Backend Not Responding

```bash
docker-compose restart
docker logs deliveryx-traefik
```

### Simulator Won't Launch

```bash
xcrun simctl erase all
killall Xcode
```

---

## Project Files

All files are located at:
```
/Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp/
```

### Directory Structure

```
DeliveryXOApp/
├── Podfile                          ← CocoaPods dependencies
├── DeliveryXOApp.xcworkspace        ← OPEN THIS FILE
├── DeliveryXOApp.xcodeproj          ← Created by you in Xcode
└── DeliveryXOApp/
    ├── Models/ (6 files)
    ├── Services/ (4 files)
    ├── ViewControllers/ (5 files)
    ├── Utils/ (1 file)
    ├── AppDelegate.swift
    ├── SceneDelegate.swift
    ├── Info.plist
    ├── LaunchScreen.storyboard
    └── Assets.xcassets
```

---

## What Happens When You Run

1. **Launch Screen:** Blue "DeliveryX" text appears
2. **StoreSetupViewController:** First onboarding screen loads
3. **API Connection:** App connects to `http://localhost/api/v1`
4. **Ready!** You can now test the onboarding flow

---

## Next Steps

- Fill out restaurant form
- Upload a logo (from Photos or Camera)
- Add location and operating hours
- Select menu collections
- Create products with images
- Review and submit menu
- Check backend data via Postman

---

## Need Help?

See detailed instructions in:
- **[SETUP.md](./SETUP.md)** - Complete setup guide
- **[README.md](./README.md)** - Project overview
- **[ios-ui-onboarding-design.md](../stories/todo/ios-ui-onboarding-design.md)** - API specs

---

## Summary

**To run the app:**
1. Create Xcode project (ONE TIME)
2. `pod install`
3. `open DeliveryXOApp.xcworkspace`
4. Add files in Xcode (ONE TIME)
5. Start backend: `docker-compose up -d`
6. Xcode: `Cmd + R`

That's it! 🚀
