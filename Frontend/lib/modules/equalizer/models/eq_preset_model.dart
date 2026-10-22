class EqPresetModel {
  final String id;
  final String name;
  final List<double> gains; // 10 bands, dB in -12..12

  const EqPresetModel({
    required this.id,
    required this.name,
    required this.gains,
  });
}
