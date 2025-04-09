import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/log_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'log_entry_screen.dart';

class LogSearchScreen extends StatefulWidget {
  const LogSearchScreen({super.key});

  @override
  State<LogSearchScreen> createState() => _LogSearchScreenState();
}

class _LogSearchScreenState extends State<LogSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: AppTextStyles.body1,
          decoration: InputDecoration(
            hintText: 'Search logs...',
            hintStyle: AppTextStyles.body2,
            border: InputBorder.none,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      body: Consumer<LogProvider>(
        builder: (context, logProvider, child) {
          if (_searchQuery.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Enter text to search logs',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          final searchResults = logProvider.searchLogs(_searchQuery);

          if (searchResults.isEmpty) {
            return Center(
              child: Text(
                'No logs found',
                style: AppTextStyles.body1
                    .copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final log = searchResults[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LogEntryScreen(log: log),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              DateFormat('MMM d, y').format(log.date),
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('h:mm a').format(log.date),
                              style: AppTextStyles.caption,
                            ),
                            if (log.imagePath != null) ...[
                              const Spacer(),
                              const Icon(
                                Icons.image,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          log.content,
                          style: AppTextStyles.body1,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
