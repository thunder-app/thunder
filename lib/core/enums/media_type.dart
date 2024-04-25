enum MediaType { image, video, link, text }

enum MediaQuality {
  full,
  high,
  medium,
  low;

  get size {
    switch (this) {
      case MediaQuality.full:
        return null;
      case MediaQuality.high:
        return 1080;
      case MediaQuality.medium:
        return 720;
      case MediaQuality.low:
        return 480;
    }
  }
}
