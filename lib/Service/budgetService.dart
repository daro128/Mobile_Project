
import '../models/budget.dart';
import '../models/transaction.dart';

class BudgetService {
  final List<Budget> _budgets = [];

  List<Budget> get budgets => List.unmodifiable(_budgets);

  // Find budget
  Budget? _findBudget(String id) {
    for (var budget in _budgets) {
      if (budget.id == id) {
        return budget;
      }
    }
    return null;
  }

  Budget? getBudgetByCategory({
    required String categoryId,
    required int month,
    required int year,
  }) {
    for (var budget in _budgets) {
      if (budget.categoryId == categoryId &&
          budget.month == month &&
          budget.year == year) {
        return budget;
      }
    }
    return null;
  }

  void _validateLimit(double limit) {
    if (limit <= 0) {
      throw Exception('Budget limit must be positive');
    }
  }

  void _validateDate(int month, int year) {
    if (month < 1 || month > 12) {
      throw Exception('Invalid month');
    }

    if (year < 1) {
      throw Exception('Invalid year');
    }
  }

  void addBudget({
    required String id,
    required String categoryId,
    required double limit,
    required int month,
    required int year,
  }) {
    if (id.trim().isEmpty) {
      throw Exception('Budget ID cannot be empty');
    }

    if (categoryId.trim().isEmpty) {
      throw Exception('Category ID cannot be empty');
    }

    _validateLimit(limit);
    _validateDate(month, year);

    if (_findBudget(id) != null) {
      throw Exception('Budget ID already exists');
    }

    if (getBudgetByCategory(
          categoryId: categoryId,
          month: month,
          year: year,
        ) !=
        null) {
      throw Exception('Budget for this category already exists');
    }

    _budgets.add(
      Budget(
        id: id,
        categoryId: categoryId,
        limit: limit,
        month: month,
        year: year,
      ),
    );
  }

  void updateBudget({required String id, double? newLimit}) {
    final index = _budgets.indexWhere((budget) => budget.id == id);

    if (index == -1) {
      throw Exception('Budget not found');
    }

    if (newLimit != null) {
      _validateLimit(newLimit);
    }

    _budgets[index] = _budgets[index].updateBudget(limit: newLimit);
  }

  // Delete budget
  void deleteBudget(String id) {
    final index = _budgets.indexWhere((budget) => budget.id == id);

    if (index == -1) {
      throw Exception('Budget not found');
    }

    _budgets.removeAt(index);
  }

  List<Budget> getBudgetsByMonth({
    required int month,
    required int year,
  }) {
    return _budgets
        .where(
          (budget) => budget.month == month && budget.year == year,
        )
        .toList();
  }

  double getCategorySpending({
    required String categoryId,
    required List<Transaction> transactions,
    required int month,
    required int year,
  }) {
    double total = 0;

    for (var transaction in transactions) {
      if (transaction.categoryId == categoryId &&
          transaction.type == TransactionType.expense &&
          transaction.date.month == month &&
          transaction.date.year == year) {
        total += transaction.amount;
      }
    }

    return total;
  }

  double getBudgetProgress({
    required String categoryId,
    required List<Transaction> transactions,
    required int month,
    required int year,
  }) {
    final budget = getBudgetByCategory(
      categoryId: categoryId,
      month: month,
      year: year,
    );

    if (budget == null) {
      throw Exception('Budget not found');
    }

    final spending = getCategorySpending(
      categoryId: categoryId,
      transactions: transactions,
      month: month,
      year: year,
    );

    return spending / budget.limit;
  }

  double getRemainingBudget({
    required String categoryId,
    required List<Transaction> transactions,
    required int month,
    required int year,
  }) {
    final budget = getBudgetByCategory(
      categoryId: categoryId,
      month: month,
      year: year,
    );

    if (budget == null) {
      throw Exception('Budget not found');
    }

    final spending = getCategorySpending(
      categoryId: categoryId,
      transactions: transactions,
      month: month,
      year: year,
    );

    return budget.limit - spending;
  }

  bool isBudgetExceeded({
    required String categoryId,
    required List<Transaction> transactions,
    required int month,
    required int year,
  }) {
    final progress = getBudgetProgress(
      categoryId: categoryId,
      transactions: transactions,
      month: month,
      year: year,
    );

    return progress > 1;
  }
}
