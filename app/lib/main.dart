import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

final ValueNotifier<Uint8List?> _profilePhoto = ValueNotifier<Uint8List?>(null);

void main() => runApp(const SecondHeadApp());

const _bg = Color(0xFF050D16);
const _surface = Color(0xFF0B1622);
const _surface2 = Color(0xFF111F2C);
const _purple = Color(0xFF7C3AED);
const _electric = Color(0xFF2563EB);
const _cyan = Color(0xFF22D3EE);
const _muted = Color(0xFF9AA8B6);
const _border = Color(0xFF273746);

class SecondHeadApp extends StatelessWidget {
  const SecondHeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SECOND HEAD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _bg,
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: _purple,
          brightness: Brightness.dark,
        ).copyWith(
          primary: _purple,
          secondary: _cyan,
          surface: _surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0x990B1622),
          hintStyle: const TextStyle(color: _muted, fontSize: 13),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: _purple),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surface,
          indicatorColor: _purple.withOpacity(.18),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ),
      ),
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
            style: TextStyle(fontSize: 11, color: _muted),
          ),
          const Text(
            'Human – AI Unity.',
            style: TextStyle(fontSize: 11, color: _muted),
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
                  gradient: const LinearGradient(colors: [_purple, _cyan]),
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
        colors: [_purple, _electric, _cyan],
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
                    style: const TextStyle(fontSize: 11, color: _muted),
                  ),
                  const SizedBox(height: 24),
                  ...fields.expand((w) => [w, const SizedBox(height: 10)]),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 43,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_purple, _electric]),
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
        prefixIcon: Icon(icon, size: 17, color: _muted),
        hintText: hint,
        suffixIcon: trailing
            ? const Icon(Icons.visibility_outlined, size: 17, color: _muted)
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
                  style: TextStyle(fontSize: 10, color: _muted),
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: TextStyle(color: _cyan),
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
              style: TextStyle(fontSize: 10, color: _muted),
              children: [
                TextSpan(
                  text: 'Sign in',
                  style: TextStyle(color: _cyan),
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
              Expanded(child: Divider(color: _border)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('or continue with', style: TextStyle(fontSize: 10, color: _muted)),
              ),
              Expanded(child: Divider(color: _border)),
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
          backgroundColor: _surface2,
          side: const BorderSide(color: _border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _HomeScreen extends StatefulWidget {
  const _HomeScreen();

  @override
  State<_HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeScreen> {
  int index = 0;

  final pages = const [
    _ConversationView(),
    _JourneyView(),
    _LifecycleView(),
    _ProfileView(),
  ];

  void _selectPage(int value) => setState(() => index = value);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _SideMenu(),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity < -250 && index < pages.length - 1) {
              _selectPage(index + 1);
            } else if (velocity > 250 && index > 0) {
              _selectPage(index - 1);
            }
          },
          child: pages[index],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _selectPage,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline, size: 19), selectedIcon: Icon(Icons.chat_bubble, size: 19), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.hexagon_outlined, size: 19), selectedIcon: Icon(Icons.hexagon, size: 19), label: 'Journey'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined, size: 19), selectedIcon: Icon(Icons.event_note, size: 19), label: 'Lifecycle'),
          NavigationDestination(icon: Icon(Icons.person_outline, size: 19), selectedIcon: Icon(Icons.person, size: 19), label: 'Profile'),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, this.leading, this.actions = const []});

  final String title;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          leading ??
              IconButton(
                tooltip: 'Menu',
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu, size: 21),
              ),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class _ConversationView extends StatelessWidget {
  const _ConversationView();

  void _rename(BuildContext context) {
    final controller = TextEditingController(text: _conversationTitle.value);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(18, 8, 18, MediaQuery.of(sheet).viewInsets.bottom + 18),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Rename conversation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(controller: controller, autofocus: true),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(sheet), child: const Text('Cancel'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton(onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                _conversationTitle.value = name;
                final list = [..._recentConversations.value];
                final i = list.indexWhere((x) => x.title == _conversationTitle.value);
                if (i >= 0) list[i] = _ConversationEntry(name, list[i].preview);
                _recentConversations.value = list;
              }
              Navigator.pop(sheet);
            }, child: const Text('Save'))),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ValueListenableBuilder<String>(
        valueListenable: _conversationTitle,
        builder: (context, title, _) => _TopBar(
          title: title,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search, size: 19)),
            IconButton(onPressed: () => _rename(context), icon: const Icon(Icons.edit_square, size: 19)),
          ],
        ),
      ),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: _CompanionCard()),
      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        children: const [
          _DateLabel('Today'),
          _Message(text: 'Hi, Savie! 👋\nHow can I help you today?', time: '09:41', assistant: true),
          _Message(text: 'Help me summarize my main plan for today and top priorities.', time: '09:41', assistant: false),
          _Message(text: 'Sure! Here is your summary and top priorities.', time: '09:42', assistant: true),
          _SummaryCard(),
        ],
      )),
      const _Composer(),
    ]);
  }
}

