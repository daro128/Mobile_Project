import 'package:test/test.dart';

import '../models/account.dart';
import '../models/transaction.dart';
import '../service/accountService.dart';
import '../service/transactionService.dart';

void main() {
  group('TransactionService', () {
    // Add transaction
    test('adds an income transaction and increases account balance', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.income, amount: 200, date: DateTime(2026, 11, 18)));

      expect(accountService.getAccountById('A1')!.balance, 700);
      expect(transactionService.transactions.length, 1);
    });

    test('adds an expense transaction and decreases account balance', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.expense, amount: 100, date: DateTime(2026, 11, 18)));

      expect(accountService.getAccountById('A1')!.balance, 400);
    });

    test('cannot add expense with insufficient balance', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 100));

      expect(() => transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.expense, amount: 200, date: DateTime(2026, 11, 18))), throwsException);

      expect(accountService.getAccountById('A1')!.balance, 100);
      expect(transactionService.transactions, isEmpty);
    });

    test('cannot add transaction with duplicate ID', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      final transaction = Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.income, amount: 100, date: DateTime(2026, 11, 18));

      transactionService.addTransaction(transaction);

      expect(() => transactionService.addTransaction(transaction), throwsException);
    });

    // Transfer transaction
    test('transfers money between two accounts', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));
      accountService.addAccount(Account(id: 'A2', name: 'Savings', type: AccountType.savings, balance: 100));

      transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', targetAccountId: 'A2', type: TransactionType.transfer, amount: 200, date: DateTime(2026, 11, 18)));

      expect(accountService.getAccountById('A1')!.balance, 300);
      expect(accountService.getAccountById('A2')!.balance, 300);
    });

    test('cannot transfer money to the same account', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      expect(() => transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', targetAccountId: 'A1', type: TransactionType.transfer, amount: 100, date: DateTime(2026, 11, 18))), throwsException);
    });

    // Update transaction
    test('updates transaction amount and recalculates balance', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.expense, amount: 100, date: DateTime(2026, 11, 18)));

      transactionService.updateTransaction(id: 'T1', amount: 50);

      expect(accountService.getAccountById('A1')!.balance, 450);
      expect(transactionService.getTransactionById('T1').amount, 50);
    });

    test('cannot update transaction with invalid amount', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.expense, amount: 100, date: DateTime(2026, 11, 18)));

      expect(() => transactionService.updateTransaction(id: 'T1', amount: -50), throwsException);

      expect(accountService.getAccountById('A1')!.balance, 400);
    });

    // Delete transaction
    test('deletes transaction and restores account balance', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.expense, amount: 100, date: DateTime(2026, 11, 18)));

      transactionService.deleteTransaction('T1');

      expect(accountService.getAccountById('A1')!.balance, 500);
      expect(transactionService.transactions, isEmpty);
    });

    test('cannot delete transaction that does not exist', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      expect(() => transactionService.deleteTransaction('T1'), throwsException);
    });

    // Get transactions
    test('gets transactions by account', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.income, amount: 100, date: DateTime(2026, 11, 18)));

      expect(transactionService.getTransactionsByAccount('A1').length, 1);
    });

    test('calculates total income and expense by month', () {
      final accountService = AccountService();
      final transactionService = TransactionService(accountService: accountService);

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      transactionService.addTransaction(Transaction(id: 'T1', accountId: 'A1', categoryId: 'C1', type: TransactionType.income, amount: 200, date: DateTime(2026, 11, 5)));
      transactionService.addTransaction(Transaction(id: 'T2', accountId: 'A1', categoryId: 'C2', type: TransactionType.expense, amount: 50, date: DateTime(2026, 11, 10)));

      expect(transactionService.getTotalIncome(month: 11, year: 2026), 200);
      expect(transactionService.getTotalExpense(month: 11, year: 2026), 50);
    });
  });
}