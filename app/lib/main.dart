import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const _SideMenu(),
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopBar(
          title: 'SECOND HEAD',
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search, size: 19)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit_square, size: 19)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _CompanionCard(),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            children: const [
              _DateLabel('Today'),
              _Message(text: 'Hi, Savie! 👋\nHow can I help you today?', time: '09:41', assistant: true),
              _Message(text: 'Help me summarize my main plan for today and top priorities.', time: '09:41', assistant: false),
              _Message(text: 'Sure! Here is your summary and top priorities.', time: '09:42', assistant: true),
              _SummaryCard(),
            ],
          ),
        ),
        const _Composer(),
      ],
    );
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
  const _Message({required this.text, required this.time, required this.assistant});
  final String text;
  final String time;
  final bool assistant;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: assistant ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: assistant ? _surface2 : _purple,
          borderRadius: BorderRadius.circular(9),
          border: assistant ? Border.all(color: _border) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(fontSize: 11, height: 1.35))),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 8, color: _muted)),
          ],
        ),
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

class _Composer extends StatelessWidget {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 9),
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, size: 22)),
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

class _SideMenu extends StatelessWidget {
  const _SideMenu();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _bg,
      width: 285,
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
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
                ],
              ),
            ),
            const Divider(color: _border),
            _MenuTile(icon: Icons.add_comment_outlined, label: 'New Conversation'),
            _MenuTile(icon: Icons.hexagon_outlined, label: 'Journey'),
            _MenuTile(icon: Icons.event_note_outlined, label: 'Lifecycle'),
            _MenuTile(icon: Icons.hub_outlined, label: 'Integrations'),
            _MenuTile(icon: Icons.person_outline, label: 'Profile'),
            _MenuTile(icon: Icons.settings_outlined, label: 'Settings'),
            _MenuTile(icon: Icons.help_outline, label: 'Help & Support'),
            _MenuTile(icon: Icons.info_outline, label: 'About Second Head'),
            const Spacer(),
            const Divider(color: _border),
            _MenuTile(icon: Icons.logout, label: 'Log Out', danger: true),
            const SizedBox(height: 12),
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

class _JourneyView extends StatelessWidget {
  const _JourneyView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(
          title: 'Journey',
          actions: [Icon(Icons.refresh_rounded, size: 20)],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search your journey...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.tune, size: 17)),
            ),
          ),
        ),
        const _FilterChips(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            children: const [
              _JourneyCard(title: 'Project SH Roadmap', subtitle: 'Documented roadmap and key milestones', date: '2 days ago'),
              _JourneyCard(title: 'Client Meeting Notes', subtitle: 'Important notes from the meeting about feature priorities.', date: 'Yesterday'),
              _JourneyCard(title: 'Ideas – AI Personalization', subtitle: 'Ideas about personalization based on user behavior.', date: 'May 29'),
              _JourneyCard(title: 'Reference – Runtime Contract', subtitle: 'Notes about runtime contract and future calling.', date: 'May 25'),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _Chip(label: 'All', selected: true),
          _Chip(label: 'Important'),
          _Chip(label: 'Pinned'),
          _Chip(label: 'Recent'),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? _purple.withOpacity(.15) : _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? _purple : _border),
      ),
      child: Text(label, style: TextStyle(fontSize: 9, color: selected ? Colors.white : _muted)),
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard({required this.title, required this.subtitle, required this.date});
  final String title;
  final String subtitle;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: _muted, height: 1.35)),
                const SizedBox(height: 5),
                Text(date, style: const TextStyle(fontSize: 8, color: _muted)),
              ],
            ),
          ),
          const Icon(Icons.star, size: 17, color: _cyan),
        ],
      ),
    );
  }
}

class _LifecycleView extends StatelessWidget {
  const _LifecycleView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TopBar(
          title: 'Lifecycle',
          actions: [Icon(Icons.fullscreen, size: 18)],
        ),
        const _Tabs(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            children: const [
              _SectionLabel('Today'),
              _Task(title: 'Meeting with team SH', time: '10:00 AM'),
              _Task(title: 'Review document R6', time: '01:00 PM'),
              _Task(title: 'Implement feature A', time: '03:00 PM'),
              SizedBox(height: 10),
              _SectionLabel('Tomorrow'),
              _Task(title: 'Update documentation', time: '09:00 AM'),
              _Task(title: 'Test & validation', time: '02:00 PM'),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14, bottom: 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: FloatingActionButton.small(
              onPressed: () {},
              backgroundColor: _purple,
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _Tab(label: 'To Do', selected: true)),
        Expanded(child: _Tab(label: 'In Progress')),
        Expanded(child: _Tab(label: 'Done')),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: selected ? _purple : _border, width: selected ? 2 : 1)),
      ),
      child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: selected ? Colors.white : _muted)),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      );
}

class _Task extends StatelessWidget {
  const _Task({required this.title, required this.time});
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
      child: Row(
        children: [
          const Icon(Icons.radio_button_unchecked, size: 18, color: _muted),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 10))),
          Text(time, style: const TextStyle(fontSize: 9, color: _muted)),
        ],
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

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
              Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 23,
                      backgroundColor: _purple,
                      child: Icon(Icons.person, size: 24),
                    ),
                    SizedBox(width: 11),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Savie', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        SizedBox(height: 3),
                        Text('savie@secondhead.app', style: TextStyle(fontSize: 9, color: _muted)),
                      ],
                    ),
                  ],
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

