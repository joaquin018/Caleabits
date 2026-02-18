import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/calendar_cell.dart';
import '../widgets/weekday_label.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildMonthTitle(),
          _buildWeekdayHeaders(),
          const Divider(),
          _buildCalendarGrid(daysInMonth, firstWeekday),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildIconButton(
                Icons.chevron_left,
                onTap: () => setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month - 1,
                  );
                }),
              ),
              const SizedBox(width: 8),
              _buildHeaderAction(
                icon: Icons.calendar_today,
                label: '${_focusedDay.year}',
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _buildIconButton(
                Icons.chevron_right,
                onTap: () => setState(() {
                  _focusedDay = DateTime(
                    _focusedDay.year,
                    _focusedDay.month + 1,
                  );
                }),
              ),
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildMonthTitle() {
    return Padding(
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
    );
  }

  Widget _buildWeekdayHeaders() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          WeekdayLabel('L'),
          WeekdayLabel('M'),
          WeekdayLabel('M'),
          WeekdayLabel('J'),
          WeekdayLabel('V'),
          WeekdayLabel('S'),
          WeekdayLabel('D'),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(int daysInMonth, int firstWeekday) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double cellWidth = constraints.maxWidth / 7;
          final double cellHeight = constraints.maxHeight / 6;
          final double aspectRatio = cellWidth / cellHeight;

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: aspectRatio,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayOffset = index - (firstWeekday - 1);
              final isFirstRow = index < 7;

              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return CalendarCell(
                  day: null,
                  isToday: false,
                  events: const [],
                  showTopBorder: isFirstRow,
                );
              }

              final day = dayOffset + 1;
              final date = DateTime(_focusedDay.year, _focusedDay.month, day);
              final isToday = DateUtils.isSameDay(date, DateTime.now());

              return CalendarCell(
                day: day,
                isToday: isToday,
                events: const [],
                showTopBorder: isFirstRow,
                isFirstOfMonth: day == 1,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
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
            onTap: () => setState(() {
              _focusedDay = DateTime.now();
            }),
          ),
          const SizedBox.shrink(),
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
}
