import 'package:flutter_test/flutter_test.dart';

import 'package:second_head/features/lifecycle/eol/eol_controller.dart';
import 'package:second_head/features/lifecycle/eol/eol_service.dart';
import 'package:second_head/features/lifecycle/eol/eol_state.dart';

class _FakeEolService implements EolService {
  @override
  Future<EolImpact> prepareImpact() async => const EolImpact(
        journeyItems: 2,
        relationships: 1,
        recoverySnapshots: 3,
      );

  @override
  Future<void> executeFrontendClosure() async {}
}

void main() {
  test('EOL flow moves from review to confirmation to terminal UI state', () async {
    final controller = EolController(service: _FakeEolService());

    expect(controller.state.flow, EolFlowState.overview);

    await controller.loadImpact();
    expect(controller.state.flow, EolFlowState.impactReview);
    expect(controller.state.impact.journeyItems, 2);
    expect(controller.state.impact.relationships, 1);
    expect(controller.state.impact.recoverySnapshots, 3);

    controller.openConfirmation();
    expect(controller.state.flow, EolFlowState.confirmation);

    controller.setAcknowledged(true);
    await controller.execute();
    expect(controller.state.flow, EolFlowState.terminal);
  });

  test('EOL cannot execute before acknowledgement', () async {
    final controller = EolController(service: _FakeEolService());
    controller.openConfirmation();
    await controller.execute();
    expect(controller.state.flow, EolFlowState.confirmation);
  });

  test('EOL can be cancelled', () {
    final controller = EolController(service: _FakeEolService());
    controller.cancel();
    expect(controller.state.flow, EolFlowState.cancelled);
  });
}
