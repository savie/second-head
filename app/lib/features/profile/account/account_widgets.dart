part of 'account_view.dart';

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.title, required this.rows});

  final String title;
  final List<_AccountRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, color: shMuted, fontWeight: FontWeight.w600),
          ),
        ),
        Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
    required this.icon,
    required this.label,
    required this.value,
    this.editable = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool editable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: editable ? onTap : null,
        child: Container(
          constraints: const BoxConstraints(minHeight: 70),
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          decoration: BoxDecoration(
            color: shSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: shBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: shSurface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: shBorder),
                ),
                child: Icon(icon, size: 21, color: Colors.white),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: shMuted),
                    ),
                  ],
                ),
              ),
              if (editable)
                const Icon(Icons.chevron_right_rounded, size: 21, color: shMuted),
            ],
          ),
        ),
      ),
    );
  }
}
