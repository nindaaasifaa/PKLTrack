import 'package:flutter/material.dart';

import 'services/nama_profil_siswa_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NamaProfilSiswaService.inisialisasi();
  runApp(const PKLTrackApp());
}

class PKLTrackApp extends StatelessWidget {
  const PKLTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PKLTrack',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/splash': (context) => const SplashScreen(),
      },
    );
  }
}