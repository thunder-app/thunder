enum VideoAutoPlay {
  never(label: 'Never'),
  always(label: 'Always'),
  onWifi(label: 'On Wifi');

  const VideoAutoPlay({
    required this.label,
  });

  final String label;
}
