# Xcode Project Setup Guide

## 1. Create New Project

1. Open Xcode
2. Select `File > New > Project`
3. Choose `iOS > App`
4. Configure project settings:
```
Project Name: CellularBridge
Organization Identifier: com.yourdomain
Interface: SwiftUI or UIKit (based on preference)
Language: Swift
```

## 2. Create Network Extension Target

1. Select `File > New > Target`
2. Choose `Network Extension`
3. Configure extension settings:
```
Product Name: CellularBridgeExtension
Organization Identifier: com.yourdomain
Language: Swift
Project: CellularBridge
Embed in Application: CellularBridge
```

## 3. Configure Capabilities

### Main App Target:
1. Select the main target in Xcode
2. Go to "Signing & Capabilities"
3. Click "+" and add:
   - Network Extensions
   - Personal VPN
   - Background Modes
   - Access WiFi Information

### Network Extension Target:
1. Select the Network Extension target
2. Go to "Signing & Capabilities"
3. Click "+" and add:
   - Network Extensions
   - App Groups (to share data between app and extension)

## 4. Create Folder Structure

Create the following folder structure in Xcode:
```
CellularBridge/
├── Source/
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   └── Info.plist
│   ├── Network/
│   │   ├── BridgeManager.swift
│   │   ├── PacketTunnel.swift
│   │   └── SecurityProvider.swift
│   ├── UI/
│   │   ├── MainViewController.swift
│   │   └── Views/
│   └── Utilities/
├── NetworkExtension/
│   ├── PacketTunnelProvider.swift
│   ├── PacketFlow.swift
│   ├── TunnelConfiguration.swift
│   ├── NetworkExtension.entitlements
│   └── Info.plist
└── Resources/
    └── Assets.xcassets
```

## 5. Configure Info.plist Files

### Main App Info.plist:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSLocalNetworkUsageDescription</key>
    <string>Required for cellular data sharing</string>
    <key>UIBackgroundModes</key>
    <array>
        <string>network-authentication</string>
        <string>network</string>
    </array>
</dict>
</plist>
```

### Network Extension Info.plist:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NEProviderClasses</key>
    <dict>
        <key>com.apple.networkextension.packet-tunnel</key>
        <string>$(PRODUCT_MODULE_NAME).PacketTunnelProvider</string>
    </dict>
</dict>
</plist>
```

## 6. Configure Entitlements

### Main App Entitlements:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider</string>
        <string>app-proxy-provider</string>
    </array>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yourdomain.cellularbridge</string>
    </array>
</dict>
</plist>
```

### Network Extension Entitlements:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider</string>
    </array>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yourdomain.cellularbridge</string>
    </array>
</dict>
</plist>
```

## 7. Initial Code Setup

Create initial files with basic implementations:

1. Main App (`AppDelegate.swift`):
```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Initialize Bridge Manager
        BridgeManager.shared.initialize()
        
        return true
    }
}
```

2. Network Extension (`PacketTunnelProvider.swift`):
```swift
import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        let settings = TunnelConfiguration().createNetworkSettings()
        setTunnelNetworkSettings(settings) { error in
            if let error = error {
                completionHandler(error)
                return
            }
            completionHandler(nil)
        }
    }
}
```

## 8. Build Configurations

1. Create development and production schemes
2. Configure build settings for both targets
3. Set up code signing:
   - Ensure you have appropriate provisioning profiles
   - Configure signing certificates
   - Set up App Groups entitlement

## 9. Test Setup

1. Create test target if not already created
2. Set up basic unit tests:
```swift
import XCTest
@testable import CellularBridge

class CellularBridgeTests: XCTestCase {
    func testBasicSetup() {
        XCTAssertNotNil(BridgeManager.shared)
    }
}
```

## 10. Run and Test

1. Select a development device (Network Extensions require a real device)
2. Build and run the main app target
3. Verify that both targets build successfully
4. Check that entitlements are properly configured
5. Test basic functionality

## Common Issues and Solutions

### 1. Signing Issues
```
Error: Missing Network Extension entitlement
Solution: Verify provisioning profiles and entitlements
```

### 2. Build Errors
```
Error: Missing capabilities
Solution: Add required capabilities in Xcode
```

### 3. Extension Not Loading
```
Error: Extension fails to load
Solution: Check Info.plist configuration and entitlements
```

## Next Steps

1. Implement core functionality
2. Set up CI/CD
3. Configure analytics
4. Add logging
5. Implement security features
