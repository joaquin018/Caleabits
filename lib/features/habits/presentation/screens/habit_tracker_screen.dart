import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum HabitStatus { none, success, failure }

class HabitModel {
  final String name;
  final String detail;
  final List<HabitStatus> statuses;

  HabitModel({
    required this.name,
    required this.detail,
    required this.statuses,
  });
}

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  DateTime _focusedDay = DateTime.now();
  late List<HabitModel> _habits;

  // Column width constants
  final double _nameWidth = 150.0;
  final double _dayWidth = 22.0;
  final double _statWidth = 40.0;
  final double _pctWidth = 60.0;
  final double _detailWidth = 300.0;

  @override
  void initState() {
    super.initState();
    _initializeHabits();
  }

  void _initializeHabits() {
    final int daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;

    _habits = [
      HabitModel(
        name: 'Ejercicio',
        detail: 'Flexiones, Plancha, Sentadilla Dividida',
        statuses: List.generate(
          daysInMonth,
          (index) => index < 10
              ? (index % 3 == 0 ? HabitStatus.failure : HabitStatus.success)
              : HabitStatus.none,
        ),
      ),
      HabitModel(
        name: 'Anki',
        detail: '10 / 20 flashcards por día',
        statuses: List.generate(
          daysInMonth,
          (index) => index < 15
              ? (index % 5 == 0 ? HabitStatus.failure : HabitStatus.success)
              : HabitStatus.none,
        ),
      ),
      HabitModel(
        name: 'Lectura',
        detail: '1 Página de un libro / lectura extensa',
        statuses: List.generate(
          daysInMonth,
          (index) => index < 12
              ? (index % 4 == 0 ? HabitStatus.failure : HabitStatus.success)
              : HabitStatus.none,
        ),
      ),
      HabitModel(
        name: 'Aimlab',
        detail: 'Voltaic Valorant Benchmark',
        statuses: List.generate(
          daysInMonth,
          (index) => index < 20
              ? (index % 6 == 0 ? HabitStatus.failure : HabitStatus.success)
              : HabitStatus.none,
        ),
      ),
    ];
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + offset);
      _initializeHabits();
    });
  }

  void _onCellClick(int habitIndex, int dayIndex, bool isLeftClick) {
    setState(() {
      final statuses = _habits[habitIndex].statuses;
      if (isLeftClick) {
        statuses[dayIndex] = statuses[dayIndex] == HabitStatus.failure
            ? HabitStatus.none
            : HabitStatus.failure;
      } else {
        statuses[dayIndex] = statuses[dayIndex] == HabitStatus.success
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
    final int daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;
    final double totalWidth =
        _nameWidth +
        (daysInMonth * _dayWidth) +
        (_statWidth * 2) +
        _pctWidth +
        _detailWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header with Navigation
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Colors.redAccent,
                      size: 32,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$monthNum - $monthName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Colors.redAccent,
                      size: 32,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Scrollable Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalWidth,
                  child: Column(
                    children: [
                      _buildTableHeader(daysInMonth),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            return _buildHabitRow(index, daysInMonth);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(int days) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _nameWidth,
            child: const Text(
              'HÁBITO',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...List.generate(
            days,
            (i) => SizedBox(
              width: _dayWidth,
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          _buildHeaderColumn('✓', _statWidth),
          _buildHeaderColumn('X', _statWidth),
          _buildHeaderColumn('%', _pctWidth),
          SizedBox(
            width: _detailWidth,
            child: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'DETALLE',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderColumn(String label, double width) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHabitRow(int habitIndex, int days) {
    final habit = _habits[habitIndex];
    int success = habit.statuses.where((s) => s == HabitStatus.success).length;
    int failure = habit.statuses.where((s) => s == HabitStatus.failure).length;
    double percentage = (success + failure) == 0
        ? 0
        : (success / (success + failure)) * 100;

    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _nameWidth,
            child: Text(
              habit.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...List.generate(days, (dayIndex) {
            // Guard against different month lengths when switching
            if (dayIndex >= habit.statuses.length)
              return const SizedBox.shrink();

            final status = habit.statuses[dayIndex];
            Color? bgColor;
            IconData? icon;
            Color? iconColor;

            if (status == HabitStatus.success) {
              bgColor = Colors.green.withValues(alpha: 0.2);
              icon = Icons.check;
              iconColor = Colors.greenAccent;
            } else if (status == HabitStatus.failure) {
              bgColor = Colors.red.withValues(alpha: 0.2);
              icon = Icons.close;
              iconColor = Colors.redAccent;
            }

            return GestureDetector(
              onTap: () => _onCellClick(habitIndex, dayIndex, true),
              onSecondaryTap: () => _onCellClick(habitIndex, dayIndex, false),
              child: Container(
                width: _dayWidth,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: const Border(
                    left: BorderSide(color: Colors.white10, width: 0.5),
                  ),
                ),
                child: icon != null
                    ? Center(child: Icon(icon, color: iconColor, size: 12))
                    : null,
              ),
            );
          }),
          _buildStatValue(success.toString(), _statWidth, Colors.greenAccent),
          _buildStatValue(failure.toString(), _statWidth, Colors.redAccent),
          _buildStatValue(
            '${percentage.toStringAsFixed(1)}%',
            _pctWidth,
            Colors.white,
          ),
          SizedBox(
            width: _detailWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                habit.detail,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatValue(String value, double width, Color color) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Center(
        child: Text(value, style: TextStyle(color: color, fontSize: 12)),
      ),
    );
  }
}
