enum SyncPhase { idle, syncing, synced, failed }

/// What the sync engine is doing. Offline and "changes pending" come from
/// their own providers (connection status, pending changes).
class SyncState {
  const SyncState({
    this.phase = SyncPhase.idle,
    this.lastSyncedAt,
    this.errorMessage,
    this.conflicts = 0,
  });

  final SyncPhase phase;

  /// UTC time of the last run that uploaded everything.
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  /// Conflicts resolved this session (for a one-off notice in the UI).
  final int conflicts;

  SyncState copyWith({
    SyncPhase? phase,
    DateTime? lastSyncedAt,
    String? Function()? errorMessage,
    int? conflicts,
  }) => SyncState(
    phase: phase ?? this.phase,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    conflicts: conflicts ?? this.conflicts,
  );

  @override
  bool operator ==(Object other) =>
      other is SyncState &&
      other.phase == phase &&
      other.lastSyncedAt == lastSyncedAt &&
      other.errorMessage == errorMessage &&
      other.conflicts == conflicts;

  @override
  int get hashCode => Object.hash(phase, lastSyncedAt, errorMessage, conflicts);
}
