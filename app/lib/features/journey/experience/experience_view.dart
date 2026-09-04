import 'package:flutter/material.dart';
import '../semantic_domain_view.dart';

class ExperienceView extends StatelessWidget {
  const ExperienceView({super.key});

  @override
  Widget build(BuildContext context) => const SemanticDomainView(domain: ShSemanticDomain.experience);
}
