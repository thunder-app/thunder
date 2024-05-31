// ignore_for_file: avoid_print
import 'dart:io';
import 'package:thunder/globals.dart';

/// This script automatically generates the release files for the current version,
/// and stores the release files in /release directory.
void buildRelease() {
  // Check if Flutter is installed
  print('Checking if Flutter is installed...');
  ProcessResult flutterResult = Process.runSync('flutter', ['--version']);

  if (flutterResult.exitCode != 0) {
    print('Flutter is not installed. Please install Flutter and try again.');
    return;
  } else {
    print('Starting Flutter release builds for Android and iOS...');
  }

  // Get current release version
  print('\nFetching current version from globals.dart...');
  String version = currentVersion;
  print(version);

  print('\nRemoving previous build artifacts...');
  removeBuildArtifacts();

  // Build for Android
  print('\nStarting Android build...');
  ProcessResult androidResult = Process.runSync('flutter', ['build', 'apk', '--release', '--flavor', 'production', '--no-tree-shake-icons']);
  stdout.write(androidResult.stdout);
  stderr.write(androidResult.stderr);

  if (androidResult.exitCode == 0) {
    print('Android build successful!');
    createAPKFile(version);
  } else {
    print('Failed to build for Android. Error: ${androidResult.stderr}');
  }

  // Build for iOS
  print('\nStarting iOS build...');
  ProcessResult iosResult = Process.runSync('flutter', ['build', 'ios', '--release', '--flavor', 'production', '--no-tree-shake-icons']);
  stdout.write(iosResult.stdout);
  stderr.write(iosResult.stderr);

  if (iosResult.exitCode == 0) {
    print('iOS build successful!');
    createIPAFile(version);
  } else {
    print('Failed to build for iOS. Error: ${iosResult.stderr}');
  }
}

void removeBuildArtifacts() {
  Directory releaseDirectory = Directory('release');
  try {
    // Remove previous build artifacts if they exist
    releaseDirectory.deleteSync(recursive: true);
  } catch (e) {
    print(e.toString());
  } finally {
    print('Finished removing previous build artifacts...');
  }
}

void createAPKFile(String version) {
  print('\nCreating APK release file...');

  // Create the "release" directory
  Directory releaseDir = Directory('release');
  releaseDir.createSync();

  // Copy the APK file to the "release" directory and rename it
  File apkFile = File('build/app/outputs/flutter-apk/app-production-release.apk');
  String newApkPath = '${releaseDir.path}/thunder-v$version.apk';
  apkFile.copySync(newApkPath);

  print('APK file copied and renamed successfully!');
}

// Creates a IPA file from the flutter build
void createIPAFile(String version) {
  print('\nCreating IPA release file...');

  String outputDirectoryPath = 'release/Payload/';
  String runnerAppPath = 'build/ios/iphoneos/Runner.app';

  Directory outputDirectory = Directory(outputDirectoryPath);

  // Create the "Payload" directory
  Directory payloadRunnerDir = Directory('$outputDirectoryPath/Runner.app');
  payloadRunnerDir.createSync(recursive: true);

  // Copy the Runner.app directory to the "Payload" directory
  Directory runnerAppDir = Directory(runnerAppPath);

  runnerAppDir.listSync(recursive: true).forEach((file) {
    String newPath = file.path.replaceFirst(runnerAppDir.path, payloadRunnerDir.path);

    if (file is File) {
      File newFile = File(newPath);
      newFile.createSync(recursive: true);
      newFile.writeAsBytesSync(file.readAsBytesSync());
    }
  });

  // Compress the "Payload" directory into a zip file, and rename it to .ipa
  ProcessResult zipResult = Process.runSync('bash', ['-c', 'cd release && zip -r thunder-v$version.ipa Payload']);
  if (zipResult.exitCode == 0) {
    print('IPA file created successfully!');
  } else {
    print('Failed to create IPA file. Error: ${zipResult.stdout}');
  }

  // Remove Payload directory
  outputDirectory.delete(recursive: true);
}

void main() {
  buildRelease();
}
