import 'package:flutter/material.dart';
import 'core/navigation/sh_navigation_shell.dart';
import 'features/chat/conversation/conversation_view.dart';
import 'features/journey/journey_view.dart';
import 'core/theme/sh_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

final ValueNotifier<Uint8List?> _profilePhoto = ValueNotifier<Uint8List?>(null);

void main() => runApp(const SecondHeadApp());

class SecondHeadApp extends StatelessWidget {
  const SecondHeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SECOND HEAD',
      debugShowCheckedModeBanner: false,
      theme: buildShTheme(),
      home: const _SplashScreen(),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.large = false, this.showWordmark = false});

  final bool large;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final size = large ? 116.0 : 48.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset('assets/brand/unity.png', fit: BoxFit.contain),
        ),
        if (showWordmark) ...[
          const SizedBox(height: 12),
          const Text(
            'SECOND HEAD',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Dual Mind. Infinite Potential.',
            style: TextStyle(fontSize: 11, color: shMuted),
          ),
          const Text(
            'Human – AI Unity.',
            style: TextStyle(fontSize: 11, color: shMuted),
          ),
        ],
      ],
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const _LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _WaveBackground(),
          Center(child: _BrandMark(large: true, showWordmark: true)),
          Positioned(
            bottom: 38,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 30,
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [shPurple, shCyan]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveBackground extends StatelessWidget {
  const _WaveBackground();

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _WavePainter());
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..shader = const LinearGradient(
        colors: [shPurple, shElectric, shCyan],
      ).createShader(Offset.zero & size);

    for (var i = 0; i < 7; i++) {
      final path = Path();
      final base = size.height * .68 + i * 9;
      path.moveTo(-20, base);
      for (var x = 0.0; x <= size.width + 20; x += 10) {
        final y = base +
            16 * (i.isEven ? 1 : -1) *
                (0.5 + .5 * (i / 7)) *
                (x / size.width).clamp(0.0, 1.0) *
                0.8 *
                (x / size.width < .5 ? x / size.width : 1 - x / size.width);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint..opacity = .32);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    this.fields = const [],
    this.footer,
    this.secondary,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final List<Widget> fields;
  final Widget? footer;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: _BrandMark(),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: shMuted),
                  ),
                  const SizedBox(height: 24),
                  ...fields.expand((w) => [w, const SizedBox(height: 10)]),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 43,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [shPurple, shElectric]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FilledButton(
                        onPressed: onPrimary,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(primaryLabel),
                      ),
                    ),
                  ),
                  if (footer != null) footer!,
                  if (secondary != null) ...[
                    const SizedBox(height: 10),
                    secondary!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.hint,
    this.icon = Icons.mail_outline,
    this.obscure = false,
    this.trailing = false,
  });

  final String hint;
  final IconData icon;
  final bool obscure;
  final bool trailing;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscure,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 17, color: shMuted),
        hintText: hint,
        suffixIcon: trailing
            ? const Icon(Icons.visibility_outlined, size: 17, color: shMuted)
            : null,
      ),
    );
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue to Second Head',
      fields: const [
        _AuthField(hint: 'Email'),
        _AuthField(
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: true,
          trailing: true,
        ),
      ],
      primaryLabel: 'Sign In',
      onPrimary: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _HomeScreen()),
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _ForgotPasswordScreen()),
              ),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Forgot password?', style: TextStyle(fontSize: 10)),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const _SignUpScreen()),
              ),
              child: const Text.rich(
                TextSpan(
                  text: 'Don’t have an account? ',
                  style: TextStyle(fontSize: 10, color: shMuted),
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: TextStyle(color: shCyan),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      secondary: const _SocialButtons(),
    );
  }
}

class _ForgotPasswordScreen extends StatelessWidget {
  const _ForgotPasswordScreen();

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Forgot password?',
      subtitle: 'No worries! Enter your email and we’ll send you a link to reset your password.',
      fields: const [_AuthField(hint: 'Email')],
      primaryLabel: 'Send Reset Link',
      onPrimary: () => Navigator.of(context).pop(),
      footer: Align(
        alignment: Alignment.center,
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back to sign in', style: TextStyle(fontSize: 10)),
        ),
      ),
    );
  }
}

