import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'database.dart';
import 'theme.dart';
import 'package:drift/drift.dart' as drift;

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
      home: const Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: HabitTrackerScreen(),
        ),
      ),
    );
  }
}

enum HabitStatus { none, success, failure }

class HabitModel {
  String? id;
  String name;
  String detail;
  final List<HabitStatus> statuses;

  HabitModel({
    this.id,
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
  List<HabitModel> _habits = [];
  List<TextEditingController> _nameControllers = [];
  List<TextEditingController> _detailControllers = [];
  bool _isMenuExpanded = false;
  bool _isDeleteMode = false;
  bool _isLoading = true;

  // Column width constants (base settings)
  final double _nameWidth = 150.0;
  final double _dayWidth = 22.0;
  final double _statWidth = 40.0;
  final double _pctWidth = 60.0;
  final double _minDetailWidth = 300.0;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  @override
  void dispose() {
    for (var c in _nameControllers) c.dispose();
    for (var c in _detailControllers) c.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);

    final dbHabits = await AppDatabase.instance.getAllHabits();

    final int daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;

    final List<HabitModel> loadedHabits = [];

    for (final dbHabit in dbHabits) {
      final entries = await AppDatabase.instance.getEntriesForHabit(dbHabit.id);

      final statuses = List.generate(daysInMonth, (index) {
        final day = index + 1;
        final entry = entries.cast<HabitEntry?>().firstWhere(
          (e) =>
              e?.date.year == _focusedDay.year &&
              e?.date.month == _focusedDay.month &&
              e?.date.day == day,
          orElse: () => null,
        );

        if (entry == null) return HabitStatus.none;
        return entry.status == 1 ? HabitStatus.success : HabitStatus.failure;
      });

      loadedHabits.add(
        HabitModel(
          id: dbHabit.id,
          name: dbHabit.name,
          detail: dbHabit.detail ?? '',
          statuses: statuses,
        ),
      );
    }

    if (mounted) {
      setState(() {
        for (var c in _nameControllers) c.dispose();
        for (var c in _detailControllers) c.dispose();

        _habits = loadedHabits;
        _nameControllers = _habits
            .map((h) => TextEditingController(text: h.name))
            .toList();
        _detailControllers = _habits
            .map((h) => TextEditingController(text: h.detail))
            .toList();
        _isLoading = false;
      });
    }
  }

  void _changeMonth(int offset) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + offset);
    });
    _loadHabits();
  }

  void _addHabit() async {
    await AppDatabase.instance.upsertHabit(
      const HabitsCompanion(
        name: drift.Value('NUEVO HÁBITO'),
        detail: drift.Value(''),
      ),
    );
    _loadHabits();
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _isMenuExpanded = false;
    });
  }

  void _deleteHabit(int index) async {
    final habit = _habits[index];
    if (habit.id != null) {
      await AppDatabase.instance.softDeleteHabit(habit.id!);
      _loadHabits();
    }
  }

  void _onCellClick(int habitIndex, int dayIndex, bool isLeftClick) async {
    final habit = _habits[habitIndex];
    if (habit.id == null) return;

    final statuses = habit.statuses;
    HabitStatus newStatus;
    if (isLeftClick) {
      newStatus = statuses[dayIndex] == HabitStatus.failure
          ? HabitStatus.none
          : HabitStatus.failure;
    } else {
      newStatus = statuses[dayIndex] == HabitStatus.success
          ? HabitStatus.none
          : HabitStatus.success;
    }

    setState(() {
      statuses[dayIndex] = newStatus;
    });

    final date = DateTime(_focusedDay.year, _focusedDay.month, dayIndex + 1);
    int statusInt = 0;
    if (newStatus == HabitStatus.success) statusInt = 1;
    if (newStatus == HabitStatus.failure) statusInt = 2;

    await AppDatabase.instance.upsertEntry(
      HabitEntriesCompanion(
        habitId: drift.Value(habit.id!),
        date: drift.Value(date),
        status: drift.Value(statusInt),
      ),
    );
  }

  void _updateHabit(int habitIndex) async {
    final habit = _habits[habitIndex];
    if (habit.id == null) return;

    await AppDatabase.instance.upsertHabit(
      HabitsCompanion(
        id: drift.Value(habit.id!),
        name: drift.Value(_nameControllers[habitIndex].text),
        detail: drift.Value(_detailControllers[habitIndex].text),
      ),
    );
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

    final double screenWidth = MediaQuery.of(context).size.width;
    final double baseWidthWithoutDetail =
        2.0 +
        _nameWidth +
        (daysInMonth * _dayWidth) +
        (_statWidth * 2) +
        _pctWidth +
        32;

    final double currentDetailWidth =
        (screenWidth > baseWidthWithoutDetail + _minDetailWidth)
        ? screenWidth - baseWidthWithoutDetail
        : _minDetailWidth;

    final double totalWidth = baseWidthWithoutDetail - 32 + currentDetailWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            )
          : Stack(
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
                                color: Colors.pinkAccent,
                                size: 32,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            SizedBox(
                              width: 320,
                              child: Center(
                                child: Text(
                                  '$monthNum - $monthName',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _changeMonth(1),
                              icon: const Icon(
                                Icons.chevron_right,
                                color: Colors.pinkAccent,
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
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: totalWidth,
                                height: constraints.maxHeight,
                                child: Column(
                                  children: [
                                    _buildTableHeader(
                                      daysInMonth,
                                      currentDetailWidth,
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: _habits.length,
                                        itemBuilder: (context, index) {
                                          return _buildHabitRow(
                                            index,
                                            daysInMonth,
                                            currentDetailWidth,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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

  Widget _buildTableHeader(int days, double detailWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 2),
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
            width: detailWidth,
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

  Widget _buildHabitRow(int habitIndex, int days, double detailWidth) {
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
                    onChanged: (val) {
                      habit.name = val;
                      _updateHabit(habitIndex);
                    },
                    enabled: !_isDeleteMode,
                    style: TextStyle(
                      color: _isDeleteMode ? Colors.redAccent : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
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
            width: detailWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                controller: _detailControllers[habitIndex],
                onChanged: (val) {
                  habit.detail = val;
                  _updateHabit(habitIndex);
                },
                enabled: !_isDeleteMode,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                decoration: const InputDecoration(
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

