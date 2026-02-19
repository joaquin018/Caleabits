import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum HabitStatus { none, success, failure }

class HabitModel {
  String name;
  String detail;
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
  late List<TextEditingController> _nameControllers;
  late List<TextEditingController> _detailControllers;
  bool _isMenuExpanded = false;
  bool _isDeleteMode = false;

  final double _nameWidth = 150.0;
  final double _dayWidth = 22.0;
  final double _statWidth = 40.0;
  final double _pctWidth = 60.0;
  final double _detailWidth = 300.0;

  @override
  void initState() {
    super.initState();
    _initializeHabits(firstTime: true);
  }

  @override
  void dispose() {
    for (var c in _nameControllers) c.dispose();
    for (var c in _detailControllers) c.dispose();
    super.dispose();
  }

  void _initializeHabits({bool firstTime = false}) {
    if (!firstTime) {
      for (var c in _nameControllers) c.dispose();
      for (var c in _detailControllers) c.dispose();
    }

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

    _nameControllers = _habits
        .map((h) => TextEditingController(text: h.name))
        .toList();
    _detailControllers = _habits
        .map((h) => TextEditingController(text: h.detail))
        .toList();
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + offset);
      _initializeHabits();
    });
  }

  void _addHabit() {
    final int daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;
    setState(() {
      final h = HabitModel(
        name: '',
        detail: '',
        statuses: List.generate(daysInMonth, (index) => HabitStatus.none),
      );
      _habits.add(h);
      _nameControllers.add(TextEditingController(text: ''));
      _detailControllers.add(TextEditingController(text: ''));
      _isMenuExpanded = false;
    });
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _isMenuExpanded = false;
    });
  }

  void _deleteHabit(int index) {
    setState(() {
      _habits.removeAt(index);
      _nameControllers[index].dispose();
      _nameControllers.removeAt(index);
      _detailControllers[index].dispose();
      _detailControllers.removeAt(index);
      if (_habits.isEmpty) _isDeleteMode = false;
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
        2.0 +
        _nameWidth +
        (daysInMonth * _dayWidth) +
        (_statWidth * 2) +
        _pctWidth +
        _detailWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      if (_isDeleteMode) ...[
                        const SizedBox(width: 20),
                        const Text(
                          'MODO ELIMINAR ACTIVO',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              setState(() => _isDeleteMode = false),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white54,
                            size: 18,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

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

          Positioned(
            bottom: 30,
            right: 30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isMenuExpanded) ...[
                  _buildMenuButton(
                    icon: Icons.add,
                    color: Colors.greenAccent,
                    onTap: _addHabit,
                  ),
                  const SizedBox(width: 12),
                  _buildMenuButton(
                    icon: Icons.remove,
                    color: Colors.redAccent,
                    onTap: _toggleDeleteMode,
                  ),
                  const SizedBox(width: 12),
                ],
                _buildMenuButton(
                  icon: _isMenuExpanded
                      ? Icons.chevron_right
                      : Icons.chevron_left,
                  color: Colors.pinkAccent,
                  onTap: () =>
                      setState(() => _isMenuExpanded = !_isMenuExpanded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        ),
        child: Icon(icon, color: color, size: 28),
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
          const SizedBox(width: 2), // Guard for border
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
      decoration: BoxDecoration(
        border: Border(
          bottom: const BorderSide(color: Colors.white10, width: 0.5),
          left: BorderSide(
            color: _isDeleteMode ? Colors.redAccent : Colors.transparent,
            width: 2.0,
          ),
        ),
        color: _isDeleteMode ? Colors.redAccent.withValues(alpha: 0.05) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: _nameWidth,
            child: Row(
              children: [
                if (_isDeleteMode) ...[
                  IconButton(
                    onPressed: () => _deleteHabit(habitIndex),
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: TextField(
                    controller: _nameControllers[habitIndex],
                    onChanged: (val) => habit.name = val,
                    enabled: !_isDeleteMode,
                    style: TextStyle(
                      color: _isDeleteMode ? Colors.redAccent : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Hábito...',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(days, (dayIndex) {
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
              onTap: _isDeleteMode
                  ? null
                  : () => _onCellClick(habitIndex, dayIndex, true),
              onSecondaryTap: _isDeleteMode
                  ? null
                  : () => _onCellClick(habitIndex, dayIndex, false),
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
              child: TextField(
                controller: _detailControllers[habitIndex],
                onChanged: (val) => habit.detail = val,
                enabled: !_isDeleteMode,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Detalle...',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
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
