import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum HabitStatus { none, success, failure }

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final DateTime _focusedDay = DateTime.now();
  late List<HabitStatus> _dayStatuses;

  @override
  void initState() {
    super.initState();
    final int daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;
    // Initialize with mock data for visualization
    _dayStatuses = List.generate(daysInMonth, (index) {
      if (index < 12) {
        return index % 4 == 0 ? HabitStatus.failure : HabitStatus.success;
      }
      return HabitStatus.none;
    });
  }

  void _onCellClick(int index, bool isLeftClick) {
    setState(() {
      if (isLeftClick) {
        _dayStatuses[index] = _dayStatuses[index] == HabitStatus.failure
            ? HabitStatus.none
            : HabitStatus.failure;
      } else {
        _dayStatuses[index] = _dayStatuses[index] == HabitStatus.success
            ? HabitStatus.none
            : HabitStatus.success;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String monthName = DateFormat(
      'MMMM',
      'es',
    ).format(_focusedDay).toUpperCase();
    final int monthNum = _focusedDay.month;
    final int daysInMonth = _dayStatuses.length;

    int successCount = _dayStatuses
        .where((s) => s == HabitStatus.success)
        .length;
    int failureCount = _dayStatuses
        .where((s) => s == HabitStatus.failure)
        .length;
    double percentage = (successCount + failureCount) == 0
        ? 0
        : (successCount / (successCount + failureCount)) * 100;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Info Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$monthNum - $monthName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ejercicio',
                          style: TextStyle(
                            color: Colors.pinkAccent,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'DETALLE',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Flexiones Normales (1 aunque sea)\nPlancha (10sec aunque sea)\nSentadilla Dividida (1 aunque sea)',
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10),

            // Tracker Grid
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              child: Column(
                children: [
                  // Days Header
                  Row(
                    children: List.generate(daysInMonth, (index) {
                      return Expanded(
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  // Habit Marking Row
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white10, width: 0.5),
                    ),
                    child: Row(
                      children: List.generate(daysInMonth, (index) {
                        final status = _dayStatuses[index];
                        Color? bgColor;
                        Widget? icon;

                        if (status == HabitStatus.success) {
                          bgColor = Colors.green.withValues(alpha: 0.2);
                          icon = const Icon(
                            Icons.check,
                            color: Colors.greenAccent,
                            size: 16,
                          );
                        } else if (status == HabitStatus.failure) {
                          bgColor = Colors.red.withValues(alpha: 0.2);
                          icon = const Icon(
                            Icons.close,
                            color: Colors.redAccent,
                            size: 16,
                          );
                        }

                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _onCellClick(index, true), // Left Click
                            onSecondaryTap: () =>
                                _onCellClick(index, false), // Right Click
                            child: Container(
                              decoration: BoxDecoration(
                                color: bgColor,
                                border: Border(
                                  left: index == 0
                                      ? BorderSide.none
                                      : const BorderSide(
                                          color: Colors.white10,
                                          width: 0.5,
                                        ),
                                ),
                              ),
                              child: icon != null ? Center(child: icon) : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Statistics Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  _buildStatCard(
                    Icons.check,
                    successCount.toString(),
                    Colors.greenAccent,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    Icons.close,
                    failureCount.toString(),
                    Colors.redAccent,
                  ),
                  const SizedBox(width: 16),
                  _buildStatCard(
                    Icons.percent,
                    percentage.toStringAsFixed(1),
                    Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
