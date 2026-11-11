import 'package:flutter/material.dart';
import 'screens/casvium_home_shell.dart';
import 'services/railway_postgres_service.dart';
import 'theme/casvium_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final store = CasviumStore();
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
