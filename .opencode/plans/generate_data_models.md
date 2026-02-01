# Data Models Generation Plan for lib/data/models/

## Purpose

Create pure Dart model files in `lib/data/models/` that represent the data structure. These are DTOs (Data Transfer Objects) that can be converted to/from Drift-generated models.

## Models to Generate (8 files)

### 1. transaction_type.dart
**Purpose:** Enum for transaction types (stored as String in DB)

```dart
enum TransactionType {
  debit,
  credit,
}

extension TransactionTypeExtension on TransactionType {
  String get value => name;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TransactionType.debit,
    );
  }
}
```

---

### 2. transaction.dart
**Purpose:** Transaction model matching Transactions table

```dart
import 'transaction_type.dart';

class Transaction {
  final int id;
  final int accountId;
  final int? categoryId;
  final int? smsId;
  final String? payee;
  final int amount;              // Stored as int in DB (paise/cents)
  final TransactionType type;     // Enum
  final String? reference;
  final String? description;
  final DateTime occurredAt;

  Transaction({
    this.id = 0,
    required this.accountId,
    this.categoryId,
    this.smsId,
    this.payee,
    required this.amount,
    required this.type,
    this.reference,
    this.description,
    required this.occurredAt,
  });

  Transaction copyWith({
    int? id,
    int? accountId,
    int? categoryId,
    int? smsId,
    String? payee,
    int? amount,
    TransactionType? type,
    String? reference,
    String? description,
    DateTime? occurredAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      smsId: smsId ?? this.smsId,
      payee: payee ?? this.payee,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }
}
```

---

### 3. category.dart
**Purpose:** Category model matching Categories table

```dart
class Category {
  final int id;
  final String name;
  final String icon;
  final int color;              // Color as int (0xFFRRGGBB)
  final String? description;

  Category({
    this.id = 0,
    required this.name,
    required this.icon,
    required this.color,
    this.description,
  });

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    int? color,
    String? description,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }
}
```

---

### 4. bank_account.dart
**Purpose:** Bank account model matching BankAccounts table

```dart
class BankAccount {
  final int id;
  final String name;
  final String? number;
  final String? description;
  final String icon;

  BankAccount({
    this.id = 0,
    required this.name,
    this.number,
    this.description,
    required this.icon,
  });

  BankAccount copyWith({
    int? id,
    String? name,
    String? number,
    String? description,
    String? icon,
  }) {
    return BankAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }
}
```

---

### 5. tag.dart
**Purpose:** Tag model matching Tags table

```dart
class Tag {
  final int id;
  final String name;
  final int color;              // Color as int

  Tag({
    this.id = 0,
    required this.name,
    required this.color,
  });

  Tag copyWith({
    int? id,
    String? name,
    int? color,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }
}
```

---

### 6. sms.dart
**Purpose:** SMS model matching SmsMessages table

```dart
class Sms {
  final int id;
  final String sender;
  final String body;
  final bool isDeleted;
  final DateTime receivedAt;
  final DateTime? deletedAt;
  final DateTime? processedAt;
  final bool isTransaction;
  final String status;          // 'pending', 'processed', 'ignored'

  Sms({
    this.id = 0,
    required this.sender,
    required this.body,
    this.isDeleted = false,
    required this.receivedAt,
    this.deletedAt,
    this.processedAt,
    this.isTransaction = false,
    this.status = 'pending',
  });

  Sms copyWith({
    int? id,
    String? sender,
    String? body,
    bool? isDeleted,
    DateTime? receivedAt,
    DateTime? deletedAt,
    DateTime? processedAt,
    bool? isTransaction,
    String? status,
  }) {
    return Sms(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      body: body ?? this.body,
      isDeleted: isDeleted ?? this.isDeleted,
      receivedAt: receivedAt ?? this.receivedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      processedAt: processedAt ?? this.processedAt,
      isTransaction: isTransaction ?? this.isTransaction,
      status: status ?? this.status,
    );
  }
}
```

---

### 7. sms_parsing_pattern.dart
**Purpose:** SMS parsing pattern model matching ParsingPatterns table

```dart
import 'transaction_type.dart';

class SMSParsingPattern {
  final int id;
  final String? name;
  final String senderPattern;
  final String bodyPattern;
  final TransactionType transactionType;
  final bool isActive;
  final int? defAccountId;      // Default account ID
  final int? defCategoryId;     // Default category ID

  SMSParsingPattern({
    this.id = 0,
    this.name,
    required this.senderPattern,
    required this.bodyPattern,
    required this.transactionType,
    this.isActive = true,
    this.defAccountId,
    this.defCategoryId,
  });

  SMSParsingPattern copyWith({
    int? id,
    String? name,
    String? senderPattern,
    String? bodyPattern,
    TransactionType? transactionType,
    bool? isActive,
    int? defAccountId,
    int? defCategoryId,
  }) {
    return SMSParsingPattern(
      id: id ?? this.id,
      name: name ?? this.name,
      senderPattern: senderPattern ?? this.senderPattern,
      bodyPattern: bodyPattern ?? this.bodyPattern,
      transactionType: transactionType ?? this.transactionType,
      isActive: isActive ?? this.isActive,
      defAccountId: defAccountId ?? this.defAccountId,
      defCategoryId: defCategoryId ?? this.defCategoryId,
    );
  }
}
```

---

### 8. sender_filter.dart
**Purpose:** Sender filter model matching SenderFilters table

```dart
class SenderFilter {
  final int id;
  final String? name;
  final String pattern;          // Regex pattern
  final String action;           // 'ignore', 'process', 'flag'
  final bool isActive;
  final String? description;

  SenderFilter({
    this.id = 0,
    this.name,
    required this.pattern,
    required this.action,
    this.isActive = true,
    this.description,
  });

  SenderFilter copyWith({
    int? id,
    String? name,
    String? pattern,
    String? action,
    bool? isActive,
    String? description,
  }) {
    return SenderFilter(
      id: id ?? this.id,
      name: name ?? this.name,
      pattern: pattern ?? this.pattern,
      action: action ?? this.action,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}
```

---

## File List to Generate

1. `lib/data/models/transaction_type.dart`
2. `lib/data/models/transaction.dart`
3. `lib/data/models/category.dart`
4. `lib/data/models/bank_account.dart`
5. `lib/data/models/tag.dart`
6. `lib/data/models/sms.dart`
7. `lib/data/models/sms_parsing_pattern.dart`
8. `lib/data/models/sender_filter.dart`

---

## Notes

- All models are plain Dart classes (no Drift imports)
- All fields are `final` for immutability
- All models have `copyWith()` method
- Transaction type is stored as String in DB but as Enum in model
- Amount is stored as int in DB (paise/cents) but exposed as int in model
- Color values are stored as int (0xFFRRGGBB)

---

## Estimated Time

**8 model files:** 20-30 minutes
