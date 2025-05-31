import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Seus imports de tela
import 'screens/dashboard_screen.dart';
import 'screens/monitoring_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/maintenance_screen.dart';
import 'screens/configuration_screen.dart';
import 'screens/about_screen.dart';

// --- Configuração do Supabase ---
const String supabaseUrl = 'https://dfyyieapoytaaypqbewn.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRmeXlpZWFwb3l0YWF5cHFiZXduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2Njg1NzEsImV4cCI6MjA2NDI0NDU3MX0.EQvuq-xXqYsTXIgJG0bwFrA4W0sDIAF56DjTc3DHeQE';
// --- Fim da Configuração do Supabase ---

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Removido: override desnecessário do didChangeAppLifecycleState

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estação Separadora de Peças',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade700,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          elevation: 4.0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        cardTheme: const CardThemeData(
          // Corrigido para CardThemeData
          elevation: 3.0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900]),
          titleMedium: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800]),
          titleSmall: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Colors.black87),
          bodyLarge: const TextStyle(fontSize: 16.0),
          bodyMedium: const TextStyle(fontSize: 14.0, color: Colors.black87),
          bodySmall: TextStyle(fontSize: 12.0, color: Colors.grey[700]),
          labelLarge:
              const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
        ),
      ),
      initialRoute: DashboardScreen.routeName,
      routes: {
        DashboardScreen.routeName: (context) => const DashboardScreen(),
        MonitoringScreen.routeName: (context) => const MonitoringScreen(),
        ReportsScreen.routeName: (context) => const ReportsScreen(),
        MaintenanceScreen.routeName: (context) => const MaintenanceScreen(),
        ConfigurationScreen.routeName: (context) => const ConfigurationScreen(),
        AboutScreen.routeName: (context) => const AboutScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
