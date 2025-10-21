# DeliveryXOApp - Restaurant Owner iOS App

iOS application for restaurant owners to onboard their restaurants and manage menus on the DeliveryX platform.

## Overview

DeliveryXOApp is a native iOS application built with Swift and UIKit that allows restaurant owners to:
- Create and manage restaurant profiles
- Set up locations with operating hours
- Build menus with collections and products
- Upload product images
- Submit menus for approval
- Manage product availability

## Features

### 5-Step Onboarding Flow

1. **Store Setup** - Create restaurant with name, description, logo, and phone
2. **Location Setup** - Add physical location with address and operating hours (7 days/week)
3. **Collection Selection** - Choose menu categories from 10 predefined options
4. **Product Creation** - Add products with photos, prices, descriptions, and categories
5. **Review & Submit** - Review complete menu and submit for approval

### Post-Approval Management

- View menu status (draft, pending, published)
- Toggle product availability without re-approval
- View products organized by collection

## Technology Stack

### iOS

- **Language:** Swift 5.0
- **Min iOS Version:** 15.0
- **UI Framework:** UIKit (Programmatic UI)
- **Architecture:** MVC pattern
- **Dependency Manager:** CocoaPods

### Dependencies

| Pod | Version | Purpose |
|-----|---------|---------|
| Alamofire | ~> 5.8 | HTTP networking |
| SwiftyJSON | ~> 5.0 | JSON parsing |
| SDWebImage | ~> 5.18 | Async image loading & caching |
| SnapKit | ~> 5.6 | Auto Layout DSL |
| SVProgressHUD | ~> 2.3 | Loading indicators |
| YPImagePicker | ~> 5.3 | Image picker with camera |

### Backend Integration

- **API Base URL:** `http://localhost/api/v1` (development)
- **Services:**
  - Restaurant Service (Store & Location)
  - Menu Service (Menu, Collection, Product)
  - Approval Service (Menu approval workflow)
  - Media Service (S3 image uploads)

## Project Structure

```
DeliveryXOApp/
├── Models/                          # Data models (Codable)
│   ├── Store.swift
│   ├── Location.swift
│   ├── OperatingHours.swift
│   ├── Menu.swift
│   ├── Collection.swift
│   └── Product.swift
├── Services/                        # API service layer
│   ├── APIClient.swift              # Generic HTTP client
│   ├── RestaurantService.swift      # Store & Location APIs
│   ├── MenuService.swift            # Menu, Collection, Product APIs
│   └── MediaService.swift           # Image upload to S3
├── ViewControllers/
│   └── Onboarding/                  # 5-step onboarding flow
│       ├── StoreSetupViewController.swift
│       ├── LocationSetupViewController.swift
│       ├── CollectionSelectionViewController.swift
│       ├── ProductCreationViewController.swift
│       └── ReviewSubmitViewController.swift
├── Utils/
│   └── Constants.swift              # App constants
└── Resources/
    ├── Assets.xcassets              # Images, colors, app icons
    ├── LaunchScreen.storyboard      # Launch screen
    └── Info.plist                   # App configuration
```

## Quick Start

### Prerequisites

- macOS 13.0+ (Ventura or later)
- Xcode 14.0+
- CocoaPods 1.12+
- Backend services running locally

### Installation

```bash
# 1. Navigate to project
cd /Users/fahdayoubi/dev/deliveryx/oapp/DeliveryXOApp

# 2. Install dependencies
pod install

# 3. Open workspace
open DeliveryXOApp.xcworkspace
```

### Running the App

```bash
# 1. Start backend services
cd /Users/fahdayoubi/dev/deliveryx/oapp
docker-compose up -d

# 2. In Xcode:
# - Select iPhone 15 Pro simulator
# - Press Cmd + R to run
```

**See [SETUP.md](./SETUP.md) for detailed setup instructions.**

## API Integration

