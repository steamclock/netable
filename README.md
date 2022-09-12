![](header.png)

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Netable.svg)](https://img.shields.io/cocoapods/v/Netable.svg) [![Platform](https://img.shields.io/cocoapods/p/Netable.svg?style=flat)](http://cocoapods.org/pods/Netable)

Modern apps interact with a lot of different APIs. Netable makes that easier by providing a simple interface for using those APIs to drive high quality iOS and MacOS apps, built on Swift `Codable`, while still supporting non-standard and unusual APIs when need be.

- [Features](#features)
- [Usage](#usage)
- [Example](#example)
- [Requirements](#requirements)
- [Installation](#installation)
- [License](#license)

## Features

Netable is built on a number of core principles we believe a networking library should follow:
- Handle the simplest REST API calls with minimal code, while still having the extensibility to decode the gnarliest responses
- Leverage Swift’s Codabale protocols for automatic decoding and encoding
- Avoid monolithic networking files and avoid wrappers
- Straightforward global and local error handling
- Add a little bit of magic, but only where it goes a long way 

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

#### Leave your network code to deal with the important stuff

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

#### Smart Unwrapping Objects

Sometimes APIs like to return the object you actually care about inside of a single level wrapper, which `Finalize` is great at dealing with, but requires a little more boilerplate code than we'd like. This is where `SmartUnwrap<>` comes in! 

Create your request as normal, but set your `RawResource = SmartUnwrap<ObjectYouCareAbout>` and `FinalResource = ObjectYourCareAbout`. You can also specify `Request.smartUnwrapKey` to avoid ambiguity when unwrapping objects from your response.

Before: 
```swift
struct UserResponse {
    let user: User
}

struct User {
    let name: String
    let email: String
}

struct GetUserRequest: Request {
    typealias Parameters: GetUserParams
    typealias RawResource: UserResponse
    typealias FinalResource: User
    
    // ...
    
    func finalize(raw: RawResource) -> Result<FinalResource, NetableError> {
        return .success(raw.user)
    }
}
```

After: 
```swift
struct User: {
    let name: String
    let email: String
}

struct GetUserRequest: Request {
    typealias Parameters: GetUserParams
    typealias RawResource: SmartUnwrap<User>
    typealias FinalResource: User
}

```

### Handling Errors

In addition to handling errors locally through the `completion` callback provided by `request()`,  we provide two ways to handle errors globally. These can be useful for doing things like presenting errors in the UI for common error cases across multiple requests, or catching things like failed authentication requests to clear a stored user.

#### Using `requestFailureDelegate`

See [GlobalRequestFailureDelegate](https://github.com/steamclock/netable/blob/master/Netable/NetableExample/ViewController/RootTabBarController.swift) in the Example project for a more detailed example.

```swift
extension GlobalRequestFailureDelegateExample: RequestFailureDelegate {
    func requestDidFail<T>(_ request: T, error: NetableError) where T : Request {
        let alert = UIAlertController(title: "Uh oh!", message: error.errorDescription, preferredStyle: .alert)
        present(alert, animated: true)
    }
}
```

#### Using `requestFailurePublisher`

If you prefer `Combine`, you can subscribe to this publisher to recieve `NetableErrors` from elsewhere in your app.

See [GlobalRequestFailurePublisher](https://github.com/steamclock/netable/blob/master/Netable/NetableExample/Repository/UserRepository.swift) in the Example project for a more detailed example.

```swift
netable.requestFailurePublisher.sink { error in
    let alert = UIAlertController(title: "Uh oh!", message: error.errorDescription, preferredStyle: .alert)
    self.present(alert, animated: true)
}.store(in: &cancellables)
```

#### Using `FallbackResource`

Sometimes, you may want to specify a backup type to try and decode your response to if the initial decoding fails, for example:
- You want to provide a fallback option for an important request that may have changed due to protocol versioning
- An API may send back different types of responses for different types of success

`Request` allows you to optionally declare a `FallbackResource: Decodable` associated type when creating your request. If you do and your request fails to decode the `RawResource`, it will try to decode your fallback resource, and if successful, throw a `NetableError.fallbackDecode` with your successful decoding.

See [FallbackDecoderViewController](https://github.com/steamclock/netable/blob/master/Netable/NetableExample/Request/VersionCheckRequest.swift) in the Example project for a more detailed example.

#### GraphQL Support

While you can technically use `Netable` to manage GraphQL queries right out of the box, we've added a couple helper protocols to make your life a little bit easier, called `GraphQLQuery` and `GraphQLMutation`.

You can see a detailed example in the example project, but note that by default it's important that your `.graphql` file's name matches _exactly_ with your request.

We recommend using a tool like [Postman](https://www.postman.com/) to document and test your queries.

### Full Documentation

[In-depth documentation](https://steamclock.github.io/netable/) is provided through Jazzy and GitHub Pages.  

## Example

To run the example project, clone the repo, and run `pod install` from inside the Example directory first.

## Requirements

- iOS 13.0+
- MacOS 10.15+
- Xcode 11.0+

## Installation

Netable is available through **[Swift Package Manager](https://swift.org/package-manager/)**. To install it, follow these steps:

1. In Xcode, click **File**, then **Swift Package Manager**, then **Add Package Dependency**
2. Choose your project
3. Enter this URL in the search bar `https://github.com/steamclock/netable.git`

## License

Netable is available under the MIT license. See the [License.md](https://github.com/steamclock/netable/blob/master/LICENSE.md) for more info.