class _CompanionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [_purple, _electric]),
            ),
            child: const Icon(Icons.psychology_outlined, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SH Prime', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Row(children: [Icon(Icons.circle, size: 6, color: Colors.green), SizedBox(width: 4), Text('Online', style: TextStyle(fontSize: 9, color: _muted))]),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: _muted),
        ],
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Text(text, style: const TextStyle(fontSize: 9, color: _muted)),
        ),
      );
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    required this.time,
    required this.assistant,
    this.image,
  });

  final String text;
  final String time;
  final bool assistant;
  final Uint8List? image;

  void _showActions(BuildContext context) {
    final actions = assistant
        ? const ['Copy', 'Delete', 'Regenerate']
        : const ['Copy', 'Delete', 'Edit'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in actions)
              ListTile(
                leading: Icon(
                  action == 'Delete'
                      ? Icons.delete_outline
                      : action == 'Edit'
                          ? Icons.edit_outlined
                          : action == 'Regenerate'
                              ? Icons.refresh_rounded
                              : Icons.copy_outlined,
                  color: action == 'Delete' ? Colors.redAccent : Colors.white70,
                ),
                title: Text(action),
                onTap: () => Navigator.of(context).pop(),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showActions(context),
      child: Align(
        alignment: assistant ? Alignment.centerLeft : Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (assistant)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _ChatAvatar(assistant: true),
              ),
            Container(
          constraints: const BoxConstraints(maxWidth: 300),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: assistant
                ? null
                : const LinearGradient(colors: [_purple, _electric]),
            color: assistant ? _surface2 : null,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(assistant ? 5 : 18),
              bottomRight: Radius.circular(assistant ? 18 : 5),
            ),
            border: assistant ? Border.all(color: _border) : null,
          ),
          child: Column(
            crossAxisAlignment:
                assistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    image!,
                    width: 245,
                    height: 175,
                    fit: BoxFit.cover,
                  ),
                ),
              if (image != null && text.isNotEmpty) const SizedBox(height: 7),
              if (text.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 11, height: 1.4),
                  ),
                ),
              const SizedBox(height: 4),
              Text(time, style: const TextStyle(fontSize: 8, color: _muted)),
            ],
          ),
        ),
            if (!assistant)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _ChatAvatar(assistant: false),
              ),
          ],
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.assistant});
  final bool assistant;

  @override
  Widget build(BuildContext context) {
    if (assistant) {
      return Container(
        width: 22,
        height: 22,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [_purple, _electric]),
        ),
        child: ClipOval(child: Image.asset('assets/brand/unity.png', fit: BoxFit.contain)),
      );
    }
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: _profilePhoto,
      builder: (context, photo, _) => CircleAvatar(
        radius: 11,
        backgroundColor: _surface2,
        backgroundImage: photo != null ? MemoryImage(photo) : null,
        child: photo == null ? const Icon(Icons.person_outline, size: 13, color: _muted) : null,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today Summary', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text('• Meeting with team SH – 10:00 AM\n• Review document R6 – 1:00 PM\n• Implement feature A – 3:00 PM', style: TextStyle(fontSize: 10, color: _muted, height: 1.55)),
          SizedBox(height: 9),
          Text('Top Priorities', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          SizedBox(height: 5),
          Text('1. Complete feature A\n2. Integrate calendar\n3. Write documentation', style: TextStyle(fontSize: 10, color: _muted, height: 1.55)),
        ],
      ),
    );
  }
}

