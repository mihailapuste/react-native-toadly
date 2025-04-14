# Changelog

All notable changes to the Toadly module will be documented in this file.

## [Unreleased]

- Auto report js crash/exception handling on ios

### Added
- Session replay functionality for iOS
  - Captures screenshots every 1 second
  - Maintains a buffer of the last 15 seconds of images
  - Creates a GIF from these images when a user reports an issue
  - Uploads the GIF to GitHub and includes it in the issue template
  - Automatically adds a "session-replay" label to issues with replay data
- Improved GitHub issue template with collapsible sections for screenshots and session replays
- Added session replay toggle to enable/disable the feature

### Changed
- Refactored GitHubService to use DispatchGroup for better handling of multiple uploads
- Enhanced GitHubImageUploader to support different file types and custom filenames
- Updated GitHubIssueCreator to include session replay URLs in issue body

### Fixed
- Improved error handling in image upload process
- Fixed memory management in session replay by using low-resolution images

## [0.3.3] - 2025-04-13

### Added
- Mirrored features for android support

### Limitations
- Still missing screen capture for android

## [0.3.2] - 2025-04-12

### Added
- Added global error handler for JavaScript errors
- Improved template for issue submission

### Changed
- Cleanup and refactoring
- Improved logging for both JavaScript and native errors
- Enhanced error reporting with more context about crashes
- Improved and expanded example app

### Platform Support
- iOS only

## [0.3.1] - 2025-04-11

### Limitations
- iOS only

### Added
- Initial release of the Toadly module
- Show crash report dialog for user-initiated reports
- Screenshot capture for bug reports
- JavaScript error logging and reporting
