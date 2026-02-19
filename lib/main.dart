import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'core/database/app_database.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize CRDT Database Clock with a persistent nodeId
  final prefs = await SharedPreferences.getInstance();
  String? nodeId = prefs.getString('crdt_node_id');
  if (nodeId == null) {
    nodeId = const Uuid().v4();
    await prefs.setString('crdt_node_id', nodeId);
  }
  AppDatabase.instance.initClock(nodeId);

  await initializeDateFormatting('es', null);
  runApp(const CaleabitsApp());
}

class CaleabitsApp extends StatelessWidget {
  const CaleabitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caleabits',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainHomeScreen(),
    );
  }
}
