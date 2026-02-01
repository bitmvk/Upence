# Domain Entities Generation Plan

## Current State Analysis

**Database Tables Identified:**
1. `Transactions` - id, accountId, categoryId, smsId, payee, amount, type (String), reference, description, occurredAt
2. `Categories` - id, name, icon, color, description
3. `BankAccounts` - id, name, number, description, icon
4. `Tags` - id, name, color
5. `SmsMessages` - id, sender, body, isDeleted, receivedAt, deletedAt, processedAt, isTransaction, status
6. `ParsingPatterns` - id, name, senderPattern, bodyPattern, transactionType, isActive, defAccountId, defCategoryId
7. `SenderFilters` - id, name, pattern, action, isActive, description
8. `TransactionTags` - Join table for transactions ↔ tags

**Key Observations:**
- Transaction type is stored as `TextColumn get type` in database (String)
- Parsing patterns use `TextColumn get transactionType` as well
- All references use integer IDs (foreign keys)
- Some fields are nullable

---

## Domain Entities to Generate

### 1. TransactionType Enum
**File:** `lib/domain/entities/transaction_type.dart`

**Purpose:** Type-safe transaction types (currently stored as String in DB)

**Values:**
- `credit` - Money coming in
- `debit` - Money going out

**Methods:**
- `value` - returns String for DB storage
- `fromString(String)` - factory to convert DB string to enum

---

### 2. TransactionEntity
**File:** `lib/domain/entities/transaction_entity.dart`

**Properties:**
```dart
final int id;
final String accountId;           // Foreign key
final String? categoryId;        // Foreign key (nullable)
final int? smsId;               // Foreign key to SmsMessages (nullable)
final String? payee;
final double amount;             // Stored as int in DB (paise/cents)
final TransactionType type;       // Enum
final String? reference;
final String? description;
final DateTime occurredAt;
```

**Methods:**
- `copyWith()` - For immutable updates
- `isEmpty()` - Check if it's a placeholder

**Notes:**
- Amount is stored as int in DB but exposed as double in entity
- `payee` is the same as `counterParty` in earlier designs
- `occurredAt` maps to `timestamp` conceptually

---

### 3. CategoryEntity
**File:** `lib/domain/entities/category_entity.dart`

**Properties:**
```dart
final int id;
final String name;
final String icon;
final int color;                 // Color value as integer (0xFFRRGGBB)
final String? description;
```

**Methods:**
- `copyWith()` - For immutable updates
- `toColor()` - Convert int to Flutter Color

**Notes:**
- Icon is a String (name of Material Design icon)

---

### 4. BankAccountEntity
**File:** `lib/domain/entities/bank_account_entity.dart`

**Properties:**
```dart
final int id;
final String name;
final String? number;
final String? description;
final String icon;
```

**Methods:**
- `copyWith()` - For immutable updates
- `toDisplayString()` - Format for display (e.g., "HDFC Bank ****1234")

---

### 5. TagEntity
**File:** `lib/domain/entities/tag_entity.dart`

**Properties:**
```dart
final int id;
final String name;
final int color;                 // Color value as integer
```

**Methods:**
- `copyWith()` - For immutable updates

---

### 6. SMSEntity
**File:** `lib/domain/entities/sms_entity.dart`

**Properties:**
```dart
final int id;
final String sender;
final String body;
final bool isDeleted;
final DateTime receivedAt;
final DateTime? deletedAt;
final DateTime? processedAt;
final bool isTransaction;
final String status;              // 'pending', 'processed', 'ignored'
```

**Methods:**
- `copyWith()` - For immutable updates
- `isUnprocessed()` - Check if ready for processing (status == 'pending' && !isDeleted)

---

### 7. SMSParsingPatternEntity
**File:** `lib/domain/entities/sms_parsing_pattern_entity.dart`

**Properties:**
```dart
final int id;
final String? name;
final String senderPattern;        // Regex pattern for sender matching
final String bodyPattern;          // Regex pattern for body matching
final TransactionType transactionType;
final bool isActive;
final String? defAccountId;       // Default account ID (nullable)
final String? defCategoryId;      // Default category ID (nullable)
```

**Methods:**
- `copyWith()` - For immutable updates
- `matches(String sender, String body)` - Test if pattern matches SMS

