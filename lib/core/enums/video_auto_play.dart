enum VideoAutoPlay {
  never(label: 'never'),
  always(label: 'always'),
  onwifi(label: 'onwifi');

  const VideoAutoPlay({
    required this.label,
  });

  final String label;
}
