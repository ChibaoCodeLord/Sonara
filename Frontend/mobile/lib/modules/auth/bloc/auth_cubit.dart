import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_mock_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthMockService _service;
  Timer? _otpTimer;

  AuthCubit({AuthMockService? service})
      : _service = service ?? AuthMockService(),
        super(const AuthState());

  static const int otpResendSeconds = 60;
  static const int minTasteSelections = 3;

  Future<bool> signIn(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final name = await _service.signIn(email, password);
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        isLoggedIn: true,
        email: email,
        displayName: name,
      ));
      return true;
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
      return false;
    }
  }

  Future<bool> signInWithProvider(String provider) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final name = await _service.signInWithProvider(provider);
    emit(state.copyWith(
      status: AuthStatus.authenticated,
      isLoggedIn: true,
      displayName: name,
    ));
    return true;
  }

  Future<bool> signUp(String name, String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await _service.signUp(name, email, password);
      await _service.sendOtp(email);
      emit(state.copyWith(
        status: AuthStatus.otpSent,
        email: email,
        displayName: name,
      ));
      _startOtpCountdown();
      return true;
    } on AuthException catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: e.message));
      return false;
    }
  }

  Future<void> resendOtp() async {
    if (state.otpSecondsLeft > 0) return;
    await _service.sendOtp(state.email);
    _startOtpCountdown();
  }

  Future<bool> verifyOtp(String code) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    final ok = await _service.verifyOtp(code);
    if (ok) {
      _otpTimer?.cancel();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        isLoggedIn: true,
        otpSecondsLeft: 0,
      ));
    } else {
      emit(state.copyWith(
        status: AuthStatus.failure,
        errorMessage: 'Mã OTP không chính xác, vui lòng thử lại',
      ));
    }
    return ok;
  }

  Future<void> requestPasswordReset(String email) =>
      _service.requestPasswordReset(email);

  void clearError() {
    emit(state.copyWith(status: AuthStatus.idle, clearError: true));
  }

  void toggleGenre(String genre) {
    final genres = {...state.selectedGenres};
    genres.contains(genre) ? genres.remove(genre) : genres.add(genre);
    emit(state.copyWith(selectedGenres: genres));
  }

  void toggleArtist(String artistId) {
    final artists = {...state.selectedArtistIds};
    artists.contains(artistId) ? artists.remove(artistId) : artists.add(artistId);
    emit(state.copyWith(selectedArtistIds: artists));
  }

  void signOut() {
    _otpTimer?.cancel();
    emit(const AuthState());
  }

  void _startOtpCountdown() {
    _otpTimer?.cancel();
    emit(state.copyWith(otpSecondsLeft: otpResendSeconds));
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.otpSecondsLeft - 1;
      if (next <= 0) timer.cancel();
      emit(state.copyWith(otpSecondsLeft: next < 0 ? 0 : next));
    });
  }

  @override
  Future<void> close() {
    _otpTimer?.cancel();
    return super.close();
  }
}
