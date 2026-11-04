import 'package:flutter/material.dart';
import '../models/onboarding_slide_model.dart';

/// Mirrors the Express/JWT auth endpoints with in-memory fakes.
class AuthMockService {
  /// Demo OTP accepted by [verifyOtp] until the email service is wired in.
  static const String demoOtp = '246810';

  List<OnboardingSlideModel> getSlides() {
    return const [
      OnboardingSlideModel(
        badge: 'LOSSLESS 24-BIT HI-RES',
        title: 'Nghe đúng chất âm\nphòng thu',
        description:
            'Hàng triệu bài hát chất lượng FLAC 24-bit / 192kHz, trung thực đến từng hơi thở.',
        icon: Icons.high_quality_rounded,
      ),
      OnboardingSlideModel(
        badge: 'AI HUM-TO-SEARCH',
        title: 'Ngân nga một câu,\ntìm ra cả bài hát',
        description:
            'Chỉ cần huýt sáo hay ngâm nga giai điệu, Sonara AI nhận diện bài hát trong vài giây.',
        icon: Icons.graphic_eq_rounded,
      ),
      OnboardingSlideModel(
        badge: 'SPATIAL AUDIO 3D',
        title: 'Âm thanh vòm\nbao trùm mọi phía',
        description:
            'Đắm chìm trong không gian âm nhạc 3D được tối ưu cho tai nghe của bạn.',
        icon: Icons.surround_sound_rounded,
      ),
    ];
  }

  Future<String> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (password.length < 6) {
      throw const AuthException('Email hoặc mật khẩu không đúng');
    }
    return email.split('@').first;
  }

  Future<String> signInWithProvider(String provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return 'Người dùng $provider';
  }

  Future<void> signUp(String name, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (email.toLowerCase() == 'test@sonara.vn') {
      throw const AuthException('Email này đã được đăng ký');
    }
  }

  Future<void> sendOtp(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Future<bool> verifyOtp(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return code == demoOtp;
  }

  Future<void> requestPasswordReset(String email) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }
}

class AuthException implements Exception {
  final String message;

  const AuthException(this.message);
}
