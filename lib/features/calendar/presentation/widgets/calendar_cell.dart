import 'package:flutter/material.dart';

class CalendarCell extends StatelessWidget {
  final int? day;
  final bool isToday;
  final List<Map<String, dynamic>> events;
  final bool showTopBorder;
  final bool isFirstOfMonth;

  const CalendarCell({
    super.key,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