class _SignUpScreen extends StatelessWidget {
  const _SignUpScreen();

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Create your account',
      subtitle: 'Let’s get you started',
      fields: const [
        _AuthField(hint: 'Full name', icon: Icons.person_outline),
        _AuthField(hint: 'Email'),
        _AuthField(hint: 'Password', icon: Icons.lock_outline, obscure: true, trailing: true),
        _AuthField(hint: 'Confirm password', icon: Icons.lock_outline, obscure: true, trailing: true),
      ],
      primaryLabel: 'Create Account',
      onPrimary: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _HomeScreen()),
      ),
      footer: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text.rich(
            TextSpan(
              text: 'Already have an account? ',
              style: TextStyle(fontSize: 10, color: shMuted),
              children: [
                TextSpan(
                  text: 'Sign in',
                  style: TextStyle(color: shCyan),
                ),
              ],
            ),
          ),
        ),
      ),
      secondary: const _SocialButtons(),
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Divider(color: shBorder)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('or continue with', style: TextStyle(fontSize: 10, color: shMuted)),
              ),
              Expanded(child: Divider(color: shBorder)),
            ],
          ),
        ),
        _SocialButton(label: 'Google', leading: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
        const SizedBox(height: 7),
        _SocialButton(label: 'Apple', leading: const Text('', style: TextStyle(fontSize: 18))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.leading});

  final String label;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 39,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: leading,
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          backgroundColor: shSurface2,
          side: const BorderSide(color: shBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return ShNavigationShell(
      drawer: const _SideMenu(),
      pages: const [
        ConversationView(),
        JourneyView(),
        _LifecycleView(),
        _ProfileView(),
      ],
    );
  }
}

final ValueNotifier<List<_ConversationEntry>> _recentConversations =
    ValueNotifier<List<_ConversationEntry>>([
  const _ConversationEntry('Today Priorities', 'Summary and top priorities'),
  const _ConversationEntry('SH Roadmap', 'Project planning and milestones'),
  const _ConversationEntry('Ideas & Notes', 'Personalized ideas and notes'),
]);

class _SideMenu extends StatelessWidget {
  const _SideMenu();

  void _openPage(BuildContext context, int index) {
    Navigator.of(context).pop();
    final home = context.findAncestorStateOfType<_HomeScreenState>();
    home?._selectPage(index);
  }

