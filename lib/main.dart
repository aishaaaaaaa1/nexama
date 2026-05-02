import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/landing_page.dart';
import 'pages/signup_page.dart';
import 'pages/login_page.dart';
import 'pages/entrepreneur_dashboard.dart';
import 'pages/investisseur_dashboard.dart';
import 'pages/prestataire_dashboard.dart';
import 'pages/formateur_dashboard.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const NexaMaApp());
}

class NexaMaApp extends StatelessWidget {
  const NexaMaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexaMa — Plateforme intelligente pour entrepreneurs marocains',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF198754),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/': (context) => const LandingPage(),
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
        '/dashboard/entrepreneur': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return EntrepreneurDashboard(userData: args);
        },
        '/dashboard/investisseur': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return InvestisseurDashboard(userData: args);
        },
        '/dashboard/prestataire': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return PrestataireDashboard(userData: args);
        },
        '/dashboard/formateur': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return FormateurDashboard(userData: args);
        },
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthService.getToken();
    final user = await AuthService.getUserData();

    if (token != null && token.isNotEmpty && user != null) {
      final role = user['role']?.toString().toLowerCase();
      if (!mounted) return;
      if (role == 'entrepreneur') {
        Navigator.of(context).pushReplacementNamed('/dashboard/entrepreneur', arguments: user);
      } else if (role == 'investisseur') {
        Navigator.of(context).pushReplacementNamed('/dashboard/investisseur', arguments: user);
      } else if (role == 'prestataire') {
        Navigator.of(context).pushReplacementNamed('/dashboard/prestataire', arguments: user);
      } else if (role == 'formateur') {
        Navigator.of(context).pushReplacementNamed('/dashboard/formateur', arguments: user);
      } else {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF198754)),
      ),
    );
  }
}
