import 'package:flutter/material.dart';
import '../semantic_domain_view.dart';

class MemoryView extends StatelessWidget {
  const MemoryView({super.key});

  @override
  Widget build(BuildContext context) => const SemanticDomainView(domain: ShSemanticDomain.memory);
}
