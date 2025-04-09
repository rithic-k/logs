import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/log_entry_model.dart';
import '../../providers/log_provider.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class LogEntryScreen extends StatefulWidget {
  final LogEntry? log;
  final DateTime? date;

  const LogEntryScreen({
    super.key,
    this.log,
    this.date,
  }) : assert(log != null || date != null);

  @override
  State<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends State<LogEntryScreen> {
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.log != null) {
      _contentController.text = widget.log!.content;
    }
  }

  Future<void> _saveLog() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final logProvider = Provider.of<LogProvider>(context, listen: false);
      final log = LogEntry(
        id: widget.log?.id,
        content: _contentController.text,
        date: widget.log?.date ?? widget.date!,
      );

      await logProvider.addLog(log);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save log')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveLog,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'What\'s on your mind?',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textPrimary,
                fontSize: 24,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: TextField(
                  controller: _contentController,
                  style: AppTextStyles.body1,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(24),
                    hintText: 'Start typing...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
