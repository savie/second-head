import 'package:flutter/material.dart';

import 'eol_controller.dart';
import 'eol_overview_view.dart';

/// Entry point owned by the Lifecycle feature.
///
/// The parent Lifecycle map only needs to open this route; the complete EOL
/// flow stays isolated inside the eol sub-feature.
class EolEntryView extends StatefulWidget {
  const EolEntryView({super.key});

  @override
  State<EolEntryView> createState() => _EolEntryViewState();
}

class _EolEntryViewState extends State<EolEntryView> {
  late final EolController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EolController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EolOverviewView(controller: _controller);
  }
}
