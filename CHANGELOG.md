# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [UNRELEASED]
### Added
- [74] Change Netable constructor to remove the option to directly set a URLSessionConfiguration and instead only expose the `timeout` option.
- [79] Add `requestFailedDelegate` and `requestFailedPublisher` to users to handle errors globally in addition to in `request` completion callbacks. Bumps minimum iOS version to 13.0.

## [0.10.3] - 12-01-21
### Changed
- Fixed an issue with logging successful requests that was preventing finalized data from being printed properly.
- Fixed a couple small tpyos.

## [0.10.2] - 10-08-20
### Added
- Added support for `DELETE` requests.

## [0.10.1] - 16-07-20
### Changed
- Fixed some properties in the new logging not being marked as "public".

## [0.10.0] - 16-07-20
### Added
- Requests are now automatically retried for (some) failures. The new RetryConfiguration struct controls the exact mechanisms for retrying.

### Removed
- The NotificationCenter events for request completion have been removed. For global snooping on requests, use a custom LogDestination.

### Changed
- The names and payload of some of the request related LogEvents have changed, generally to include more data on requests.
- LogEvent.requestCompleted is no longer sent for requests that fail based on non 2xx HTTP codes, just LogEvent.requestFailure. You can check for a NetableError.httpError payload if you want to log the status code or raw data.
- LogDestination is now always called on the main thread
- Default logging now logs URLs on request completion, and logs HTTP status codes for HTTP failures
- Change RequestIdentifier to be opaque

## [0.9.1] - 24-06-20
### Changed
- Fixed build on non-Apple platforms (note: only basic compliation has been tested, still might not work properly)
- Use TimeInterval instead of CFTimeInterval in public interface (shouldn't actually change API, since they are both just Double typedefs)
- Remove not-publically-exposed-and-probably-not-working capability to use encodings other than UTF8 for multipart form requests.

## [0.9.0] - 19-06-20
### Added
- Added `jsonKeyEncodingStrategy` to `Request`s, allowing custom encoding strategies for request params.
- Added `LogEvent.startupInfo`  to keep track of some debugging info while booting.

### Changed
- Changed multi-line logs that weren't printing to the console properly to single liners.
- Changed `LogEvent.message` to accept a `StaticString` instead of a `String`.
- Changed when parameters are checked for nested objects.

## [0.8.5] - 2020-05-01
### Added
- Added a new post example
- Added ability to customize the decode method for requests
- Update file headers, add some more comments to examples

### Changed
- Reworked the example project to allow for more examples to be added

## [0.8.4] - 2020-03-16
### Added
- Added support for built in logging

## [0.8.3] - 2020-03-10
### Changed
- Fixed the unit for network duration

## [0.8.2] - 2020-03-02
### Added
- Added missing error codes

## [0.8.1] - 2020-02-11
### Changed
- Lowered minimum iOS target to 11

## [0.8.0] - 2020-02-07
### Changed
- Renamed library to Netable
- Consolidated iOS and Mac targets to a single target
- Removed MockingJay and updated unit tests using OHHTTPStubs

## [0.7.0] - 2020-02-03
### Added
- Support for Swift Package Manager

## [0.6.0] - 2020-02-03
### Added
- Users can now pass in a custom url session configuration when initializing

## [0.5.0] - 2019-02-12
### Changed
- Updated Request to support a final resource type
- Updated example

### Added
- Included a final resource and finalize default implementations
- Added resourceExtractionError type to NetworkAPIError

## [UNRELEASED]
- Update documentation
- Add `cancel(request)` functionality to cancel specific requests

## [0.8.4] - 2019-22-07
- Included response data in a http error (can allow clients to display server messages)

## [0.3.0] - 2019-24-06
### Added
- Included response data in a decoding error (can allow clients to handle JSON fragments)

## [0.2.0] - 2019-29-05
### Added
- Multipart form data request
- URL encoded form data request

### Fixed
- Log notifications not fired in some cases of errors or early returns

## [0.1.0] - 2019-26-04
### Added
- Localized descriptions for errors

### Changed
- Removed Result enum in favour of Swift 5's Result type

## [0.0.1] - 2018-18-10
### Added
- Basic frameworks for iOS and macOS
