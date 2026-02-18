import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HabitCalendar extends StatefulWidget {
  const HabitCalendar({super.key});

  @override
  State<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends State<HabitCalendar> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday; // 1 = Monday, ..., 7 = Sunday

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Month/Year Selector
                Row(
                  children: [
                    _buildIconButton(
                      Icons.chevron_left,
                      onTap: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildHeaderAction(
                      icon: Icons.calendar_today,
                      label: '${_focusedDay.year}',
                      onTap: () {}, // Future implementation for year picker
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      Icons.chevron_right,
                      onTap: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildIconButton(Icons.calendar_view_day_outlined),
                    const SizedBox(width: 20),
                    _buildIconButton(Icons.search),
                    const SizedBox(width: 20),
                    _buildIconButton(Icons.add, color: Colors.pinkAccent),
                  ],
                ),
              ],
            ),
          ),

          // Month Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              DateFormat('MMMM', 'es').format(_focusedDay).toUpperCase()[0] +
                  DateFormat('MMMM', 'es').format(_focusedDay).substring(1),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Weekday Headers
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _WeekdayLabel('L'),
                _WeekdayLabel('M'),
                _WeekdayLabel('M'),
                _WeekdayLabel(
                  'X',
                ), // 'X' is commonly used for Wednesday in Spain, but 'M' is also fine.
                _WeekdayLabel('J'),
                _WeekdayLabel('V'),
                _WeekdayLabel('S'),
                _WeekdayLabel('D'),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Calendar Grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate aspect ratio to fit 6 rows in the available height
                final double cellWidth = constraints.maxWidth / 7;
                final double cellHeight = constraints.maxHeight / 6;
                final double aspectRatio = cellWidth / cellHeight;

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: aspectRatio,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final dayOffset = index - (firstWeekday - 1);
                    final isFirstRow = index < 7;

                    if (dayOffset < 0 || dayOffset >= daysInMonth) {
                      return _CalendarCell(
                        day: null,
                        isToday: false,
                        events: const [],
                        showTopBorder: isFirstRow,
                      );
                    }

                    final day = dayOffset + 1;
                    final date = DateTime(
                      _focusedDay.year,
                      _focusedDay.month,
                      day,
                    );
                    final isToday = DateUtils.isSameDay(date, DateTime.now());

                    return _CalendarCell(
                      day: day,
                      isToday: isToday,
                      events: _getEventsForDay(day),
                      showTopBorder: isFirstRow,
                      isFirstOfMonth: day == 1,
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Action Bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.pinkAccent, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.pinkAccent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon, {
    Color color = Colors.pinkAccent,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderAction(
            icon: Icons.circle,
            label: 'Hoy',
            onTap: () {
              setState(() {
                _focusedDay = DateTime.now();
              });
            },
          ),
          Row(
            children: [
              _buildIconButton(Icons.error_outline, color: Colors.white54),
              const SizedBox(width: 24),
              _buildIconButton(Icons.inbox_outlined, color: Colors.white54),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getEventsForDay(int day) {
    return [];
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final int? day;
  final bool isToday;
  final List<Map<String, dynamic>> events;
  final bool showTopBorder;
  final bool isFirstOfMonth;

  const _CalendarCell({
    required this.day,
    required this.isToday,
    required this.events,
    this.showTopBorder = false,
    this.isFirstOfMonth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: showTopBorder
              ? const BorderSide(color: Colors.white10, width: 0.5)
              : BorderSide.none,
          bottom: const BorderSide(color: Colors.white10, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: day == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstOfMonth)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 2),
                    child: Text(
                      '${DateFormat('MMM', 'es').format(DateTime.now()).toUpperCase().substring(0, 3)}.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: isToday
                      ? const BoxDecoration(
                          color: Colors.pinkAccent,
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Text(
                    '$day',
                    style: TextStyle(
                      color: isToday ? Colors.white : Colors.white,
                      fontSize: 18,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                ...events.map(
                  (e) => Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: e['color'],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      e['label'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
