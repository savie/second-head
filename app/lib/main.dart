import 'package:flutter/material.dart';

void main() {
  runApp(const SecondHeadApp());
}

class SecondHeadApp extends StatelessWidget {
  const SecondHeadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SECOND HEAD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D1D1B),
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const _SplashScreen(),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.large = false});

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: large ? 92 : 52,
          height: large ? 92 : 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface,
              width: large ? 3 : 2,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            'V3',
            style: TextStyle(
              fontSize: large ? 28 : 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'SECOND HEAD',
          style: TextStyle(
            fontSize: large ? 18 : 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
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
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const _LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: _BrandMark(large: true)),
    );
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue with SECOND HEAD.',
      primaryLabel: 'Sign in',
      secondaryLabel: 'Create account',
      onPrimary: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _HomeScreen()),
      ),
      onSecondary: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const _SignUpScreen()),
      ),
      footer: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const _ForgotPasswordScreen()),
        ),
        child: const Text('Forgot password?'),
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
      subtitle: 'Set up your SECOND HEAD account.',
      primaryLabel: 'Sign up',
      secondaryLabel: 'Back to sign in',
      onPrimary: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _HomeScreen()),
      ),
      onSecondary: () => Navigator.of(context).pop(),
      fields: const [
        _AuthField(label: 'Name'),
        _AuthField(label: 'Email'),
        _AuthField(label: 'Password', obscureText: true),
      ],
    );
  }
}

class _ForgotPasswordScreen extends StatelessWidget {
  const _ForgotPasswordScreen();

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      title: 'Reset your password',
      subtitle: 'Enter your email and we will help you get back in.',
      primaryLabel: 'Send reset link',
      secondaryLabel: 'Back to sign in',
      onPrimary: () => Navigator.of(context).pop(),
      onSecondary: () => Navigator.of(context).pop(),
      fields: const [_AuthField(label: 'Email')],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({required this.label, this.obscureText = false});

  final String label;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(hintText: label),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.fields = const [
      _AuthField(label: 'Email'),
      _AuthField(label: 'Password', obscureText: true),
    ],
    this.footer,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final List<Widget> fields;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandMark(),
                  const SizedBox(height: 56),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  ...fields.expand(
                    (field) => [field, const SizedBox(height: 12)],
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: onPrimary,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(primaryLabel),
                    ),
                  ),
                  TextButton(
                    onPressed: onSecondary,
                    child: Text(secondaryLabel),
                  ),
                  if (footer != null) footer!,
                ],
              ),
            ),
          ),
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
  int _selectedIndex = 0;

  final _pages = const [
    _ConversationView(),
    _JourneyView(),
    _LifecycleView(),
    _ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Conversation',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Journey',
          ),
          NavigationDestination(
            icon: Icon(Icons.autorenew_outlined),
            selectedIcon: Icon(Icons.autorenew),
            label: 'Lifecycle',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _InternalHeader extends StatelessWidget {
  const _InternalHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        IconButton(
          tooltip: 'Search',
          onPressed: () {},
          icon: const Icon(Icons.search),
        ),
        IconButton(
          tooltip: 'More',
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ],
    );
  }
}

class _ConversationView extends StatelessWidget {
  const _ConversationView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: [
          const _InternalHeader(title: 'SECOND HEAD'),
          const Expanded(
            child: Center(
              child: Text(
                'Start a conversation',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Write something...',
                    suffixIcon: IconButton(
                      onPressed: null,
                      icon: Icon(Icons.arrow_upward),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JourneyView extends StatelessWidget {
  const _JourneyView();

  @override
  Widget build(BuildContext context) {
    return const _SimpleSurface(
      title: 'Journey',
      icon: Icons.route,
      message: 'Your journey will appear here.',
    );
  }
}

class _LifecycleView extends StatelessWidget {
  const _LifecycleView();

  @override
  Widget build(BuildContext context) {
    return const _SimpleSurface(
      title: 'Lifecycle',
      icon: Icons.autorenew,
      message: 'Your active lifecycle will appear here.',
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return const _SimpleSurface(
      title: 'Profile',
      icon: Icons.person,
      message: 'Account and settings will appear here.',
    );
  }
}

class _SimpleSurface extends StatelessWidget {
  const _SimpleSurface({
    required this.title,
    required this.icon,
    required this.message,
  });

  final String title;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          _InternalHeader(title: title),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48),
                  const SizedBox(height: 16),
                  Text(message),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
