enum TransactionType { income, expense, transfer }

class Transaction {
  final String id;
  final String accountId;
  final String? targetAccountId;
  final String? categoryId;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? note;

  Transaction({
    required this.id,
    required this.accountId,
    this.targetAccountId,
    this.categoryId,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
  });

  Transaction updateTransaction({
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
  }) => Transaction(
    id: id,
    accountId: accountId,
    targetAccountId: targetAccountId,
    categoryId: categoryId ?? this.categoryId,
    type: type,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note ?? this.note,
  );
}
