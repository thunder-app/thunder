bool isVideoUrl(String url) {
  List<String> videoExtensions = [
    "mp4",
    "avi",
    "mkv",
    "mov",
    "wmv",
    "flv",
    "webm",
    "ogg",
    "ogv",
    "3gp",
    "mpeg",
    "mpg",
    "m4v",
    "ts",
    "vob",
  ];

  // Get the file extension from the URL
  String fileExtension = url.split('.').last.toLowerCase();

  // Check if the file extension is in the list of video extensions
  return videoExtensions.contains(fileExtension);
}
