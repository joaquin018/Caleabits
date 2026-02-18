import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'calendar_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const HabitsApp());
}

class HabitsApp extends StatelessWidget {
  const HabitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habits',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Inter',
      ),
      home: const HabitCalendar(),
    );
  }
}
