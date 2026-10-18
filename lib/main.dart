import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Si la plataforma web no sirve el archivo .env, se usan las variables de entorno o fallbacks
  }

  const defaultUrl = 'https://cnpupavojispfagmbghm.supabase.co';
  const defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNucHVwYXZvamlzcGZhZ21iZ2htIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzNDU1MjcsImV4cCI6MjEwNjkyMTUyN30.QnHjkugTYY_Jl32r8zVTI3BCxRBPJRaIL0SyCjOZplc';

  final supabaseUrl = dotenv.env['SUPABASE_URL'] ??
      const String.fromEnvironment('SUPABASE_URL', defaultValue: defaultUrl);
  final supabasePublishableKey = dotenv.env['SUPABASE_ANON_KEY'] ??
      const String.fromEnvironment('SUPABASE_ANON_KEY',
          defaultValue: defaultAnonKey);

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(
    const ProviderScope(
      child: TramaApp(),
    ),
  );
}