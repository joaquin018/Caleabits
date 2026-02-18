import 'package:flutter/material.dart';
import 'package:habits/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:habits/features/habits/presentation/screens/habit_tracker_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white10, width: 0.5),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Colors.pinkAccent,
            indicatorWeight: 3,
            labelColor: Colors.pinkAccent,
            unselectedLabelColor: Colors.white24,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            tabs: const [
              Tab(text: 'CALENDARIO'),
              Tab(text: 'HÁBITOS'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [CalendarScreen(), HabitTrackerScreen()],
      ),
    );
  }
}
