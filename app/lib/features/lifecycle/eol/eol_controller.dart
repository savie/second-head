import 'package:flutter/foundation.dart';

import 'eol_service.dart';
import 'eol_state.dart';

class EolController extends ChangeNotifier {
  EolController({EolService? service}) : _service = service ?? LocalEolService();

  final EolService _service;
  EolState _state = const EolState();

  EolState get state => _state;

  Future<void> loadImpact() async {
    try {
      final impact = await _service.prepareImpact();
      _state = _state.copyWith(
        impact: impact,
        flow: EolFlowState.impactReview,
        clearError: true,
      );
    } catch (error) {
      _state = _state.copyWith(
        flow: EolFlowState.failed,
        errorMessage: 'Unable to prepare the EOL review.',
      );
    }
    notifyListeners();
  }

  void openConfirmation() {
    _state = _state.copyWith(flow: EolFlowState.confirmation, clearError: true);
    notifyListeners();
  }

  void setAcknowledged(bool value) {
    _state = _state.copyWith(acknowledged: value);
    notifyListeners();
  }

  Future<void> execute() async {
    if (!_state.acknowledged) return;

    _state = _state.copyWith(flow: EolFlowState.executing, clearError: true);
    notifyListeners();

    try {
      await _service.executeFrontendClosure();
      _state = _state.copyWith(flow: EolFlowState.terminal);
    } catch (error) {
      _state = _state.copyWith(
        flow: EolFlowState.failed,
        errorMessage: 'The EOL request could not be completed.',
      );
    }
    notifyListeners();
  }

  void cancel() {
    _state = _state.copyWith(flow: EolFlowState.cancelled, clearError: true);
    notifyListeners();
  }

  void reset() {
    _state = const EolState();
    notifyListeners();
  }
}
