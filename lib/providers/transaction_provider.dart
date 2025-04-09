import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart' as models;
import '../models/category_model.dart' as models;
import '../models/budget_model.dart';
import '../services/local_storage_service.dart';

class TransactionProvider with ChangeNotifier {
  final LocalStorageService _storage;
  List<models.Transaction> _transactions = [];
  List<models.Category> _categories = [];
  List<Budget> _budgets = [];
  bool _isLoading = false;

  TransactionProvider(this._storage) {
    loadData();
  }

  List<models.Transaction> get transactions => _transactions;
  List<models.Category> get categories => _categories;
  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transactions = await _storage.getTransactions();
      _categories = await _storage.getCategories();
      _budgets = await _storage.getBudgets();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(models.Transaction transaction) async {
    try {
      final id = await _storage.insertTransaction(transaction);
      final newTransaction = models.Transaction(
        id: id,
        description: transaction.description,
        amount: transaction.amount,
        type: transaction.type,
        categoryId: transaction.categoryId,
        date: transaction.date,
        createdAt: transaction.createdAt,
      );
      _transactions.add(newTransaction);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> addCategory(models.Category category) async {
    try {
      final id = await _storage.insertCategory(category);
      final newCategory = models.Category(
        id: id,
        name: category.name,
        icon: category.icon,
        isExpense: category.isExpense,
        createdAt: category.createdAt,
      );
      _categories.add(newCategory);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding category: $e');
      rethrow;
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      final id = await _storage.insertBudget(budget);
      final newBudget = Budget(
        id: id,
        categoryId: budget.categoryId,
        amount: budget.amount,
        startDate: budget.startDate,
        endDate: budget.endDate,
        createdAt: budget.createdAt,
      );
      _budgets.add(newBudget);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding budget: $e');
      rethrow;
    }
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => t.type == models.TransactionType.income)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense() {
    return _transactions
        .where((t) => t.type == models.TransactionType.expense)
        .fold(0, (sum, t) => sum + t.amount);
  }

  List<models.Transaction> getTransactionsByCategory(int categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  Budget? getBudgetForCategory(int categoryId) {
    return _budgets.cast<Budget?>().firstWhere(
          (b) => b!.categoryId == categoryId,
          orElse: () => null,
        );
  }
}
