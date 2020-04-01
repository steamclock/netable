![](header.png)

[![Swift Version][swift-image]][swift-url]
[![Build Status][travis-image]][travis-url]
[![License][license-image]][license-url]
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/EZSwiftExtensions.svg)](https://img.shields.io/cocoapods/v/LFAlertController.svg)  
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/Netable)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

At [Steamclock](https://steamclock.com/), we interact with a lot of different APIs. Netable makes that easier for us by providing a simple interface for using those APIs to drive high quality iOS and MacOS apps.

- [Features](#features)
- [Usage](#usage)
- [Example](#example)
- [Requirements](#requirements)
- [Installation](#installation)
- [Contributing](#contributing)
- [License](#license)

## Features

Netable is designed with a core philosophy of ensuring that developers can write simple code for simple APIS, but providing lots of options for wrangling strange or non-standard APIs.
- Every request is an independent type
    - Facilitates breaking up requests into separate files, avoiding monolithic networking classes
- Codable-based `Result` return types
    - Easy interfacing between model and controller layers
    - Reduces need for wrapper types  
- Have your request automatically convert responses to usable objects
- Easily integrates with your existing logging library, or logs to `debugPrint` by default
- Comprehensive (Robust?) error types make handling expected and unexpected errors painless

## Usage

### Standard Usage

#### Make a new instance of `Netable`, and pass in your base URL:
```swift
let netable = Netable(baseURL: URL(string: "https://api.thecatapi.com/v1/")!)
```

#### Extend `Request`
```swift
struct CatImage: Decodable {
    let id: String
    let url: String
}

struct GetCatImages: Request {
    typealias Parameters = [String: String]
    typealias RawResource = [CatImage]

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "images/search"
    }

    public var parameters: [String: String] {
        return ["mime_type": "jpg,png", "limit": "2"]
    }
}
```

#### Make your request and handle the result:

```swift
netable.request(GetCatImages()) { result in
    switch result {
    case .success(let catImages):
        if let firstCat = catImages.first,
           let url = URL(string: firstCat.url),
           let imageData = try? Data(contentsOf: url) {
            self.catsImageView1.image = UIImage(data: imageData)
        }

        if let lastCat = catImages.last,
           let url = URL(string: lastCat.url),
           let imageData = try? Data(contentsOf: url) {
            self.catsImageView2.image = UIImage(data: imageData)
        }
    case .failure(let error):
        let alert = UIAlertController(
            title: "Uh oh!",
            message: "Get cats request failed with error: \(error)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}
```

### Resource Extraction

#### Have your request object handle extracting a usable object from the raw resource

```swift
struct CatImage: Decodable {
    let id: String
    let url: String
}

struct GetCatImageURL: Request {
    typealias Parameters = [String: String]
    typealias RawResource = [CatImage]
    typealias FinalResource = URL

     // ...

    func finalize(raw: RawResource) -> Result<FinalResource, NetableError> {
        guard let catImage = raw.first else {
            return .failure(NetableError.resourceExtractionError("The CatImage array is empty"))
        }

        guard let url = URL(string: catImage.url) else {
            return .failure(NetableError.resourceExtractionError("Could not build URL from CatImage url string"))
        }

        return .success(url)
    }
}
```

#### Leaving your network code to deal with the important stuff

```swift
netable.request(GetCatImageURL()) { result in
    switch result {
    case .success(let catUrl):
        guard let imageData = try? Data(contentsOf: catUrl) else {
            return
        }

        self.imageView.image = UIImage(data: imageData)
    case .failure(let error):
        // ...
    }
}
```

### Full Documentation

[In-depth documentation]() is provided through Jazzy.  

## Example

To run the example project, clone the repo, and run `pod install` from inside the Example directory first.

## Requirements

- iOS 10.0+
- MacOS 10.15+
- Xcode 11.0+

## Installation

Netable is available through [Swift Package Manager](https://swift.org/package-manager/). To install it, follow these steps:

1. In Xcode, click **File**, then **Swift Package Manager**, then **Add Package Dependency**
2. Choose your project
3. Enter this URL in the search bar `https://github.com/steamclock/netable.git`

Netable is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Netable'
```
Then run `pod install`.

## License

Netable is available under the MIT license. See the [License.md](https://github.com/steamclock/netable/blob/master/LICENSE.md) for more info.
