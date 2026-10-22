import '../models/session_device_model.dart';

class SettingsMockService {
  static const List<String> qualityOptions = [
    'Tiết kiệm • 96kbps',
    'Bình thường • 160kbps',
    'Cao • 320kbps',
    'Lossless • FLAC 16-bit/44.1kHz',
    'Hi-Res • FLAC 24-bit/192kHz',
  ];

  List<SessionDeviceModel> getSessions() {
    return const [
      SessionDeviceModel(
        id: 'this_device',
        name: 'iPhone 15 Pro',
        location: 'Đà Nẵng, Việt Nam',
        lastActive: 'Đang hoạt động',
        isCurrent: true,
      ),
      SessionDeviceModel(
        id: 'macbook',
        name: 'MacBook Air • Sonara Web',
        location: 'Đà Nẵng, Việt Nam',
        lastActive: '2 giờ trước',
      ),
      SessionDeviceModel(
        id: 'ipad',
        name: 'iPad mini',
        location: 'Hà Nội, Việt Nam',
        lastActive: '3 ngày trước',
      ),
      SessionDeviceModel(
        id: 'tv',
        name: 'Android TV Phòng khách',
        location: 'Đà Nẵng, Việt Nam',
        lastActive: '1 tuần trước',
      ),
    ];
  }

  Future<void> changePassword(String current, String next) =>
      Future<void>.delayed(const Duration(milliseconds: 900));
}
