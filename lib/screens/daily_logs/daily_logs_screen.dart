import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/log_entry_model.dart';
import '../../providers/log_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'log_entry_screen.dart';
import 'log_search_screen.dart';
import '../money_tracker/money_tracker_screen.dart';

class DailyLogsScreen extends StatefulWidget {
  const DailyLogsScreen({super.key});

  @override
  State<DailyLogsScreen> createState() => _DailyLogsScreenState();
}

class _DailyLogsScreenState extends State<DailyLogsScreen> {
  DateTime _selectedDate = DateTime.now();
  final PageController _pageController = PageController();
  bool _showMoneyTracker = false;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _showMoneyTracker = index == 1;
            });
          },
          children: [
            _buildMainContent(),
            const MoneyTrackerScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => _showSearch(context),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          color: const Color(0xFF2C2C2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.now(),
            focusedDay: _selectedDate,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarStyle: CalendarStyle(
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white70),
              selectedTextStyle: const TextStyle(color: Colors.black),
              selectedDecoration: const BoxDecoration(
                color: Colors.tealAccent,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.tealAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(color: Colors.white),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(32)),
              child: _buildLogsList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogsList() {
    return Consumer<LogProvider>(
      builder: (context, logProvider, child) {
        if (logProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final logs = logProvider.getLogsByDate(_selectedDate);

        if (logs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.note_add,
                  size: 48,
                  color: Colors.white70,
                ),
                const SizedBox(height: 16),
                Text(
                  'No logs for today',
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => _addNewLog(context),
                  child: const Text('Add Log'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: logs.length + 1, // +1 for the "Add Log" button
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: OutlinedButton(
                  onPressed: () => _addNewLog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.tealAccent),
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 8),
                      Text('Add Log'),
                    ],
                  ),
                ),
              );
            }

            final log = logs[index - 1];
            return _buildLogCard(log, logProvider);
          },
        );
      },
    );
  }

  Widget _buildLogCard(LogEntry log, LogProvider provider) {
    return Dismissible(
      key: Key(log.id.toString()),
      background: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await provider.deleteLog(log.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log deleted')),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: InkWell(
          onTap: () => _editLog(context, log),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('h:mm a').format(log.date),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  log.content,
                  style: AppTextStyles.body1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LogSearchScreen()),
    );
  }

  void _addNewLog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LogEntryScreen(date: _selectedDate)),
    );
  }

  void _editLog(BuildContext context, LogEntry log) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LogEntryScreen(log: log)),
    );
  }
}