  void _rename(BuildContext context, int index) {
    final item = _recentConversations.value[index];
    final controller = TextEditingController(text: item.title);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(
          18, 8, 18, MediaQuery.of(sheet).viewInsets.bottom + 18,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Rename conversation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TextField(controller: controller, autofocus: true),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(sheet),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      final list = [..._recentConversations.value];
                      list[index] = _ConversationEntry(name, item.preview);
                      _recentConversations.value = list;
                      if (conversationTitle.value == item.title) {
                        conversationTitle.value = name;
                      }
                    }
                    Navigator.pop(sheet);
                  },
                  child: const Text('Save'),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: shBackground,
      width: 292,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Row(children: [
                _BrandMark(),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Savie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('savie@secondhead.app', style: TextStyle(fontSize: 9, color: shMuted)),
                    ],
                  ),
                ),
              ]),
            ),
            const Divider(color: shBorder),
            _MenuTile(
              icon: Icons.chat_bubble_outline,
              label: 'Conversation',
              onTap: () => _openPage(context, 0),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ValueListenableBuilder<List<_ConversationEntry>>(
                valueListenable: _recentConversations,
                builder: (context, conversations, _) => Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _openPage(context, 0),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(children: [
                          Icon(Icons.add_rounded, size: 18, color: shCyan),
                          SizedBox(width: 10),
                          Text('New Conversation',
                              style: TextStyle(fontSize: 11, color: shCyan)),
                        ]),
                      ),
                    ),
                    for (var i = 0; i < conversations.length; i++)
                      GestureDetector(
                        onLongPress: () => _rename(context, i),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 30, right: 4),
                          leading: const Icon(Icons.chat_bubble_outline, size: 14, color: shMuted),
                          title: Text(conversations[i].title,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10)),
                          subtitle: Text(conversations[i].preview,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 8, color: shMuted)),
                          onTap: () {
                            conversationTitle.value = conversations[i].title;
                            _openPage(context, 0);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(color: shBorder),
            _MenuTile(icon: Icons.hexagon_outlined, label: 'Journey', onTap: () => _openPage(context, 1)),
            _MenuTile(icon: Icons.event_note_outlined, label: 'Lifecycle', onTap: () => _openPage(context, 2)),
            _MenuTile(icon: Icons.person_outline, label: 'Profile', onTap: () => _openPage(context, 3)),
            _MenuTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () => Navigator.pop(context)),
            _MenuTile(icon: Icons.info_outline, label: 'About', onTap: () => Navigator.pop(context)),
            const Spacer(),
            const Divider(color: shBorder),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 10),
              child: Row(children: [
                Expanded(child: _MenuTile(icon: Icons.settings_outlined, label: 'Settings', onTap: () => Navigator.pop(context))),
                Expanded(child: _MenuTile(icon: Icons.logout_rounded, label: 'Log Out', onTap: () => Navigator.popUntil(context, (route) => route.isFirst))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutView extends StatelessWidget {
  const _AboutView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShTopBar(title: 'About'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 24),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [shPurple, shElectric],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: shPurple.withOpacity(.22),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      child: const _BrandMark(),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'SECOND HEAD',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Your second head, built for continuity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: shMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: shSurface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: shBorder),
                ),
                child: const Column(
                  children: [
                    _AboutRow('Version', '1.0.0'),
                    Divider(height: 1, color: shBorder),
                    _AboutRow('Build', '#1'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'Second Head',
                  style: TextStyle(fontSize: 9, color: shMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 10, color: shMuted)),
      ],
    ),
  );
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, this.danger = false});
  final IconData icon;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 19, color: danger ? Colors.redAccent : shMuted),
      title: Text(label, style: TextStyle(fontSize: 12, color: danger ? Colors.redAccent : Colors.white)),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}

