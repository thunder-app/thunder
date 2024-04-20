enum VideoPlayBackSpeed {
  pointTow5x(label: '0.25x'),
  point5x(label: '0.5x'),
  pointSeven5x(label: '0.75x'),
  normal(label: 'normal'),
  onePointTwo5x(label: '1.25x'),
  onePoint5x(label: '1.5x'),
  onePointSeven5x(label: '1.75x'),
  twoX(label: '2x');

  const VideoPlayBackSpeed({
    required this.label,
  });

  final String label;
}
