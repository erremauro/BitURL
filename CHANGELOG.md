# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][homepage] and this project adheres to 
[Semantic Versioning][versioning]

[homepage]: https://keepachangelog.com/en/1.0.0/
[versioning]: https://semver.org/spec/v2.0.0.html

## [Unreleased]

### Added

- Add success and failure icons for different resolutions

### Fixed

- Fix icons for Light and Dark mode

## [1.2.0] - 2019-10-29

### Added

- Add reverse URL Type Scheme to reverse bitly short link to their original long 
format with scheme `biturl://reverse/{bitlyURL}`

## [1.1.2] - 2019-10-29

### Fixed

- Hide the unnecessary api key check status in Preferences when the window shown 
for the first time. 

## [1.1.1] – 2019–10–29

### Added

- Check for api key validity in the Preferences

### Changed

- Hide the dock icon immediately after the configurations are confirmed in the 
Welcome Splash Page if the "Hide Dock Icon" checkbox was selected.

## [1.1.0] – 2019-10-28

### Added

- Welcome Splash Page to setup the oauth token and icon dock icon visibility

### Changed

- Project renamed to BitURL

## [1.0.0] - 2019-10-26

### Added

- URL shortening via URL Scheme Event
- Ability to hide application icon in Preferences
- Ability to se the Bitly's OAuth API Key in Preferences
- Italian localization
