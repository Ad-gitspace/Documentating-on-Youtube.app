import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'services/upload_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await UploadManager().initQueue();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => UploadManager(),
      child: const DocsMeApp(),
    ),
  );
}

/// Root widget for the DocsMe application.
///
/// Determines the initial route based on whether the user is already
/// signed in (silent sign-in succeeds).
class DocsMeApp extends StatefulWidget {
  const DocsMeApp({super.key});

  @override
  State<DocsMeApp> createState() => _DocsMeAppState();
}

class _DocsMeAppState extends State<DocsMeApp> {
  bool _initialized = false;
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      await AuthService().init();
    } catch (e) {
      debugPrint('Error during auth init: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSignedIn = AuthService().currentUser != null;
          _initialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocsMe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: !_initialized
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : (_isSignedIn ? const MainShell() : const LoginScreen()),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainShell(),
      },
    );
  }
}
