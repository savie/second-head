import '../../profile/integrations/integration_authorization_store.dart';
import '../../journey/journey_data.dart';
import '../../../core/storage/recovery_snapshot_store.dart';
import 'eol_state.dart';

abstract interface class EolService {
  Future<EolImpact> prepareImpact();
  Future<void> executeFrontendClosure();
}

/// Frontend-only implementation.
///
/// This deliberately does not mutate Supabase or reinterpret lifecycle
/// semantics. It prepares an impact snapshot from existing local stores and
/// completes only the local frontend flow until a backend contract is wired.
class LocalEolService implements EolService {
  LocalEolService({
    RecoverySnapshotStore? snapshots,
    IntegrationAuthorizationStore? integrations,
  })  : _snapshots = snapshots ?? RecoverySnapshotStore.instance,
        _integrations = integrations ?? IntegrationAuthorizationStore.instance;

  final RecoverySnapshotStore _snapshots;
  final IntegrationAuthorizationStore _integrations;

  @override
  Future<EolImpact> prepareImpact() async {
    await Future.wait([
      JourneyStore.refreshFromDisk(),
      _snapshots.refreshFromDisk(),
      _integrations.refreshFromDisk(),
    ]);

    return EolImpact(
      journeyItems: shJourneyItems.length,
      relationships: _integrations.items.length,
      recoverySnapshots: _snapshots.items.length,
    );
  }

  @override
  Future<void> executeFrontendClosure() async {
    // Intentionally no destructive storage operation here.
    // EOL is not equivalent to Delete Data, and backend terminal lifecycle
    // execution belongs behind this service boundary.
  }
}
