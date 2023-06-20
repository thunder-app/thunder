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
  <a href="">
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
  <a href="">
    <img src="https://img.shields.io/github/v/release/hjiangsu/thunder" alt="Latest Release">
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
As the sole maintainer of this project, progress might be a bit slow. But hey, here's where you can make a difference! Whether you're proficient at Flutter and Dart, or just simply interested in the project, I would be absolutely thrilled if you could lend a hand and contribute.  
</p>
<p>
Your passion, contributions, and ideas would be greatly appreciated! Together, let's make this project shine. 🚀 💻
</p>
<hr />


## Releases
**Note:** As this is still in alpha and WIP, releases will happen through GitHub. There are no plans at the moment to release to Google Play store (and derivatives) or Apple's TestFlight. However, this may change in the future as more progress is made.

All releases will be held in the [Releases](https://github.com/hjiangsu/thunder/releases) section under the corresponding version.
- For iOS users, you can install Thunder using [AltStore](https://altstore.io/)
- For Android users, simply install Thunder with the provided APK file.

## Features

Thunder is currently undergoing **active development**, and it is possible that not all features have been fully implemented at this stage. Due to this, significant breaking changes may occur between versions. The next section summarizes the features that are currently implemented.

#### **Communities**

- Browse community posts
- Search for communities from the current instance (and subscribe)
- Browse subscriptions if logged in

#### **Posts**

- Voting and saving for posts and comments
- See a specific post and its associated comments
- Infinite scrolling for posts
- Infinite scrolling for comments

#### **Authentication**

- Multi-account login and switching

#### **Theme & Customization**

- Basic settings to change the view of posts on a given community/feed
- Light and dark themes available

## Roadmap

The current focus is to provide a MVP to be able to do basic tasks, including
- Ability to create posts and comments
- Improvements to accessibility
- Improvements to customizability of post views (compact, normal, expanded, etc)

## Contributing

Contributions are always welcome! To contribute potential features or bug-fixes:

1. Fork this repository
2. Apply any changes and/or additions based off an existing issue (or create a new issue for the feature/fix you are working on)
3. Create a pull request to have your changes reviewed and merged

## Building From Source

### Installing Flutter and Related Dependencies

Thunder is developed with Flutter, and is built to support both iOS and Android.

To build the app from source, a few steps are required.

1. Set up and install Flutter.
   - For more information, visit https://docs.flutter.dev/get-started/install.
2. Clone this repository and fetch the dependencies using `flutter pub get`
3. Run the build script using `dart scripts/build.dart`, which will build both the iOS and Android release versions

## Conventions

While there are no specific conventions that must be followed, do try to follow best practices whenever possible.

Suggestions are always welcome to improve the code quality and architecture of the app!

## Related Packages

Thunder uses the following packages and libraries under the hood. This is not an exhaustive list.

### Custom Built Libraries

[lemmy-dart](https://github.com/hjiangsu/lemmy-dart) - custom-built Lemmy library built in Dart
