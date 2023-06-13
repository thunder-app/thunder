<h1 align="center">
  <br>
    <img src="./assets/logo.png" alt="Markdownify" width="200">
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
    <img src="https://img.shields.io/github/forks/hjiangsu/thunder" alt="Forks">
  </a>
    <a href="">
    <img src="https://img.shields.io/badge/platform-ios%20%7C%20android-blueviolet" alt="Platforms">
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

## Features

Thunder is currently undergoing **active development**, and it is possible that not all features have been fully implemented at this stage.

Due to this, significant breaking changes may occur between versions. The next section summarizes the features that are currently implemented.

#### **Communities**

- Browse local community's posts
- Browse your subscriptions if logged in

#### **Posts**

- See a specific post and its associated comments
- Infinite scrolling for posts
- Infinite scrolling for comments

#### **Authentication**

- Basic login functionality

#### **Theme & Customization**

- N/A

## Roadmap

The current focus is to provide a MVP to be able to do basic tasks, including
- browsing through posts, comments, communities and feeds (all, hot, new, etc.)
- authenticating with your account and seeing subscriptions
- searching for communities, and basic interaction with them (subscribing to communities, upvoting/downvoting posts, replying to comments)

## Contributing

Contributions are always welcome! To contribute potential features or bug-fixes:

1. Fork this repository
2. Apply any changes and/or additions
3. Create a pull request to have your changes reviewed and merged

## Building From Source

There are a few prerequisites in order to build and run the application locally.

### Create an Environment File

Thunder uses `.env` to store secrets, including credentials for API access. This is an example of a minimal `.env` file.

```dart
// [REQUIRED] Lemmy specific information
LEMMU_BASE_URL = ""
```

### Installing Flutter and Related Dependencies

Thunder is developed with Flutter, and is built to support both iOS and Android.

To build the app from source, a few steps are required.

1. Create a `.env` file in the root directory as described in the previous section.
2. Set up and install Flutter.
   - For more information, visit https://docs.flutter.dev/get-started/install.
3. Clone this repository and fetch the dependencies using `flutter pub get`
4. Run the appropriate build command depending on the platform.
   - iOS: `flutter build ios --release`
   - Android: `flutter build apk`

## Conventions

While there are no specific conventions that must be followed, do try to follow best practices whenever possible.

Suggestions are always welcome to improve the code quality and architecture of the app!

## Related Packages

Thunder uses the following packages and libraries under the hood. This is not an exhaustive list.

### Custom Built Libraries

[lemmy-dart](https://github.com/hjiangsu/lemmy-dart) - custom-built Lemmy library built in Dart
