import 'package:flutter/material.dart';
import '../semantic_domain_view.dart';

class KnowledgeView extends StatelessWidget {
  const KnowledgeView({super.key});

  @override
  Widget build(BuildContext context) => const SemanticDomainView(domain: ShSemanticDomain.knowledge);
}
