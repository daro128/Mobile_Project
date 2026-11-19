import '../models/transaction.dart';
import 'accountService.dart';

class TransactionService {
  final List<Transaction> _transactions = [];
  final AccountService _accountService;

  TransactionService({required AccountService accountService})
      : _accountService = accountService;

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  Transaction _findTransaction(String id) {
    for (var transaction in _transactions) {
      if (transaction.id == id) {
        return transaction;
      }
    }

    throw Exception('Transaction not found>:');
  }

  void _validateAmount(double amount) {
    if (amount <= 0) {
      throw Exception('Transaction amount must be positive>:');
    }
  }

  void _updateAccountBalance(String accountId, double amount) {
    final account = _accountService.getAccountById(accountId);

    if (account == null) {
      throw Exception('Account not found>:');
    }

    final newBalance = account.balance + amount;

    if (newBalance < 0) {
      throw Exception('Insufficient balance>:');
    }

    _accountService.updateAccount(account.updateAccount(balance: newBalance));
  }

  void _applyTransaction(Transaction transaction, {bool reverse = false}) {
    double amount = reverse ? -transaction.amount : transaction.amount;

    if (transaction.type == TransactionType.income) {
      _updateAccountBalance(transaction.accountId, amount);
    } else if (transaction.type == TransactionType.expense) {
      _updateAccountBalance(transaction.accountId, -amount);
    } else if (transaction.type == TransactionType.transfer) {
      final fromAccountId =
          reverse ? transaction.targetAccountId! : transaction.accountId;

      final toAccountId =
          reverse ? transaction.accountId : transaction.targetAccountId!;

      _accountService.transferMoney(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: transaction.amount,
      );
    }
  }

  void addTransaction(Transaction transaction) {
    _validateAmount(transaction.amount);

    if (transaction.id.trim().isEmpty) {
      throw Exception('Transaction ID cannot be empty>:');
    }

    if (_transactions.any((item) => item.id == transaction.id)) {
      throw Exception('Transaction ID already exists>:');
    }

    if (transaction.accountId.trim().isEmpty) {
      throw Exception('Account ID cannot be empty>:');
    }

    if (transaction.type == TransactionType.transfer) {
      if (transaction.targetAccountId == null ||
          transaction.targetAccountId!.trim().isEmpty) {
        throw Exception('Target account is required for transfer>:');
      }

      if (transaction.accountId == transaction.targetAccountId) {
        throw Exception('Cannot transfer to the same account>:');
      }
    }

    if (transaction.type != TransactionType.transfer &&
        (transaction.categoryId == null ||
            transaction.categoryId!.trim().isEmpty)) {
      throw Exception('Category is required>:');
    }

    _applyTransaction(transaction);

    _transactions.add(transaction);
  }

  Transaction getTransactionById(String id) {
    return _findTransaction(id);
  }

  void updateTransaction({
    required String id,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
  }) {
    final index = _transactions.indexWhere(
      (transaction) => transaction.id == id,
    );

    if (index == -1) {
      throw Exception('Transaction not found>:');
    }

    if (amount != null) {
      _validateAmount(amount);
    }

    final transaction = _transactions[index];

    if (transaction.type != TransactionType.transfer &&
        categoryId != null &&
        categoryId.trim().isEmpty) {
      throw Exception('Category cannot be empty>:');
    }

    final updatedTransaction = Transaction(
      id: transaction.id,
      accountId: transaction.accountId,
      targetAccountId: transaction.targetAccountId,
      categoryId: categoryId ?? transaction.categoryId,
      type: transaction.type,
      amount: amount ?? transaction.amount,
      date: date ?? transaction.date,
      note: note ?? transaction.note,
    );

    _applyTransaction(transaction, reverse: true);

    try {
      _applyTransaction(updatedTransaction);
      _transactions[index] = updatedTransaction;
    } catch (e) {
      _applyTransaction(transaction);
      rethrow;
    }
  }

  void deleteTransaction(String id) {
    final index = _transactions.indexWhere(
      (transaction) => transaction.id == id,
    );

    if (index == -1) {
      throw Exception('Transaction not found>:');
    }

    _applyTransaction(_transactions[index], reverse: true);

    _transactions.removeAt(index);
  }

  List<Transaction> getTransactionsByAccount(String accountId) {
    return _transactions
        .where(
          (transaction) =>
              transaction.accountId == accountId ||
              transaction.targetAccountId == accountId,
        )
        .toList();
  }

  List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactions
        .where((transaction) => transaction.categoryId == categoryId)
        .toList();
  }

  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions
        .where((transaction) => transaction.type == type)
        .toList();
  }

  List<Transaction> getTransactionsByMonth({
    required int month,
    required int year,
  }) {
    return _transactions
        .where(
          (transaction) =>
              transaction.date.month == month && transaction.date.year == year,
        )
        .toList();
  }

  double getTotalIncome({required int month, required int year}) {
    double total = 0;

    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.income &&
          transaction.date.month == month &&
          transaction.date.year == year) {
        total += transaction.amount;
      }
    }

    return total;
  }

  double getTotalExpense({required int month, required int year}) {
    double total = 0;

    for (var transaction in _transactions) {
      if (transaction.type == TransactionType.expense &&
          transaction.date.month == month &&
          transaction.date.year == year) {
        total += transaction.amount;
      }
    }

    return total;
  }
}