### Key Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/stores` | POST | Create restaurant store |
| `/stores/{id}/locations` | POST | Add location |
| `/locations/{id}/operating-hours` | PUT | Set hours |
| `/locations/{id}/menus` | POST | Create draft menu |
| `/menus/{id}/collections` | POST | Add collection |
| `/locations/{id}/products` | POST | Create product |
| `/menus/{id}/products` | POST | Add product to menu |
| `/menus/{id}/submit` | POST | Submit for approval |
| `/menus/{id}` | GET | Get complete menu |
| `/products/{id}/availability` | PUT | Toggle availability |
| `/media/upload-url` | POST | Generate S3 URL |

### Data Models

All models use Codable with proper snake_case ↔ camelCase conversion:

- `Store` - Restaurant information
- `Location` - Physical location with coordinates
- `OperatingHours` - Hours for each day of week
- `Menu` - Menu with status workflow
- `Collection` - Menu category (Pizzas, Burgers, etc.)
- `Product` - Menu item with price and description

## Development

### Code Style

- Swift naming conventions
- MVC architecture
- Programmatic Auto Layout
- Result-based error handling
- Completion handler pattern

### Adding New Features

1. Add model in `Models/`
2. Add API methods in appropriate `Service`
3. Create ViewController in `ViewControllers/`
4. Wire up navigation and actions

### Testing

```bash
# Run tests
# In Xcode: Cmd + U

# Or via command line:
xcodebuild test -workspace DeliveryXOApp.xcworkspace \
  -scheme DeliveryXOApp \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

## Backend Requirements

### Services Must Be Running

```bash
# Check status
docker ps

# Should show:
# - deliveryx-traefik (port 80)
# - deliveryx-restaurant (port 8081)
# - deliveryx-menu (port 8082)
# - deliveryx-approval (port 8083)
# - deliveryx-media (port 8084)
# - deliveryx-postgres (port 5432)
```

### Test Backend

```bash
# Test API reachability
curl http://localhost/api/v1/stores

# Run Postman tests
cd /Users/fahdayoubi/dev/deliveryx/oapp/docs
newman run DeliveryX-API-Collection.postman_collection.json \
  -e DeliveryX-Environment.postman_environment.json
```

## Troubleshooting

### Common Issues

**1. Build Error: "No such module 'Alamofire'"**

```bash
pod deintegrate
pod install
```

Restart Xcode and open `.xcworkspace`.

**2. Signing Error**

Add your Apple ID in Xcode → Settings → Accounts

**3. Backend Connection Failed**

```bash
# Verify backend running
docker-compose ps

# Check logs
docker logs deliveryx-traefik

# Restart services
docker-compose restart
```

**4. Simulator Issues**

```bash
# Reset simulator
xcrun simctl erase all

# Kill and restart
killall Simulator
```

## File Count

- **6** Data Models
- **4** Service Classes
- **5** View Controllers
- **1** Utility File
- **2** App Lifecycle Files
- **3** Resource Files

**Total:** 21 Swift files

## Architecture Decisions

### Why UIKit instead of SwiftUI?

- Greater control over layouts
- Better suited for complex forms
- More mature ecosystem
- Easier CocoaPods integration

### Why MVC?

- Simple and straightforward
- Easy to understand for new developers
- Sufficient for app complexity
- Quick iteration

### Why CocoaPods instead of SPM?

- Better support for YPImagePicker
- Proven stability
- Wider pod ecosystem
- Easier debugging

## Documentation

- **[SETUP.md](./SETUP.md)** - Detailed setup instructions
- **[ios-ui-onboarding-design.md](../stories/todo/ios-ui-onboarding-design.md)** - UI design and API specs
- **Backend API Docs** - See Postman collection in `/docs`

## Current Status

✅ **Scaffolding Complete**
- All models created
- All services implemented
- All view controllers stubbed
- Navigation flow complete
- API integration ready

🔨 **TODO: UI Implementation**
- Add Auto Layout constraints
- Create custom UI components
- Add form validation
- Implement image pickers
- Style buttons and text fields

## Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit for review

## License

Copyright © 2025 DeliveryX. All rights reserved.
