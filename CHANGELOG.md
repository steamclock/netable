# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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

## [0.4.0] - 2019-22-07
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
