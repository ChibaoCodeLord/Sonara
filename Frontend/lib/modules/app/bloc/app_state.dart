class AppState {
  final int currentTabIndex;

  const AppState({
    this.currentTabIndex = 0,
  });

  AppState copyWith({
    int? currentTabIndex,
  }) {
    return AppState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
    );
  }
}
