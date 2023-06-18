## Unreleased
### Added
- Update notification which should pop up whenever there is a newer GitHub release
- When logging into your account, it should prompt autofill (tested personally on iOS, but should also work in Android

### Changed
- Login code has changed to improve support for multiple logins/profiles in the future

## 0.1.1-alpha - 2023-06-16
### Added
- Switching between tabs keeps the state of the tab
- Added Sentry to allow for debugging and logging

### Changed
- Initial feed now shows a compact version of an image, rather than the full height image

### Fixed
- Fixed issue where if you log in with an instance that does not exist, the community page will indefinitely load
- Fixed issue where a community would show a loading indicator if there were too little posts within that community

## 0.1.0-alpha - 2023-06-15
### Added
- Sorting post feed by hot, active, etc.
- Tap on community name in post to view community
- Upvote, downvote, and save posts
- Seach for communities on the same instance
- Follow and unfollow communities
- Sign in to single account

### Missing Core Features
- No ability to create a post or comment
- No user notifications
- No ability to browse saved comments and posts
- No theming options
- No multi-user ability
- Missing ability to change instances when not logged in
