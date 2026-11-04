enum AuthStatus { idle, loading, failure, otpSent, authenticated }

class AuthState {
  final AuthStatus status;
  final bool isLoggedIn;
  final String email;
  final String displayName;
  final String? errorMessage;
  final int otpSecondsLeft;
  final Set<String> selectedGenres;
  final Set<String> selectedArtistIds;

  const AuthState({
    this.status = AuthStatus.idle,
    this.isLoggedIn = false,
    this.email = '',
    this.displayName = '',
    this.errorMessage,
    this.otpSecondsLeft = 0,
    this.selectedGenres = const {},
    this.selectedArtistIds = const {},
  });

  bool get isLoading => status == AuthStatus.loading;

  int get tasteSelectionCount =>
      selectedGenres.length + selectedArtistIds.length;

  AuthState copyWith({
    AuthStatus? status,
    bool? isLoggedIn,
    String? email,
    String? displayName,
    String? errorMessage,
    bool clearError = false,
    int? otpSecondsLeft,
    Set<String>? selectedGenres,
    Set<String>? selectedArtistIds,
  }) {
    return AuthState(
      status: status ?? this.status,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      otpSecondsLeft: otpSecondsLeft ?? this.otpSecondsLeft,
      selectedGenres: selectedGenres ?? this.selectedGenres,
      selectedArtistIds: selectedArtistIds ?? this.selectedArtistIds,
    );
  }
}
