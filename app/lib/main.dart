import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/workout_foreground_service.dart';
import 'core/theme/theme.dart';
import 'features/exercise/presentation/screens/workout_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WorkoutForegroundService.init();
  runApp(const ProviderScope(child: VieApp()));
}

class VieApp extends StatelessWidget {
  const VieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WorkoutHomeScreen(),
    );
  }
}