class _Composer extends StatefulWidget {
  const _Composer();

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  void _showAttachments() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AttachAction(icon: Icons.camera_alt_outlined, label: 'Camera'),
              _AttachAction(icon: Icons.photo_library_outlined, label: 'Photos'),
              _AttachAction(icon: Icons.attach_file_rounded, label: 'File'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 9),
      child: Row(
        children: [
          IconButton(onPressed: _showAttachments, icon: const Icon(Icons.add_circle_outline, size: 22)),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Message SH...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 13),
                  suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_upward, size: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachAction extends StatelessWidget {
  const _AttachAction({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [_purple, _electric]),
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

class _ConversationEntry {
  const _ConversationEntry(this.title, this.preview);
  final String title;
  final String preview;
}

final ValueNotifier<List<_ConversationEntry>> _recentConversations =
    ValueNotifier<List<_ConversationEntry>>([
  const _ConversationEntry('Today Priorities', 'Summary and top priorities'),
  const _ConversationEntry('SH Roadmap', 'Project planning and milestones'),
  const _ConversationEntry('Ideas & Notes', 'Personalized ideas and notes'),
]);

final ValueNotifier<String> _conversationTitle =
    ValueNotifier<String>('Today Priorities');

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
      backgroundColor: _surface,
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
                      if (_conversationTitle.value == item.title) {
                        _conversationTitle.value = name;
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
      backgroundColor: _bg,
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
                      Text('savie@secondhead.app', style: TextStyle(fontSize: 9, color: _muted)),
                    ],
                  ),
                ),
              ]),
            ),
            const Divider(color: _border),
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
                          Icon(Icons.add_rounded, size: 18, color: _cyan),
                          SizedBox(width: 10),
                          Text('New Conversation',
                              style: TextStyle(fontSize: 11, color: _cyan)),
                        ]),
                      ),
                    ),
                    for (var i = 0; i < conversations.length; i++)
                      GestureDetector(
                        onLongPress: () => _rename(context, i),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.only(left: 30, right: 4),
                          leading: const Icon(Icons.chat_bubble_outline, size: 14, color: _muted),
                          title: Text(conversations[i].title,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10)),
                          subtitle: Text(conversations[i].preview,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 8, color: _muted)),
                          onTap: () {
                            _conversationTitle.value = conversations[i].title;
                            _openPage(context, 0);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Divider(color: _border),
            _MenuTile(icon: Icons.hexagon_outlined, label: 'Journey', onTap: () => _openPage(context, 1)),
            _MenuTile(icon: Icons.event_note_outlined, label: 'Lifecycle', onTap: () => _openPage(context, 2)),
            _MenuTile(icon: Icons.person_outline, label: 'Profile', onTap: () => _openPage(context, 3)),
            _MenuTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () => Navigator.pop(context)),
            _MenuTile(icon: Icons.info_outline, label: 'About', onTap: () => Navigator.pop(context)),
            const Spacer(),
            const Divider(color: _border),
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

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, this.danger = false});
  final IconData icon;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 19, color: danger ? Colors.redAccent : _muted),
      title: Text(label, style: TextStyle(fontSize: 12, color: danger ? Colors.redAccent : Colors.white)),
      onTap: () => Navigator.of(context).pop(),
    );
  }
}

