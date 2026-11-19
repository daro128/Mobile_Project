
import 'package:test/test.dart';

import '../models/account.dart';
import '../service/accountService.dart';

void main() {
  group('AccountService', () {
    // Add account
    test('adds a new account', () {
      final accountService = AccountService();

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      expect(accountService.accounts.length, 1);
      expect(accountService.getAccountById('A1')!.balance, 500);
    });

    test('cannot add account with duplicate ID', () {
      final accountService = AccountService();

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      expect(() => accountService.addAccount(Account(id: 'A1', name: 'Savings', type: AccountType.savings, balance: 100)), throwsException);
    });

    test('cannot add account with empty name', () {
      final accountService = AccountService();

      expect(() => accountService.addAccount(Account(id: 'A1', name: '  ', type: AccountType.cash, balance: 500)), throwsException);
    });

    test('cannot add account with negative balance', () {
      final accountService = AccountService();

      expect(() => accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: -100)), throwsException);
    });

    // Update account
    test('updates an existing account', () {
      final accountService = AccountService();

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      accountService.updateAccount(Account(id: 'A1', name: 'My Cash', type: AccountType.cash, balance: 700));

      expect(accountService.getAccountById('A1')!.name, 'My Cash');
      expect(accountService.getAccountById('A1')!.balance, 700);
    });

    test('cannot update account that does not exist', () {
      final accountService = AccountService();

      expect(() => accountService.updateAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500)), throwsException);
    });

    test('cannot update account with negative balance', () {
      final accountService = AccountService();

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      expect(() => accountService.updateAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: -100)), throwsException);
    });

    // Delete account
    test('deletes an existing account', () {
      final accountService = AccountService();

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      accountService.deleteAccount('A1');

      expect(accountService.accounts, isEmpty);
    });

    test('cannot delete account that does not exist', () {
      final accountService = AccountService();

      expect(() => accountService.deleteAccount('A1'), throwsException);
    });

    // Transfer money
    test('transfers money between two accounts', () {
      final accountService = AccountService();

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));
      accountService.addAccount(Account(id: 'A2', name: 'Savings', type: AccountType.savings, balance: 100));

      accountService.transferMoney(fromAccountId: 'A1', toAccountId: 'A2', amount: 200);

      expect(accountService.getAccountById('A1')!.balance, 300);
      expect(accountService.getAccountById('A2')!.balance, 300);
    });

    test('cannot transfer money with insufficient balance', () {
      final accountService = AccountService();

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 100));
      accountService.addAccount(Account(id: 'A2', name: 'Savings', type: AccountType.savings, balance: 100));

      expect(() => accountService.transferMoney(fromAccountId: 'A1', toAccountId: 'A2', amount: 200), throwsException);

      expect(accountService.getAccountById('A1')!.balance, 100);
      expect(accountService.getAccountById('A2')!.balance, 100);
    });

    test('cannot transfer money to the same account', () {
      final accountService = AccountService();

      accountService.addAccount(Account(id: 'A1', name: 'Cash', type: AccountType.cash, balance: 500));

      expect(() => accountService.transferMoney(fromAccountId: 'A1', toAccountId: 'A1', amount: 100), throwsException);
    });
  });
}
