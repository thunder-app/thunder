enum VideoPlayBackSpeed {
  pointTow5x(label: '0.25x', value: 0.25),
  point5x(label: '0.5x', value: 0.5),
  pointSeven5x(label: '0.75x', value: 0.75),
  normal(label: '1x', value: 1),
  onePointTwo5x(label: '1.25x', value: 1.25),
  onePoint5x(label: '1.5x', value: 1.5),
  onePointSeven5x(label: '1.75x', value: 1.75),
  twoX(label: '2x', value: 2);

  const VideoPlayBackSpeed({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}
