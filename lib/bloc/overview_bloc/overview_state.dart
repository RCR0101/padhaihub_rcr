abstract class OverviewState {}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class OverviewLoaded extends OverviewState {
  final int unreadCount;

  OverviewLoaded(this.unreadCount);
}

class OverviewError extends OverviewState {
  final String message;

  OverviewError(this.message);
}
