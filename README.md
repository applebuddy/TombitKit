# TombitKit

[![Platforms](https://img.shields.io/badge/iOS-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_Linux_Windows-Green?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
[![Swift](https://img.shields.io/badge/Swift-5.5_5.6_5.7-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.7-Orange?style=flat-square)

## Description

- TombitKit is networking library for crypto currency trading informations written in Swift with Concurrency.
- TombitKit makes it easier to use EndPoints or WebSocket APIs from Upbit and Binance crypto currency exchanges.

<br>
<br>

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

> Xcode 11+ is required to build TombitKit using Swift Package Manager.

To integrate TombitKit into your Xcode project using Swift Package Manager, add it to the dependencies value of your `Package.swift`:

```
import PackageDescription

let package = Package(
    name: "MyLibrary",
    // 🐶 make sure that avaliable iOS version is 13+
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "MyLibrary",
            targets: ["MyLibrary"]),
    ],
    dependencies: [
        // 🐶 add codes below.
      .package(url: "https://github.com/applebuddy/TombitKit.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyLibrary",
            // 🐶  you can add dependencies to use that library in your target.
            dependencies: ["TombitKit"]),
        .testTarget(
            name: "MyLibraryTests",
            dependencies: ["MyLibrary"]),
    ]
)
```

<br>
<br>

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate TombitKit into your project manually.

<br>
<br>

### How to use TombitKit API Manager

~~~swift
import TombitKit

public class MyLibrary {
  public private(set) var text = "Hello, World!"
  public private(set) var response: UpbitAccountsListResponse?
  
  public init() {
    Task {
      do {
        guard let response = try await TombitAPIManager.shared.requestUpbitAccountsInfo(
          apiAccessKey: "",
          apiSecretKey: ""
        ) else {
          return
        }
        print("response : \(response)")
        self.response = response
      } catch {
        print("error : \(error)")
      }
    }
  }
}
~~~

<br>
<br>


## License

TombitKit is released under the MIT license.
