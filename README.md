![](header.png)

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![Platform](https://img.shields.io/cocoapods/p/Netable.svg?style=flat)](http://cocoapods.org/pods/Netable)

Modern apps interact with a lot of different APIs. Netable makes that easier by providing a simple interface for using those APIs to drive high-quality iOS and MacOS apps, built on Swift `Codable`, while still supporting non-standard and unusual APIs when need be.

- [Features](#features)
- [Usage](#usage)
    - [Standard Usage](#standard-usage)
    - [Resource Extraction](#resource-extraction)
    - [Handling Errors](#handling-errors)
    - [GraphQL Support](#graphql-support)
- [Example](#example)
   - [Full Documentation](#full-documentation)
- [Installation](#installation)
   - [Requirements](#requirements)
   - [Supporting Earlier Versions][#supporting-earlier-versions-of-ios]
- [License](#license)

## Features

Netable is built on a number of core principles we believe a networking library should follow:
- Handle the simplest REST API calls with minimal code, while still having the extensibility to decode the gnarliest responses
- Leverage Swift’s Codable protocols for automatic decoding and encoding
- Avoid monolithic networking files and avoid wrappers
- Straightforward global and local error handling
- Add a little bit of magic, but only where it goes a long way 

## Usage

### Standard Usage

#### Make a new instance of `Netable`, and pass in your base URL:

```swift
let netable = Netable(baseURL: URL(string: "https://api.thecatapi.com/v1/")!)
```
See [here](#additional-netable-instance-parameters) for information on adding additional instance parameters. 

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

#### Make your request using `async`/`await` and handle the result:

```swift
Task {
    do {
        let catImages = try await netable.request(GetCatImages())
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
    } catch {
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

#### Making a request with Combine

```swift
netable.request(GetCatImages())
    .sink { result in
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
    }.store(in: &cancellables)
```

#### Or, if you prefer good old fashioned callbacks

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

#### Canceling A Request

You're able to easily cancel a request using `.cancel()`, which you can see in action in the [AuthNetworkService](https://github.com/steamclock/netable/blob/aeo/86-new-example-project/Netable/Example/Services/AuthNetworkService.swift#L82) within the Example Project.

To cancel a task, we first need to ensure we retain a reference to the task, like so: 

```swift
 let createRequest = Task {
               let result = try await netable.request()
}

createRequest.cancel()
```

#### Additional Netable instance parameters

Within your Netable Instance, you're able to provide optional parameters beyond the `baseURL` to send additional information with each request made. These include:

- Config parameters to specify options like `globalHeaders`, your preferred `encoding/decoding` strategy, `logRedecation`, and/or `timeouts`.
- specifying a `logDestination` for the request logs
- a `retryConfiguration` to retry the request as desired if it fails.
- specifying a `requestFialureDelegate/Subject`.

```swift
  let netable = Netable(baseURL: URL(string: "https://...")!,
            config: Config(globalHeaders: ["Authentication" : "Bearer \(login.token)"]),
            logDestination: EmptyLogDestination(),
            retryConfiguration: RetryConfiguration(errors: .all, count: 3, delay: 5.0),
            requestFailureDelegate: ErrorService.shared)
```

See [AuthNetworkService](https://github.com/steamclock/netable/blob/aeo/86-new-example-project/Netable/Example/Services/AuthNetworkService.swift#L45) in the Example Project for a more detailed example.

#### Additional Request parameters

You also have the flexibility to set optional parameters to be sent along with each individual request made to an instance. Note that for duplicated parameters between an instance and an individual request, the instance's paramters will be overridden by an individual request. You can see the list of these [here](https://github.com/steamclock/netable/blob/aeo/86-new-example-project/Netable/Netable/Request.swift).

Within the Example Project, you can see an example of adding `unredactedParameterKeys` within the [LoginRequest](https://github.com/steamclock/netable/blob/aeo/86-new-example-project/Netable/Example/Requests/LoginRequest.swift) and a `jsonKeyDecodingStrategy` within the [GetUserRequest](https://github.com/steamclock/netable/blob/aeo/86-new-example-project/Netable/Example/Requests/GetUserRequest.swift).

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

    func finalize(raw: RawResource) async throws -> FinalResource {
        guard let catImage = raw.first else {
            throw NetableError.resourceExtractionError("The CatImage array is empty")
        }

        guard let url = URL(string: catImage.url) else {
            throw NetableError.resourceExtractionError("Could not build URL from CatImage url string")
        }

        return url
    }
}
```

#### Leave your network code to deal with the important stuff

```swift
Task { 
    do {
        let catUrl = try await netable.request(GetCatImages())
        guard let imageData = try? Data(contentsOf: catUrl) else {
            throw NetableError.noData
        }

        self.imageView.image = UIImage(data: imageData)
    } catch {
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
    
    func finalize(raw: RawResource) async throws -> FinalResource {
        return raw.user
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

#### Partially Decoding Arrays

Sometimes, when decoding an array of objects, you may not want to fail the entire request if some of those objects fail to decode. For example, the following `json` would fail to decode using standard decoding because the second post is missing the content.

```json
{ 
    posts: [
        { 
        "title": "Super cool cat."
        "content": "Info about a super cool cat."
        },
        {
        "title": "Even cooler cat."
        }
    ]
}

```

To do this, you can set your Request's `arrayDecodeStrategy` to `.lossy` to return any elements that succeed to decode.

```swift
struct Post: {
   let title: String
   let content: String
}

struct GetPostsRequests: {
typealias RawResource: SmartUnwrap<[Post]>
typealias FinalResource: [Post]

var arrayDecodingStrategy: ArrayDecodingStrategy: { return .lossy }
}
```

Note that this will only work if your `RawResource` is `RawResource: Sequence` or `RawResource: SmartUnwrap<Sequence>`. For better support of decoding nested, lossy arrays we recommend checking out [Better Codable](https://github.com/marksands/BetterCodable). Also, at this time, Netable doesn't support partial decoding for GraphQL requests.

#### Create a LossyArray directly within your object

Using `.lossy` as our `arrayDecodingStrategy` works well for objects that are being decoded as an array. We've added support to allow for partial decoding of objects that _contain_ arrays.

```swift
struct User: Decodable {
    let firstName: String
    let lastName: String
    let bio: String
    let additionalInfo: LossyArray<AdditionalInfo>
}

struct UserLoginData: Decodable, Hashable {
    let age: Int
    let gender: String
    let nickname: String
}
```

Note: to access the LossyArray's elements, you have to access `.element` within, like so.

```swift
    ForEach(user.additionalInfo.element, id: \.self) {
    // ..
    }
```

### Handling Errors

In addition to handling errors locally that are thrown, or returned through `Result` objects, we provide two ways to handle errors globally. These can be useful for doing things like presenting errors in the UI for common error cases across multiple requests, or catching things like failed authentication requests to clear a stored user.

#### Using `requestFailureDelegate`

See [GlobalRequestFailureDelegate](https://github.com/steamclock/netable/blob/aeo/86-new-example-project/Netable/Example/Services/ErrorService.swift) in the Example project for a more detailed example.

```swift
extension GlobalRequestFailureDelegateExample: RequestFailureDelegate {
    func requestDidFail<T>(_ request: T, error: NetableError) where T : Request {
        let alert = UIAlertController(title: "Uh oh!", message: error.errorDescription, preferredStyle: .alert)
        present(alert, animated: true)
    }
}
```

#### Using `requestFailurePublisher`

If you prefer `Combine`, you can subscribe to this publisher to receive `NetableErrors` from elsewhere in your app.

See [GlobalRequestFailurePublisher](https://github.com/steamclock/netable/blob/aeo/86-new-example-project/Netable/Example/Services/AuthNetworkService.swift#L34) in the Example project for a more detailed example.

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

```swift
struct CoolCat {
    let name: String
    let breed: String
}

struct Cat {
    let name: String
}

struct GetCatRequest: Request {
typealias RawResource: CoolCat
typealias FallbackResource: Cat

\\
}
```

See [FallbackDecoderViewController](https://github.com/steamclock/netable/blob/aeo/86-new-example-project/Netable/Example/Requests/GetVersionRequest.swift) in the Example project for a more detailed example.

### GraphQL Support

While you can technically use `Netable` to manage GraphQL queries right out of the box, we've added a helper protocol to make your life a little bit easier, called `GraphQLRequest`.

```swift
struct GetAllPostsQuery: GraphQLRequest {
    typealias Parameters = Empty
    typealias RawResource = SmartUnwrap<[Post]>
    typealias FinalResource = [Post]

    var source = GraphQLQuerySource.resource("GetAllPostsQuery")
}
```

See [UpdatePostsMutation](https://github.com/steamclock/netable/blob/aeo/86-new-example-project/Netable/Example/Requests/GraphQL/UpdatePostsMutation.swift) in the Example Project for a more detailed example. Note that by default it's important that your `.graphql` file's name matches _exactly_ with your request.

We recommend using a tool like [Postman](https://www.postman.com/) to document and test your queries. Also note that currently, shared fragments are not supported.

## Example

### Full Documentation

[In-depth documentation](https://steamclock.github.io/netable/) is provided through Jazzy and GitHub Pages.  

## Installation

### Requirements

- iOS 15.0+
- MacOS 10.15+
- Xcode 11.0+

Netable is available through **[Swift Package Manager](https://swift.org/package-manager/)**. To install it, follow these steps:

1. In Xcode, click **File**, then **Swift Package Manager**, then **Add Package Dependency**
2. Choose your project
3. Enter this URL in the search bar `https://github.com/steamclock/netable.git`

### Supporting earlier version of iOS

Since Netable 2.0 leverages `async`/`await` under the hood, if you want to build for iOS versions before 15.0 you'll need to use `v1.0`.

## License

Netable is available under the MIT license. See the [License.md](https://github.com/steamclock/netable/blob/master/LICENSE.md) for more info.
