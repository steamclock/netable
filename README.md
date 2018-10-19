# SCNetworkAPI

[![CI Status](https://img.shields.io/travis/blensink192@gmail.com/SCNetworkAPI.svg?style=flat)](https://travis-ci.org/blensink192@gmail.com/SCNetworkAPI)
[![Version](https://img.shields.io/cocoapods/v/SCNetworkAPI.svg?style=flat)](https://cocoapods.org/pods/SCNetworkAPI)
[![License](https://img.shields.io/cocoapods/l/SCNetworkAPI.svg?style=flat)](https://cocoapods.org/pods/SCNetworkAPI)
[![Platform](https://img.shields.io/cocoapods/p/SCNetworkAPI.svg?style=flat)](https://cocoapods.org/pods/SCNetworkAPI)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

Make a new instance of `NetworkAPI`, and pass in your base URL:
```
let api = NetworkAPI(baseURL: URL(string: "https://api.thecatapi.com/v1/")!)
```

Extend `Request`:
```
struct CatImage: Decodable {
    let id: String
    let url: String
}

struct GetCat: Request {
    typealias Parameters = Empty
    typealias Returning = [CatImage]

    public var method: HTTPMethod { return .get }

    public var path: String {
        return "images/search?mime_type=jpg,png"
    }
}
```

Make your request and handle the result:
```
api.request(GetCat()) { result in
    switch result {
    case .success(let cats):
        guard let cat = cats.first,
                let url = URL(string: cat.url),
                let data = try? Data(contentsOf: url) else {
            return
        }

        self.imageView.image = UIImage(data: data)
    case .failure(let error):
        debugPrint("Get cats request failed with error: \(error)")
    }
}
```

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
