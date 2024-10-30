// ignore_for_file: avoid_print, file_names
import 'dart:io';

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
  print('\nFetching current version from pubspec.yaml...');
  ProcessResult ciderResult = Process.runSync('cider', ['version']);
  String version = ciderResult.stdout.toString().trim();
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

void main() {
  buildRelease();
}