class _LifecycleView extends StatelessWidget {
  const _LifecycleView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ShTopBar(
          title: 'Lifecycle',
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search, size: 19)),
            IconButton(onPressed: () {}, icon: Icon(Icons.fullscreen, size: 18)),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 26,
                      maxWidth: 520,
                    ),
                    child: const _LifecycleMap(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LifecycleMap extends StatelessWidget {
  const _LifecycleMap();

  @override
  Widget build(BuildContext context) {
    final stages = const [
      _LifecycleStage(
        'Clone',
        'Duplicate your Second Head state',
        Icons.copy_all_rounded,
        Alignment.centerLeft,
      ),
      _LifecycleStage(
        'Recovery',
        'Restore continuity when something changes',
        Icons.restore_rounded,
        Alignment.centerRight,
      ),
      _LifecycleStage(
        'Inheritance',
        'Pass knowledge and identity forward',
        Icons.account_tree_rounded,
        Alignment.centerLeft,
      ),
      _LifecycleStage(
        'Succession',
        'Continue the role beyond one instance',
        Icons.swap_horiz_rounded,
        Alignment.centerRight,
      ),
      _LifecycleStage(
        'Legacy',
        'Preserve what should remain meaningful',
        Icons.auto_awesome_rounded,
        Alignment.centerLeft,
      ),
      _LifecycleStage(
        'End of Life',
        'Close the lifecycle with dignity and control',
        Icons.trip_origin_rounded,
        Alignment.centerRight,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: shSurface.withOpacity(.62),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: shBorder),
        boxShadow: [
          BoxShadow(
            color: shPurple.withOpacity(.08),
            blurRadius: 30,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 400;
          return Stack(
            children: [
              Positioned(
                top: 22,
                bottom: 22,
                left: wide ? constraints.maxWidth / 2 - 1 : 22,
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [shPurple, shElectric, shCyan, shPurple],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Column(
                children: [
                  for (var i = 0; i < stages.length; i++)
                    _LifecycleCard(
                      stage: stages[i],
                      index: i,
                      wide: wide,
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LifecycleStage {
  const _LifecycleStage(this.title, this.subtitle, this.icon, this.alignment);
  final String title;
  final String subtitle;
  final IconData icon;
  final Alignment alignment;
}

class _LifecycleCard extends StatelessWidget {
  const _LifecycleCard({
    required this.stage,
    required this.index,
    required this.wide,
  });

  final _LifecycleStage stage;
  final int index;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Container(
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: shSurface2.withOpacity(.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: shBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [shPurple, shElectric],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shPurple.withOpacity(.22),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Icon(stage.icon, size: 20),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stage.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage.subtitle,
                      style: const TextStyle(
                        fontSize: 9,
                        color: shMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: shMuted,
              ),
            ],
          ),
        ),
      ),
    );

    if (!wide) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: card,
      );
    }

    final left = index.isEven;
    return SizedBox(
      height: 96,
      child: Align(
        alignment: left ? Alignment.centerLeft : Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: .84,
          child: card,
        ),
      ),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, imageQuality: 88, maxWidth: 900);
    if (file == null) return;
    _profilePhoto.value = await file.readAsBytes();
  }

  void _showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: shSurface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfilePhotoAction(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              _ProfilePhotoAction(
                icon: Icons.photo_library_outlined,
                label: 'Photos',
                onTap: () {
                  Navigator.pop(context);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              _ProfilePhotoAction(
                icon: Icons.delete_outline,
                label: 'Remove',
                onTap: () {
                  Navigator.pop(context);
                  _profilePhoto.value = null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShTopBar(
          title: 'Profile / Settings',
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.open_in_new, size: 18)),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            children: [
              ValueListenableBuilder<Uint8List?>(
                valueListenable: _profilePhoto,
                builder: (context, photo, _) => Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 16),
                  decoration: BoxDecoration(
                    color: shSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: shBorder),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _showPhotoOptions,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 29,
                              backgroundColor: shSurface2,
                              backgroundImage: photo != null ? MemoryImage(photo) : null,
                              child: photo == null
                                  ? const Icon(Icons.person_outline, size: 27, color: shMuted)
                                  : null,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 23,
                                height: 23,
                                decoration: BoxDecoration(
                                  color: shPurple,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: shSurface, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_outlined, size: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Savie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            SizedBox(height: 3),
                            Text('savie@secondhead.app', style: TextStyle(fontSize: 9, color: shMuted)),
                            SizedBox(height: 5),
                            Text('Tap your photo to change it', style: TextStyle(fontSize: 8, color: shMuted)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _showPhotoOptions,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const _SettingsGroup(title: 'Account', items: [
                _SettingItem(Icons.person_outline, 'Account', 'Manage your personal information'),
                _SettingItem(Icons.palette_outlined, 'Appearance', 'Choose theme and language'),
                _SettingItem(Icons.notifications_none, 'Notifications', 'Manage your notification preferences'),
                _SettingItem(Icons.lock_outline, 'Security', 'Password and security settings'),
                _SettingItem(Icons.hub_outlined, 'Integrations', 'Manage connected services'),
                _SettingItem(Icons.shield_outlined, 'Data & Privacy', 'Manage your data and privacy'),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfilePhotoAction extends StatelessWidget {
  const _ProfilePhotoAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [shPurple, shElectric]),
              ),
              child: Icon(icon),
            ),
            const SizedBox(height: 7),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.items});
  final String title;
  final List<_SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: shSurface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: shBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1) const Divider(height: 1, color: shBorder),
          ],
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Icon(icon, size: 19, color: shMuted),
      title: Text(title, style: const TextStyle(fontSize: 11)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 8, color: shMuted)),
      trailing: const Icon(Icons.chevron_right, size: 17, color: shMuted),
    );
  }
}

