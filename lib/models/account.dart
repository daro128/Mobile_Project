enum AccountType { cash, savings, checking }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;

  Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
  });

  Account updateAccount({String? name, AccountType? type, double? balance}) =>
      Account(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        balance: balance ?? this.balance,
      );
}
