# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
