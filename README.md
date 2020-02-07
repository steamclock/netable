# Netable

[![CI Status](https://img.shields.io/travis/blensink192@gmail.com/Netable.svg?style=flat)](https://travis-ci.org/blensink192@gmail.com/Netable)
[![Version](https://img.shields.io/cocoapods/v/Netable.svg?style=flat)](https://cocoapods.org/pods/Netable)
[![License](https://img.shields.io/cocoapods/l/Netable.svg?style=flat)](https://cocoapods.org/pods/Netable)
[![Platform](https://img.shields.io/cocoapods/p/Netable.svg?style=flat)](https://cocoapods.org/pods/Netable)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

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

#### Have your request object handle extracting a usable object from the raw resource:

```swift
struct CatImage: Decodable {
    let id: String
    let url: String
}

struct GetCatImageURL: Request {
    typealias Parameters = [String: String]
    typealias RawResource = [CatImage]
    typealias FinalResource = URL

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "images/search"
    }

    public var parameters: [String: String] {
        return ["mime_type": "jpg,png"]
    }

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

#### This can simplify your networking code:

```swift
netable.request(GetCatImageURL()) { result in
    switch result {
    case .success(let catUrl):
        guard let imageData = try? Data(contentsOf: catUrl) else {
            return
        }

        self.imageView.image = UIImage(data: imageData)
    case .failure(let error):
        let alert = UIAlertController(
            title: "Uh oh!",
            message: "Get cat url request failed with error: \(error)",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}
```

## Requirements

## Installation

Netable is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Netable'
```

Netable is also available through [Swift Package Manager](https://swift.org/package-manager/). To install it, follow these steps:

1. In Xcode, click **File**, then **Swift Package Manager**, then **Add Package Dependency**
2. Choose your project
3. Enter this URL in the search bar `https://github.com/steamclock/netable.git`

## Author

brendan@steamclock.com

## License

Netable is available under the MIT license. See the LICENSE file for more info.