class _JourneyView extends StatefulWidget { const _JourneyView(); @override State<_JourneyView> createState()=>_JourneyViewState(); }
class _JourneyViewState extends State<_JourneyView> {
 String filter='All'; int? selected;
 final items=const [_JourneyItem('Project SH Roadmap','Documented roadmap and key milestones','2 days ago','Knowledge','The documented roadmap and key milestones for Second Head.',true),_JourneyItem('Client Meeting Notes','Important notes from the meeting about feature priorities.','Yesterday','Experience','Important notes captured from the client meeting and its feature priorities.',false),_JourneyItem('Ideas – AI Personalization','Ideas about personalization based on user behavior.','May 29','Memory','Ideas and retained context about personalization based on user behavior.',true),_JourneyItem('Reference – Runtime Contract','Notes about runtime contract and future calling.','May 25','Knowledge','Reference material describing the runtime contract and future calling.',false)];
 @override Widget build(BuildContext context){if(selected!=null)return _JourneyDetail(item:items[selected!],onBack:()=>setState(()=>selected=null));final visible=[for(var i=0;i<items.length;i++)if(filter=='All'||items[i].type==filter)i];return Stack(children:[Column(children:[const _TopBar(title:'Journey',actions:[IconButton(onPressed:(){},icon:Icon(Icons.search,size:19)),IconButton(onPressed:(){},icon:Icon(Icons.refresh_rounded,size:20))]),_JourneyFilters(value:filter,onChanged:(v)=>setState(()=>filter=v)),Expanded(child:ListView.builder(padding:const EdgeInsets.fromLTRB(12,8,12,88),itemCount:visible.length,itemBuilder:(_,i)=>_JourneyCard(item:items[visible[i]],onTap:()=>setState(()=>selected=visible[i]))))]),Positioned(right:18,bottom:18,child:FloatingActionButton(heroTag:'journey-add',onPressed:()=>_create(context),child:const Icon(Icons.add)))]);}
 void _create(BuildContext context)=>showModalBottomSheet<void>(context:context,backgroundColor:_surface,showDragHandle:true,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),builder:(_)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[const Padding(padding:EdgeInsets.all(16),child:Align(alignment:Alignment.centerLeft,child:Text('Create new',style:TextStyle(fontSize:16,fontWeight:FontWeight.w700)))),for(final t in const ['Memory','Knowledge','Experience'])ListTile(leading:const Icon(Icons.add_circle_outline),title:Text(t),onTap:(){Navigator.pop(context);_edit(context,t,'');}),const SizedBox(height:8)])));
 void _edit(BuildContext context,String type,String initial){final ctl=TextEditingController(text:initial);showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:_surface,showDragHandle:true,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),builder:(sc)=>Padding(padding:EdgeInsets.fromLTRB(18,8,18,MediaQuery.of(sc).viewInsets.bottom+18),child:Column(mainAxisSize:MainAxisSize.min,children:[Text('Edit '+type,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w700)),const SizedBox(height:12),TextField(controller:ctl,maxLines:7,autofocus:true,decoration:const InputDecoration(hintText:'Write content...')),const SizedBox(height:14),Row(children:[Expanded(child:OutlinedButton(onPressed:()=>Navigator.pop(sc),child:const Text('Cancel'))),const SizedBox(width:10),Expanded(child:FilledButton(onPressed:()=>Navigator.pop(sc),child:const Text('Save')))])])));}
}
class _JourneyFilters extends StatelessWidget { const _JourneyFilters({required this.value,required this.onChanged}); final String value; final ValueChanged<String> onChanged; @override Widget build(BuildContext context)=>SingleChildScrollView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),child:Row(children:[for(final l in const ['All','Memory','Knowledge','Experience'])Padding(padding:const EdgeInsets.only(right:7),child:InkWell(borderRadius:BorderRadius.circular(20),onTap:()=>onChanged(l),child:Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:7),decoration:BoxDecoration(color:value==l?_purple.withOpacity(.16):_surface,borderRadius:BorderRadius.circular(20),border:Border.all(color:value==l?_purple:_border)),child:Text(l,style:TextStyle(fontSize:9,color:value==l?Colors.white:_muted)))))])); }
class _JourneyItem { const _JourneyItem(this.title,this.subtitle,this.date,this.type,this.content,this.isPrivate); final String title,subtitle,date,type,content; final bool isPrivate; }
class _JourneyCard extends StatelessWidget { const _JourneyCard({required this.item,required this.onTap}); final _JourneyItem item; final VoidCallback onTap; @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(16),child:Container(margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(16),border:Border.all(color:_border)),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Container(padding:const EdgeInsets.symmetric(horizontal:7,vertical:4),decoration:BoxDecoration(color:_purple.withOpacity(.12),borderRadius:BorderRadius.circular(8)),child:Text(item.type,style:const TextStyle(fontSize:8,color:_muted))),const SizedBox(width:7),Expanded(child:Text(item.title,style:const TextStyle(fontSize:11,fontWeight:FontWeight.w600)))]),const SizedBox(height:5),Text(item.subtitle,style:const TextStyle(fontSize:9,color:_muted,height:1.35)),const SizedBox(height:6),Text(item.date,style:const TextStyle(fontSize:8,color:_muted))])),const Icon(Icons.chevron_right_rounded,color:_muted)]))); }
class _JourneyDetail extends StatefulWidget { const _JourneyDetail({required this.item,required this.onBack}); final _JourneyItem item; final VoidCallback onBack; @override State<_JourneyDetail> createState()=>_JourneyDetailState(); }
class _JourneyDetailState extends State<_JourneyDetail>{ late bool privatePolicy; @override void initState(){super.initState();privatePolicy=widget.item.isPrivate;} @override Widget build(BuildContext context)=>Column(children:[_TopBar(title:widget.item.type,leading:IconButton(onPressed:widget.onBack,icon:const Icon(Icons.arrow_back))),Expanded(child:SingleChildScrollView(padding:const EdgeInsets.fromLTRB(16,8,16,20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.item.title,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w700)),const SizedBox(height:14),Container(width:double.infinity,padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:_surface,borderRadius:BorderRadius.circular(16),border:Border.all(color:_border)),child:Text(widget.item.content,style:const TextStyle(fontSize:12,height:1.5))),const SizedBox(height:20),const Text('Policy',style:TextStyle(fontSize:12,fontWeight:FontWeight.w700)),const SizedBox(height:8),Row(children:[Expanded(child:_PolicyOption(label:'Private',icon:Icons.lock_outline,selected:privatePolicy,onTap:()=>setState(()=>privatePolicy=true))),const SizedBox(width:10),Expanded(child:_PolicyOption(label:'Public',icon:Icons.public,selected:!privatePolicy,onTap:()=>setState(()=>privatePolicy=false)))])])),Padding(padding:const EdgeInsets.fromLTRB(16,8,16,14),child:Align(alignment:Alignment.centerRight,child:FloatingActionButton.small(heroTag:'journey-edit',onPressed:_edit,child:const Icon(Icons.edit_outlined))))]); void _edit(){final ctl=TextEditingController(text:widget.item.content);showModalBottomSheet<void>(context:context,isScrollControlled:true,backgroundColor:_surface,showDragHandle:true,shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(24))),builder:(sc)=>Padding(padding:EdgeInsets.fromLTRB(18,8,18,MediaQuery.of(sc).viewInsets.bottom+18),child:Column(mainAxisSize:MainAxisSize.min,children:[Text('Edit '+widget.item.type,style:const TextStyle(fontSize:16,fontWeight:FontWeight.w700)),const SizedBox(height:12),TextField(controller:ctl,maxLines:7),const SizedBox(height:14),Row(children:[Expanded(child:OutlinedButton(onPressed:()=>Navigator.pop(sc),child:const Text('Cancel'))),const SizedBox(width:10),Expanded(child:FilledButton(onPressed:()=>Navigator.pop(sc),child:const Text('Save')))])])));} }
class _PolicyOption extends StatelessWidget { const _PolicyOption({required this.label,required this.icon,required this.selected,required this.onTap}); final String label; final IconData icon; final bool selected; final VoidCallback onTap; @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(14),child:Container(padding:const EdgeInsets.symmetric(vertical:13,horizontal:12),decoration:BoxDecoration(color:selected?_purple.withOpacity(.13):_surface,borderRadius:BorderRadius.circular(14),border:Border.all(color:selected?_purple:_border)),child:Row(children:[Icon(icon,size:18),const SizedBox(width:8),Text(label,style:const TextStyle(fontSize:10))]))); }
class _LifecycleView extends StatelessWidget {
  const _LifecycleView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(
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
        color: _surface.withOpacity(.62),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _purple.withOpacity(.08),
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
                      colors: [_purple, _electric, _cyan, _purple],
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
            color: _surface2.withOpacity(.82),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [_purple, _electric],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withOpacity(.22),
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
                        color: _muted,
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
                color: _muted,
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
      backgroundColor: _surface,
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
        _TopBar(
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
                    color: _surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _border),
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
                              backgroundColor: _surface2,
                              backgroundImage: photo != null ? MemoryImage(photo) : null,
                              child: photo == null
                                  ? const Icon(Icons.person_outline, size: 27, color: _muted)
                                  : null,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                width: 23,
                                height: 23,
                                decoration: BoxDecoration(
                                  color: _purple,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _surface, width: 2),
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
                            Text('savie@secondhead.app', style: TextStyle(fontSize: 9, color: _muted)),
                            SizedBox(height: 5),
                            Text('Tap your photo to change it', style: TextStyle(fontSize: 8, color: _muted)),
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
                gradient: const LinearGradient(colors: [_purple, _electric]),
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
        color: _surface,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1) const Divider(height: 1, color: _border),
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
      leading: Icon(icon, size: 19, color: _muted),
      title: Text(title, style: const TextStyle(fontSize: 11)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 8, color: _muted)),
      trailing: const Icon(Icons.chevron_right, size: 17, color: _muted),
    );
  }
}

