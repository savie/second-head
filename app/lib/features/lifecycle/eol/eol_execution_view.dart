import 'package:flutter/material.dart';

import 'eol_controller.dart';
import 'eol_state.dart';
import 'eol_terminal_view.dart';
import 'eol_widgets.dart';

class EolExecutionView extends StatefulWidget {
  const EolExecutionView({super.key, required this.controller});

  final EolController controller;

  @override
  State<EolExecutionView> createState() => _EolExecutionViewState();
}

class _EolExecutionViewState extends State<EolExecutionView> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_stateChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_stateChanged);
    super.dispose();
  }

  void _stateChanged() {
    if (!mounted) return;
    final flow = widget.controller.state.flow;
    if (flow == EolFlowState.terminal) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => EolTerminalView(controller: widget.controller),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return EolShell(
      title: 'End of Life',
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final failed = widget.controller.state.flow == EolFlowState.failed;
          return Column(
            children: [
              const SizedBox(height: 36),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                failed ? 'Unable to complete the request' : 'Preparing lifecycle closure',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 9),
              Text(
                failed
                    ? (widget.controller.state.errorMessage ?? 'Please try again.')
                    : 'This frontend flow stops at the execution boundary. No Supabase mutation is performed here.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: shMuted, fontSize: 12, height: 1.5),
              ),
              if (failed) ...[
                const SizedBox(height: 24),
                EolActionButton(
                  label: 'Return to review',
                  outlined: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
