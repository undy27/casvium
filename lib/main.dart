import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/casvium_home_shell.dart';
import 'services/railway_postgres_service.dart';
import 'theme/casvium_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? preferences;
  try {
    preferences = await SharedPreferences.getInstance();
  } catch (error) {
    debugPrint('No se pudo abrir el almacenamiento local: $error');
  }
  final store = CasviumStore(preferences: preferences);
  runApp(CasviumApp(store: store));
}

class CasviumApp extends StatelessWidget {
  final CasviumStore store;

  const CasviumApp({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Casvium · Hogar & Tareas',
      debugShowCheckedModeBanner: false,
      theme: CasviumTheme.build(),
      home: CasviumHomeShell(store: store),
    );
  }
}
