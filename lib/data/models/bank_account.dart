class BankAccount {
  final int id;
  final String accountName;
  final String accountNumber;
  final String description;
  final String icon;

  BankAccount({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    this.description = '',
    this.icon = 'account_balance_wallet',
  });

  BankAccount copyWith({
    int? id,
    String? accountName,
    String? accountNumber,
    String? description,
    String? icon,
  }) {
    return BankAccount(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'description': description,
      'icon': icon,
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id'] as int,
      accountName: map['accountName'] as String,
      accountNumber: map['accountNumber'] as String,
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String? ?? 'account_balance_wallet',
    );
  }
}
