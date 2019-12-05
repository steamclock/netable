# SCNetworkAPI

[![CI Status](https://img.shields.io/travis/blensink192@gmail.com/SCNetworkAPI.svg?style=flat)](https://travis-ci.org/blensink192@gmail.com/SCNetworkAPI)
[![Version](https://img.shields.io/cocoapods/v/SCNetworkAPI.svg?style=flat)](https://cocoapods.org/pods/SCNetworkAPI)
[![License](https://img.shields.io/cocoapods/l/SCNetworkAPI.svg?style=flat)](https://cocoapods.org/pods/SCNetworkAPI)
[![Platform](https://img.shields.io/cocoapods/p/SCNetworkAPI.svg?style=flat)](https://cocoapods.org/pods/SCNetworkAPI)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

### Standard Usage

#### Make a new instance of `NetworkAPI`, and pass in your base URL:
```swift
let api = NetworkAPI(baseURL: URL(string: "https://api.thecatapi.com/v1/")!)
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
api.request(GetCatImages()) { result in
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

    func finalize(raw: RawResource) -> Result<FinalResource, NetworkAPIError> {
        guard let catImage = raw.first else {
            return .failure(NetworkAPIError.resourceExtractionError("The CatImage array is empty"))
        }

        guard let url = URL(string: catImage.url) else {
            return .failure(NetworkAPIError.resourceExtractionError("Could not build URL from CatImage url string"))
        }

        return .success(url)
    }
}
```

#### This can simplify your networking code:

```swift
api.request(GetCatImageURL()) { result in
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

### Error Handling

// TODO

### Logging

While creating your NetworkAPI object, you can optionally specify a log level to have some additional information be printed to the console while developing:

```

let api = NetworkAPI(baseURL: URL(string: "https://api.thecatapi.com/v1/")!, logLevel: .info)
```

There are 3 log levels provided, depending on what information you want to see:

| Level | Default | Description |
| --- | --- | --- |
| Info | Off | Request progress, responses & status |
| Error | Off | Something's gone wrong while trying to send a request. |
| None | On | Don't output any logs to the console. |

Logs are printed using `NSLog`  *without any redaction*.

## Requirements

## Installation

SCNetworkAPI is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SCNetworkAPI'
```

## Author

brendan@steamclock.com

## License

SCNetworkAPI is available under the MIT license. See the LICENSE file for more info.
