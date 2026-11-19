
import 'package:test/test.dart';
import '../models/transaction.dart';
import '../service/budgetService.dart';

void main() {
  group('BudgetService', () {
    // Add budget
    test('adds a new budget', () {
      final budgetService = BudgetService();

      budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 11, year: 2026);

      expect(budgetService.budgets.length, 1);
      expect(budgetService.budgets.first.limit, 500);
    });

    test('cannot add budget with duplicate ID', () {
      final budgetService = BudgetService();

      budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 11, year: 2026);

      expect(() => budgetService.addBudget(id: 'B1', categoryId: 'C2', limit: 300, month: 11, year: 2026), throwsException);
    });

    test('cannot add budget with duplicate category and month', () {
      final budgetService = BudgetService();

      budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 11, year: 2026);

      expect(() => budgetService.addBudget(id: 'B2', categoryId: 'C1', limit: 300, month: 11, year: 2026), throwsException);
    });

    test('cannot add budget with invalid limit', () {
      final budgetService = BudgetService();

      expect(() => budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 0, month: 11, year: 2026), throwsException);
    });

    test('cannot add budget with invalid month', () {
      final budgetService = BudgetService();

      expect(() => budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 13, year: 2026), throwsException);
    });

    // Update budget
    test('updates an existing budget', () {
      final budgetService = BudgetService();

      budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 11, year: 2026);
      budgetService.updateBudget(id: 'B1', newLimit: 800);

      expect(budgetService.budgets.first.limit, 800);
    });

    test('cannot update budget with invalid limit', () {
      final budgetService = BudgetService();

      budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 11, year: 2026);

      expect(() => budgetService.updateBudget(id: 'B1', newLimit: -100), throwsException);
    });

    test('cannot update budget that does not exist', () {
      final budgetService = BudgetService();

      expect(() => budgetService.updateBudget(id: 'B1', newLimit: 800), throwsException);
    });

    // Delete budget
    test('deletes an existing budget', () {
      final budgetService = BudgetService();

      budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 11, year: 2026);
      budgetService.deleteBudget('B1');

      expect(budgetService.budgets, isEmpty);
    });

    test('cannot delete budget that does not exist', () {
      final budgetService = BudgetService();

      expect(() => budgetService.deleteBudget('B1'), throwsException);
    });

    // Get budget
    test('gets budget by category, month and year', () {
      final budgetService = BudgetService();

      budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 11, year: 2026);

      expect(budgetService.getBudgetByCategory(categoryId: 'C1', month: 11, year: 2026)!.id, 'B1');
    });

    // Budget spending
    test('calculates category spending', () {
      final budgetService = BudgetService();
      final transactions = [
        Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.expense, amount: 100, date: DateTime(2026, 11, 5)),
        Transaction(id: 'T2', accountId: 'A1', categoryId: 'C1', type: TransactionType.expense, amount: 50, date: DateTime(2026, 11, 10)),
        Transaction(id: 'T3', accountId: 'A1', categoryId: 'C1', type: TransactionType.income, amount: 200, date: DateTime(2026, 11, 15)),
      ];

      expect(budgetService.getCategorySpending(categoryId: 'C1', transactions: transactions, month: 11, year: 2026), 150);
    });

    test('calculates budget progress', () {
      final budgetService = BudgetService();
      final transactions = [
        Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.expense, amount: 200, date: DateTime(2026, 11, 5)),
      ];

      budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 11, year: 2026);

      expect(budgetService.getBudgetProgress(categoryId: 'C1', transactions: transactions, month: 11, year: 2026), 0.4);
    });

    test('checks if budget is exceeded', () {
      final budgetService = BudgetService();
      final transactions = [
        Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.expense, amount: 600, date: DateTime(2026, 11, 5)),
      ];

      budgetService.addBudget(id: 'B1', categoryId: 'C1', limit: 500, month: 11, year: 2026);

      expect(budgetService.isBudgetExceeded(categoryId: 'C1', transactions: transactions, month: 11, year: 2026), true);
    });
  });
}
