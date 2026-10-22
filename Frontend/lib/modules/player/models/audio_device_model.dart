enum AudioDeviceType { headphones, phone, speaker, tv, car }

class AudioDeviceModel {
  final String id;
  final String name;
  final String detail;
  final AudioDeviceType type;

  const AudioDeviceModel({
    required this.id,
    required this.name,
    required this.detail,
    required this.type,
  });
}
