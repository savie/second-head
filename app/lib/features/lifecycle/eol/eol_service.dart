import '../../journey/journey_data.dart';
import '../../journey/journey_runtime_service.dart';
import '../../profile/integrations/integration_authorization_store.dart';
../../../core/state/sh_profile_state.dart';
import '../../../core/state/sh_profile_state.dart';
import '../../../core/storage/recovery_snapshot_store.dart';
import '../../auth/auth_screens.dart';
import 'eol_state.dart';

abstract interface class EolService {
  Future<EolImpact> prepareImpact();
  Future<void> executeFrontendClosure();
}

/// Runtime-backed EOL implementation.
///
/// Impact preparation remains non-destructive and uses existing local stores
/// for the review UI. Terminal execution is delegated to the backend runtime
/// authority; the UI acknowledgement is the explicit user confirmation gate.
class LocalEolService implements EolService {
  LocalEolService({
    RecoverySnapshotStore? snapshots,
    IntegrationAuthorizationStore? integrations,
    JourneyRuntimeService? runtime,
  })  : _snapshots = snapshots ?? RecoverySnapshotStore.instance,
        _integrations = integrations ?? IntegrationAuthorizationStore.instance,
        _runtime = runtime ?? const JourneyRuntimeService();

  final RecoverySnapshotStore _snapshots;
  final IntegrationAuthorizationStore _integrations;
  final JourneyRuntimeService _runtime;

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
    final shId = profileShId.value.trim();
    if (shId.isEmpty) {
      throw StateError('Active SH identity is unavailable.');
    }
    await _runtime.endOfLife(
      shId: shId,
      reason: 'Explicit user-confirmed EOL request',
    );

    // EOL is terminal for the current runtime session. The database account
    // and primary SH are deactivated by the runtime authority; terminate the
    // provider session as well so the user cannot remain inside the app after
    // successful EOL.
    try {
      await AuthSession.service.signOut();
    } catch (_) {
      // The EOL operation already succeeded. AuthSession.signOut() clears the
      // local identity in its finally block; a provider sign-out failure must
      // not turn a successful terminal operation into a false failure state.
    }
  }
}
