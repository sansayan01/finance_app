import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Initialize Supabase with production credentials
  try {
    await Supabase.initialize(
      url: 'https://tccwdpsnuudzfyxfoohk.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRjY3dkcHNudXVkemZ5eGZvb2hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgzNDQ1MTgsImV4cCI6MjA5MzkyMDUxOH0.I3B-A6YIrC2XlFlbf1eyTVqmcVJUOOcOUBYstpYE9_Y',
    );
  } catch (e) {
    debugPrint('Supabase initialization skipped: $e');
  }

  runApp(
    const ProviderScope(
      child: MicroFlowApp(),
    ),
  );
}