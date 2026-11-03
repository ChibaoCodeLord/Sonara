class SessionDeviceModel {
  final String id;
  final String name;
  final String location;
  final String lastActive;
  final bool isCurrent;

  const SessionDeviceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.lastActive,
    this.isCurrent = false,
  });
}
