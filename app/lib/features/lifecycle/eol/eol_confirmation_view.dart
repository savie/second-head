import 'package:flutter/material.dart';

import '../../../core/theme/sh_theme.dart';
import 'eol_controller.dart';
import 'eol_execution_view.dart';
import 'eol_widgets.dart';

class EolConfirmationView extends StatelessWidget {
  const EolConfirmationView({super.key, required this.controller});

  final EolController controller;

  @override
  Widget build(BuildContext context) {
    return EolShell(
      title: 'Confirm EOL',
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return Column(
            children: [
              const EolHero(),
              const SizedBox(height: 24),
              const EolCard(
                child: Text(
                  'Please confirm that you understand this is a terminal lifecycle flow. It is intentionally separate from generic Delete Data behavior.',
                  style: TextStyle(color: shMuted, fontSize: 12, height: 1.5),
                ),
              ),
              const SizedBox(height: 14),
              EolCard(
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: controller.state.acknowledged,
                  onChanged: (value) => controller.setAcknowledged(value ?? false),
                  title: const Text('I understand the EOL consequences.', style: TextStyle(fontSize: 13)),
                  subtitle: const Text('The frontend will not erase SH identity or history as part of this step.', style: TextStyle(color: shMuted, fontSize: 11, height: 1.35)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              const SizedBox(height: 24),
              EolActionButton(
                label: 'Confirm End of Life',
                icon: Icons.check_rounded,
                onPressed: controller.state.acknowledged
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => EolExecutionView(controller: controller),
                          ),
                        );
                        controller.execute();
                      }
                    : null,
              ),
              const SizedBox(height: 10),
              EolActionButton(
                label: 'Cancel',
                outlined: true,
                onPressed: controller.cancel,
              ),
            ],
          );
        },
      ),
    );
  }
}
