import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/log_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class LogCalendarScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const LogCalendarScreen({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<LogCalendarScreen> createState() => _LogCalendarScreenState();
}

class _LogCalendarScreenState extends State<LogCalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
    _selectedDay = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Consumer<LogProvider>(
        builder: (context, logProvider, child) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                eventLoader: (day) {
                  return logProvider.getLogsByDate(day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  widget.onDateSelected(selectedDay);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logProvider.getLogsByDate(_selectedDay).length,
                  itemBuilder: (context, index) {
                    final log = logProvider.getLogsByDate(_selectedDay)[index];
                    return ListTile(
                      title: Text(
                        log.content,
                        style: AppTextStyles.body1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Created at ${log.createdAt.hour}:${log.createdAt.minute}',
                        style: AppTextStyles.caption,
                      ),
                      leading: log.imagePath != null
                          ? const Icon(Icons.image)
                          : const Icon(Icons.notes),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
