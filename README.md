<h1 align="center">
  <br>
    <img src="./assets/logo.png" alt="Thunder" width="200">
  <br>
  Thunder
  <br>
</h1>

<h4 align="center">
    An open source, cross-platform Lemmy client built with <a href="https://flutter.dev/" target="_blank">Flutter</a>
</h4>

<p align="center">
  <a href="https://github.com/hjiangsu/thunder/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/hjiangsu/thunder" alt="License">
  </a>
  <a href="">
    <img src="https://img.shields.io/github/stars/hjiangsu/thunder" alt="Stars">
  </a>
  <a href="">
    <img src="https://img.shields.io/github/forks/hjiangsu/thunder" alt="Forks">
  </a>
  <a href="">
    <img src="https://img.shields.io/badge/platform-ios%20%7C%20android-blueviolet" alt="Platforms">
  </a>
</p>

<p align="center">
  <a href="https://github.com/hjiangsu/thunder/releases">
    <img src="https://img.shields.io/github/v/release/hjiangsu/thunder?label=latest release" alt="Latest Release">
  </a>
  <a href="https://apt.izzysoft.de/fdroid/index/apk/com.hjiangsu.thunder">
    <img src="https://img.shields.io/endpoint?url=https://apt.izzysoft.de/fdroid/api/v1/shield/com.hjiangsu.thunder" alt="IzzyOnDroid">
  </a>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#roadmap">Roadmap</a>
 
</p>

<p align="center">
  <a href="#contributing">Contributing</a> •
  <a href="#building-from-source">Building From Source</a> •
  <a href="#conventions">Conventions</a> •
  <a href="#related-packages">Related Packages</a>
</p>

<div align="center">
  <br>
    <img src="./docs/assets/screenshot_2.png" alt="Home Feed" width="150">
    <img src="./docs/assets/screenshot_1.png" alt="Spark" width="170">
    <img src="./docs/assets/screenshot_3.png" alt="Sidebar" width="150">
  <br>
</div>

<hr />
<p>
Hey there! Just wanted to let you know that this repo is currently my personal side project to build something cool while learning about Dart and Flutter.  
</p>
<p>
Contributions to this project are always welcomed, and in fact, even strongly encouraged here! Since I am only able to work on this during my spare time, any contributions from the community is valuable. If you are a developer, feel free to tackle any issues present.
</p>
<p>
Your passion, contributions, and ideas would be greatly appreciated! Together, let's make this project shine. 🚀 💻
</p>
<hr />


## Releases
<div align="center">
 <a href="https://apt.izzysoft.de/fdroid/index/apk/com.hjiangsu.thunder">
    <img src="https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroid.png" height="80">
  </a>
  <a href="https://github.com/hjiangsu/thunder/releases/latest"><img src="https://raw.githubusercontent.com/andOTP/andOTP/master/assets/badges/get-it-on-github.png" height="80"></a>
</div>

### Android
If you are on Android, releases are available in the [Releases](https://github.com/hjiangsu/thunder/releases) section under the corresponding version. There is also an option to obtain the release through [IzzyOnDroid](https://apt.izzysoft.de/fdroid/index/apk/com.hjiangsu.thunder) if you are interested.

### iOS
If you are on iOS, there is TestFlight available through [this link](https://testflight.apple.com/join/9n8xrqvH). An alternative is to download the corresponding IPA file in the [Releases](https://github.com/hjiangsu/thunder/releases) section and install it through [AltStore](https://altstore.io/).

## Features

Thunder is currently undergoing **active development**, and it is possible that not all features have been fully implemented at this stage. Due to this, significant breaking changes may occur between versions. The next section summarizes the features that are currently implemented.

#### **Communities**

- Browsing through general (All/Local) feeds, as well as specific communities
- Ability to search for communities that are federated with the current instance
- See a list of subscriptions, and access their community posts and general information

#### **Posts & Comments**

- Voting (upvote/downvote) and save actions for posts and comments
- Infinite scrolling for posts and comments
- Ability to create a new post, and reply to posts/comments

#### **Authentication**

- Ability to log into multiple instances, and switch between them

#### **Theme & Customization**

- Basic customization for the look of posts
  - Standard/Compact views
  - Toggle full image views or a compacted image view 
  - Toggling voting and saving actions
- Light, dark, and OLED themes available

#### **Extras**
- In-app update notifications for new releases on GitHub

## Roadmap

The current focus is to provide a MVP to be able to do basic tasks, including
- Inbox features (replies, mentions, private messages)
  - Ability to view your inbox, and be able to mark them as read
  - Ability to reply to inbox messages
  - Ability to see full context of a given inbox message (navigate to post, or comment for replies and mentions)
- Improvements to accessibility services
- More customizability of post views (compact, normal, expanded, etc.)

## Contributing

Contributions are always welcome! To contribute potential features or bug-fixes:

1. Fork this repository
2. Apply any changes and/or additions based off an existing issue (or create a new issue for the feature/fix you are working on)
3. Create a pull request to have your changes reviewed and merged

## Building From Source

### Installing Flutter and Related Dependencies

Thunder is developed with Flutter, and is built to support both iOS and Android. There may be limited support on other platforms but is not guaranteed at this time (Linux, Windows, MacOS)

To build the app from source, a few steps are required.

1. Set up and install Flutter.
   - For more information, visit https://docs.flutter.dev/get-started/install.
2. Clone this repository and fetch the dependencies using `flutter pub get`
3. Generate an empty `.env` file. The `.env` file holds any credentials. At the time of writing, en empty `.env` file with a comment is all that is required.
3. Run the build script using `dart scripts/build.dart`, which will build both the iOS and Android release versions

### Building with Docker

Alternatively, you can skip the prerequisite setup and build the Android application via docker with a single command:
```
./scripts/docker-build-android.sh
```

### Developing with Docker

You can also run your local development environment for Android via the Docker container, including connecting to ADB on the host machine.
```
./scripts/docker-dev-android.sh
```

### Environment File
This is an example of the `.env` that can be used for Thunder.
```bash
# Empty Environment File
```

## Conventions

While there are no specific conventions that must be followed, do try to follow best practices whenever possible.

Suggestions are always welcome to improve the code quality and architecture of the app!

## Related Packages

Thunder uses the following packages and libraries under the hood. This is not an exhaustive list.

### Custom Built Libraries

[lemmy-dart](https://github.com/hjiangsu/lemmy-dart) - Custom Lemmy API library written in Dart.
