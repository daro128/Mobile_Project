import '../models/account.dart';

class AccountService {
  final List<Account> _accounts = [];

  List<Account> get accounts => List.unmodifiable(_accounts);

  Account? getAccountById(String id) {
    for (var account in _accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  void addAccount(Account account) {
    if (account.id.trim().isEmpty) {
      throw Exception('Account ID cannot be empty>:');
    }

    if (account.name.trim().isEmpty) {
      throw Exception('Account name cannot be empty>:');
    }

    if (account.balance < 0) {
      throw Exception('Initial balance cannot be negative>:');
    }

    if (_accounts.any((a) => a.id == account.id)) {
      throw Exception('Account already exist>:');
    }

    _accounts.add(account);
  }

  void updateAccount(Account updatedAccount) {
    final index = _accounts.indexWhere(
      (account) => account.id == updatedAccount.id,
    );

    if (index == -1) {
      throw Exception('Account not found>:');
    }

    if (updatedAccount.name.trim().isEmpty) {
      throw Exception('Account name cannot be empty>:');
    }

    if (updatedAccount.balance < 0) {
      throw Exception('Balance cannot be negative>:');
    }

    _accounts[index] = updatedAccount;
  }

  void deleteAccount(String id) {
    final index = _accounts.indexWhere((account) => account.id == id);

    if (index == -1) {
      throw Exception('Account not found>:');
    }

    _accounts.removeAt(index);
  }

  void transferMoney({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
  }) {
    if (fromAccountId == toAccountId) {
      throw Exception('Cannot transfer to the same account>:');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than zero>:');
    }

    final fromAccount = getAccountById(fromAccountId);
    final toAccount = getAccountById(toAccountId);

    if (fromAccount == null || toAccount == null) {
      throw Exception('Account not found>:');
    }

    if (fromAccount.balance < amount) {
      throw Exception('Insufficient balance>:');
    }

    final updatedFrom = fromAccount.updateAccount(
      balance: fromAccount.balance - amount,
    );

    final updatedTo = toAccount.updateAccount(
      balance: toAccount.balance + amount,
    );

    final fromIndex = _accounts.indexWhere(
      (account) => account.id == fromAccountId,
    );

    final toIndex = _accounts.indexWhere(
      (account) => account.id == toAccountId,
    );

    _accounts[fromIndex] = updatedFrom;
    _accounts[toIndex] = updatedTo;
  }
}