**Note:** Fields use `defAccountId`/`defCategoryId` names to match database, but could also be `accountId`/`categoryId` for cleaner entity.

---

### 8. SenderFilterEntity
**File:** `lib/domain/entities/sender_filter_entity.dart`

**Properties:**
```dart
final int id;
final String? name;
final String pattern;             // Regex pattern
final String action;              // 'ignore', 'process', 'flag'
final bool isActive;
final String? description;
```

**Methods:**
- `copyWith()` - For immutable updates
- `matches(String sender)` - Test if pattern matches sender

---

### 9. FinancialOverviewEntity
**File:** `lib/domain/entities/financial_overview_entity.dart`

**Purpose:** Aggregated financial data for home screen

**Properties:**
```dart
final double balance;              // Total balance
final double income;              // Total income
final double expense;             // Total expense
```

**Methods:**
- `copyWith()` - For immutable updates
- `empty()` - Static factory for placeholder state

---

## File Creation List

### Files to Generate (9 entities):

1. `lib/domain/entities/transaction_type.dart`
2. `lib/domain/entities/transaction_entity.dart`
3. `lib/domain/entities/category_entity.dart`
4. `lib/domain/entities/bank_account_entity.dart`
5. `lib/domain/entities/tag_entity.dart`
6. `lib/domain/entities/sms_entity.dart`
7. `lib/domain/entities/sms_parsing_pattern_entity.dart`
8. `lib/domain/entities/sender_filter_entity.dart`
9. `lib/domain/entities/financial_overview_entity.dart`

---

## Implementation Notes

### 1. Import Structure
All entities should have minimal imports:
- `package:flutter/material.dart` - Only for Color type in CategoryEntity/TagEntity
- No Drift imports (entities are framework-independent)
- No JSON imports

### 2. Immutability
- All fields should be `final`
- Provide `copyWith()` method for updates
- Use `const` constructors where possible

### 3. Type Conversions
Entities may need conversion methods for later use:
- `TransactionEntity`: amount int ↔ double
- `CategoryEntity`/`TagEntity`: color int ↔ Color
- `SMSEntity`: status string ↔ enum (optional)

### 4. Validation
Keep entities simple. Validation should be:
- In viewmodels for user input
- In repositories before database insert
- Not in entities (entities should accept any valid state)

### 5. Naming Consistency
- Use camelCase for properties
- Use `Entity` suffix for class names
- Keep names close to database fields but more readable:
  - `payee` (DB) → `payee` (Entity) ✓
  - `occurredAt` (DB) → `occurredAt` (Entity) ✓
  - `defAccountId` (DB) → `defAccountId` (Entity) ✓

---

## Next Steps After Entity Generation

Once entities are generated, the following will be needed:

### Repository Interfaces
- Create 9 interface files in `lib/domain/repositories/`
- Define method signatures using entities
- Example: `Future<List<TransactionEntity>> getAllTransactions();`

### Repository Implementations
- Update 9 implementation files in `lib/data/repositories/`
- Implement interfaces
- Add entity ↔ DTO conversion methods
- Example: `TransactionEntity _toEntity(Transaction dto)`

### Use Cases
- Create 3 use cases in `lib/domain/usecases/`:
  - `process_sms_usecase.dart`
  - `find_matching_patterns_usecase.dart`
  - `get_financial_overview_usecase.dart`

---

## Verification Checklist

After generation, verify:

- [ ] All 9 entity files created
- [ ] All entities have `final` fields
- [ ] All entities have `copyWith()` method
- [ ] TransactionType enum has `value` and `fromString()` methods
- [ ] No Drift imports in entity files
- [ ] Type conversions documented (amount int ↔ double, color int ↔ Color)
- [ ] `flutter analyze` shows no errors
- [ ] All entities can be instantiated with sample data

---

## Estimated Time

**Entity Generation Only:** 30-45 minutes

Breakdown:
- TransactionType enum: 5 minutes
- TransactionEntity: 10 minutes
- CategoryEntity: 5 minutes
- BankAccountEntity: 5 minutes
- TagEntity: 3 minutes
- SMSEntity: 5 minutes
- SMSParsingPatternEntity: 5 minutes
- SenderFilterEntity: 5 minutes
- FinancialOverviewEntity: 2 minutes
