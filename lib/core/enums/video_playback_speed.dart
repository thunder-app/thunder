enum VideoPlayBackSpeed {
  pointTow5x(label: '0.25'),
  point5x(label: '0.5'),
  pointSeven5x(label: '0.75'),
  normal(label: '1'),
  onePointTwo5x(label: '1.25'),
  onePoint5x(label: '1.5'),
  onePointSeven5x(label: '1.75'),
  twoX(label: '2');

  const VideoPlayBackSpeed({
    required this.label,
  });

  final String label;
}
