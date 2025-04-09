import 'package:flutter/foundation.dart';
import '../models/log_entry_model.dart';
import '../services/local_storage_service.dart';

class LogProvider with ChangeNotifier {
  final LocalStorageService _storage;
  List<LogEntry> _logs = [];
  bool _isLoading = false;

  LogProvider(this._storage) {
    loadLogs();
  }

  List<LogEntry> get logs => _logs;
  bool get isLoading => _isLoading;

  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _logs = await _storage.getLogs();
    } catch (e) {
      debugPrint('Error loading logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addLog(LogEntry log) async {
    try {
      final id = await _storage.insertLog(log);
      final newLog = LogEntry(
        id: id,
        content: log.content,
        date: log.date,
        imagePath: log.imagePath,
        createdAt: log.createdAt,
        updatedAt: log.updatedAt,
      );
      _logs.add(newLog);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding log: $e');
      rethrow;
    }
  }

  Future<void> deleteLog(int id) async {
    try {
      await _storage.deleteLog(id);
      _logs.removeWhere((log) => log.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting log: $e');
      rethrow;
    }
  }

  List<LogEntry> getLogsByDate(DateTime date) {
    return _logs
        .where((log) =>
            log.date.year == date.year &&
            log.date.month == date.month &&
            log.date.day == date.day)
        .toList();
  }

  List<LogEntry> searchLogs(String query) {
    return _logs
        .where((log) => log.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
