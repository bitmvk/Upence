// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _counterPartyMeta = const VerificationMeta(
    'counterParty',
  );
  @override
  late final GeneratedColumn<String> counterParty = GeneratedColumn<String>(
    'counter_party',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _referenceNumberMeta = const VerificationMeta(
    'referenceNumber',
  );
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
    'reference_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    counterParty,
    amount,
    timestamp,
    categoryId,
    description,
    accountId,
    transactionType,
    referenceNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('counter_party')) {
      context.handle(
        _counterPartyMeta,
        counterParty.isAcceptableOrUnknown(
          data['counter_party']!,
          _counterPartyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_counterPartyMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('reference_number')) {
      context.handle(
        _referenceNumberMeta,
        referenceNumber.isAcceptableOrUnknown(
          data['reference_number']!,
          _referenceNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      counterParty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counter_party'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      referenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_number'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final int id;
  final String counterParty;
  final double amount;
  final DateTime timestamp;
  final String categoryId;
  final String description;
  final String accountId;
  final String transactionType;
  final String referenceNumber;
  const Transaction({
    required this.id,
    required this.counterParty,
    required this.amount,
    required this.timestamp,
    required this.categoryId,
    required this.description,
    required this.accountId,
    required this.transactionType,
    required this.referenceNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['counter_party'] = Variable<String>(counterParty);
    map['amount'] = Variable<double>(amount);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['category_id'] = Variable<String>(categoryId);
    map['description'] = Variable<String>(description);
    map['account_id'] = Variable<String>(accountId);
    map['transaction_type'] = Variable<String>(transactionType);
    map['reference_number'] = Variable<String>(referenceNumber);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      counterParty: Value(counterParty),
      amount: Value(amount),
      timestamp: Value(timestamp),
      categoryId: Value(categoryId),
      description: Value(description),
      accountId: Value(accountId),
      transactionType: Value(transactionType),
      referenceNumber: Value(referenceNumber),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<int>(json['id']),
      counterParty: serializer.fromJson<String>(json['counterParty']),
      amount: serializer.fromJson<double>(json['amount']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      description: serializer.fromJson<String>(json['description']),
      accountId: serializer.fromJson<String>(json['accountId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      referenceNumber: serializer.fromJson<String>(json['referenceNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'counterParty': serializer.toJson<String>(counterParty),
      'amount': serializer.toJson<double>(amount),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'categoryId': serializer.toJson<String>(categoryId),
      'description': serializer.toJson<String>(description),
      'accountId': serializer.toJson<String>(accountId),
      'transactionType': serializer.toJson<String>(transactionType),
      'referenceNumber': serializer.toJson<String>(referenceNumber),
    };
  }

  Transaction copyWith({
    int? id,
    String? counterParty,
    double? amount,
    DateTime? timestamp,
    String? categoryId,
    String? description,
    String? accountId,
    String? transactionType,
    String? referenceNumber,
  }) => Transaction(
    id: id ?? this.id,
    counterParty: counterParty ?? this.counterParty,
    amount: amount ?? this.amount,
    timestamp: timestamp ?? this.timestamp,
    categoryId: categoryId ?? this.categoryId,
    description: description ?? this.description,
    accountId: accountId ?? this.accountId,
    transactionType: transactionType ?? this.transactionType,
    referenceNumber: referenceNumber ?? this.referenceNumber,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      counterParty: data.counterParty.present
          ? data.counterParty.value
          : this.counterParty,
      amount: data.amount.present ? data.amount.value : this.amount,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      description: data.description.present
          ? data.description.value
          : this.description,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('counterParty: $counterParty, ')
          ..write('amount: $amount, ')
          ..write('timestamp: $timestamp, ')
          ..write('categoryId: $categoryId, ')
          ..write('description: $description, ')
          ..write('accountId: $accountId, ')
          ..write('transactionType: $transactionType, ')
          ..write('referenceNumber: $referenceNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    counterParty,
    amount,
    timestamp,
    categoryId,
    description,
    accountId,
    transactionType,
    referenceNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.counterParty == this.counterParty &&
          other.amount == this.amount &&
          other.timestamp == this.timestamp &&
          other.categoryId == this.categoryId &&
          other.description == this.description &&
          other.accountId == this.accountId &&
          other.transactionType == this.transactionType &&
          other.referenceNumber == this.referenceNumber);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<int> id;
  final Value<String> counterParty;
  final Value<double> amount;
  final Value<DateTime> timestamp;
  final Value<String> categoryId;
  final Value<String> description;
  final Value<String> accountId;
  final Value<String> transactionType;
  final Value<String> referenceNumber;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.counterParty = const Value.absent(),
    this.amount = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.description = const Value.absent(),
    this.accountId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.referenceNumber = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required String counterParty,
    required double amount,
    required DateTime timestamp,
    required String categoryId,
    this.description = const Value.absent(),
    required String accountId,
    required String transactionType,
    this.referenceNumber = const Value.absent(),
  }) : counterParty = Value(counterParty),
       amount = Value(amount),
       timestamp = Value(timestamp),
       categoryId = Value(categoryId),
       accountId = Value(accountId),
       transactionType = Value(transactionType);
  static Insertable<Transaction> custom({
    Expression<int>? id,
    Expression<String>? counterParty,
    Expression<double>? amount,
    Expression<DateTime>? timestamp,
    Expression<String>? categoryId,
    Expression<String>? description,
    Expression<String>? accountId,
    Expression<String>? transactionType,
    Expression<String>? referenceNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (counterParty != null) 'counter_party': counterParty,
      if (amount != null) 'amount': amount,
      if (timestamp != null) 'timestamp': timestamp,
      if (categoryId != null) 'category_id': categoryId,
      if (description != null) 'description': description,
      if (accountId != null) 'account_id': accountId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (referenceNumber != null) 'reference_number': referenceNumber,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<String>? counterParty,
    Value<double>? amount,
    Value<DateTime>? timestamp,
    Value<String>? categoryId,
    Value<String>? description,
    Value<String>? accountId,
    Value<String>? transactionType,
    Value<String>? referenceNumber,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      counterParty: counterParty ?? this.counterParty,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      accountId: accountId ?? this.accountId,
      transactionType: transactionType ?? this.transactionType,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (counterParty.present) {
      map['counter_party'] = Variable<String>(counterParty.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('counterParty: $counterParty, ')
          ..write('amount: $amount, ')
          ..write('timestamp: $timestamp, ')
          ..write('categoryId: $categoryId, ')
          ..write('description: $description, ')
          ..write('accountId: $accountId, ')
          ..write('transactionType: $transactionType, ')
          ..write('referenceNumber: $referenceNumber')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, icon, name, color, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String icon;
  final String name;
  final int color;
  final String description;
  const Category({
    required this.id,
    required this.icon,
    required this.name,
    required this.color,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['icon'] = Variable<String>(icon);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['description'] = Variable<String>(description);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      icon: Value(icon),
      name: Value(name),
      color: Value(color),
      description: Value(description),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      icon: serializer.fromJson<String>(json['icon']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'icon': serializer.toJson<String>(icon),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'description': serializer.toJson<String>(description),
    };
  }

  Category copyWith({
    int? id,
    String? icon,
    String? name,
    int? color,
    String? description,
  }) => Category(
    id: id ?? this.id,
    icon: icon ?? this.icon,
    name: name ?? this.name,
    color: color ?? this.color,
    description: description ?? this.description,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      icon: data.icon.present ? data.icon.value : this.icon,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('icon: $icon, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, icon, name, color, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.icon == this.icon &&
          other.name == this.name &&
          other.color == this.color &&
          other.description == this.description);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> icon;
  final Value<String> name;
  final Value<int> color;
  final Value<String> description;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.icon = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.description = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String icon,
    required String name,
    required int color,
    this.description = const Value.absent(),
  }) : icon = Value(icon),
       name = Value(name),
       color = Value(color);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? icon,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (icon != null) 'icon': icon,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (description != null) 'description': description,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? icon,
    Value<String>? name,
    Value<int>? color,
    Value<String>? description,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('icon: $icon, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  final String color;
  const Tag({required this.id, required this.name, required this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<String>(color);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name), color: Value(color));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String>(color),
    };
  }

  Tag copyWith({int? id, String? name, String? color}) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> color;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String color,
  }) : name = Value(name),
       color = Value(color);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? color,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
    });
  }

  TagsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? color,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }
}

class $TransactionTagsTable extends TransactionTags
    with TableInfo<$TransactionTagsTable, TransactionTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES transactions (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, tagId, transactionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
    );
  }

  @override
  $TransactionTagsTable createAlias(String alias) {
    return $TransactionTagsTable(attachedDatabase, alias);
  }
}

class TransactionTag extends DataClass implements Insertable<TransactionTag> {
  final int id;
  final String tagId;
  final String transactionId;
  const TransactionTag({
    required this.id,
    required this.tagId,
    required this.transactionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tag_id'] = Variable<String>(tagId);
    map['transaction_id'] = Variable<String>(transactionId);
    return map;
  }

  TransactionTagsCompanion toCompanion(bool nullToAbsent) {
    return TransactionTagsCompanion(
      id: Value(id),
      tagId: Value(tagId),
      transactionId: Value(transactionId),
    );
  }

  factory TransactionTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTag(
      id: serializer.fromJson<int>(json['id']),
      tagId: serializer.fromJson<String>(json['tagId']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tagId': serializer.toJson<String>(tagId),
      'transactionId': serializer.toJson<String>(transactionId),
    };
  }

  TransactionTag copyWith({int? id, String? tagId, String? transactionId}) =>
      TransactionTag(
        id: id ?? this.id,
        tagId: tagId ?? this.tagId,
        transactionId: transactionId ?? this.transactionId,
      );
  TransactionTag copyWithCompanion(TransactionTagsCompanion data) {
    return TransactionTag(
      id: data.id.present ? data.id.value : this.id,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTag(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, tagId, transactionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTag &&
          other.id == this.id &&
          other.tagId == this.tagId &&
          other.transactionId == this.transactionId);
}

class TransactionTagsCompanion extends UpdateCompanion<TransactionTag> {
  final Value<int> id;
  final Value<String> tagId;
  final Value<String> transactionId;
  const TransactionTagsCompanion({
    this.id = const Value.absent(),
    this.tagId = const Value.absent(),
    this.transactionId = const Value.absent(),
  });
  TransactionTagsCompanion.insert({
    this.id = const Value.absent(),
    required String tagId,
    required String transactionId,
  }) : tagId = Value(tagId),
       transactionId = Value(transactionId);
  static Insertable<TransactionTag> custom({
    Expression<int>? id,
    Expression<String>? tagId,
    Expression<String>? transactionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tagId != null) 'tag_id': tagId,
      if (transactionId != null) 'transaction_id': transactionId,
    });
  }

  TransactionTagsCompanion copyWith({
    Value<int>? id,
    Value<String>? tagId,
    Value<String>? transactionId,
  }) {
    return TransactionTagsCompanion(
      id: id ?? this.id,
      tagId: tagId ?? this.tagId,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTagsCompanion(')
          ..write('id: $id, ')
          ..write('tagId: $tagId, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }
}

class $BankAccountsTable extends BankAccounts
    with TableInfo<$BankAccountsTable, BankAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _accountNameMeta = const VerificationMeta(
    'accountName',
  );
  @override
  late final GeneratedColumn<String> accountName = GeneratedColumn<String>(
    'account_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountNumberMeta = const VerificationMeta(
    'accountNumber',
  );
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
    'account_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accountName,
    accountNumber,
    description,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('account_name')) {
      context.handle(
        _accountNameMeta,
        accountName.isAcceptableOrUnknown(
          data['account_name']!,
          _accountNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountNameMeta);
    }
    if (data.containsKey('account_number')) {
      context.handle(
        _accountNumberMeta,
        accountNumber.isAcceptableOrUnknown(
          data['account_number']!,
          _accountNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountNumberMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      accountName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_name'],
      )!,
      accountNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_number'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
    );
  }

  @override
  $BankAccountsTable createAlias(String alias) {
    return $BankAccountsTable(attachedDatabase, alias);
  }
}

class BankAccount extends DataClass implements Insertable<BankAccount> {
  final int id;
  final String accountName;
  final String accountNumber;
  final String description;
  const BankAccount({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['account_name'] = Variable<String>(accountName);
    map['account_number'] = Variable<String>(accountNumber);
    map['description'] = Variable<String>(description);
    return map;
  }

  BankAccountsCompanion toCompanion(bool nullToAbsent) {
    return BankAccountsCompanion(
      id: Value(id),
      accountName: Value(accountName),
      accountNumber: Value(accountNumber),
      description: Value(description),
    );
  }

  factory BankAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankAccount(
      id: serializer.fromJson<int>(json['id']),
      accountName: serializer.fromJson<String>(json['accountName']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'accountName': serializer.toJson<String>(accountName),
      'accountNumber': serializer.toJson<String>(accountNumber),
      'description': serializer.toJson<String>(description),
    };
  }

  BankAccount copyWith({
    int? id,
    String? accountName,
    String? accountNumber,
    String? description,
  }) => BankAccount(
    id: id ?? this.id,
    accountName: accountName ?? this.accountName,
    accountNumber: accountNumber ?? this.accountNumber,
    description: description ?? this.description,
  );
  BankAccount copyWithCompanion(BankAccountsCompanion data) {
    return BankAccount(
      id: data.id.present ? data.id.value : this.id,
      accountName: data.accountName.present
          ? data.accountName.value
          : this.accountName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankAccount(')
          ..write('id: $id, ')
          ..write('accountName: $accountName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, accountName, accountNumber, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankAccount &&
          other.id == this.id &&
          other.accountName == this.accountName &&
          other.accountNumber == this.accountNumber &&
          other.description == this.description);
}

class BankAccountsCompanion extends UpdateCompanion<BankAccount> {
  final Value<int> id;
  final Value<String> accountName;
  final Value<String> accountNumber;
  final Value<String> description;
  const BankAccountsCompanion({
    this.id = const Value.absent(),
    this.accountName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.description = const Value.absent(),
  });
  BankAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String accountName,
    required String accountNumber,
    this.description = const Value.absent(),
  }) : accountName = Value(accountName),
       accountNumber = Value(accountNumber);
  static Insertable<BankAccount> custom({
    Expression<int>? id,
    Expression<String>? accountName,
    Expression<String>? accountNumber,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountName != null) 'account_name': accountName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (description != null) 'description': description,
    });
  }

  BankAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? accountName,
    Value<String>? accountNumber,
    Value<String>? description,
  }) {
    return BankAccountsCompanion(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      accountNumber: accountNumber ?? this.accountNumber,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (accountName.present) {
      map['account_name'] = Variable<String>(accountName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankAccountsCompanion(')
          ..write('id: $id, ')
          ..write('accountName: $accountName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $SmsTableTable extends SmsTable with TableInfo<$SmsTableTable, Sms> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _senderMeta = const VerificationMeta('sender');
  @override
  late final GeneratedColumn<String> sender = GeneratedColumn<String>(
    'sender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _processedMeta = const VerificationMeta(
    'processed',
  );
  @override
  late final GeneratedColumn<int> processed = GeneratedColumn<int>(
    'processed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sender,
    message,
    timestamp,
    processed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sms_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sms> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sender')) {
      context.handle(
        _senderMeta,
        sender.isAcceptableOrUnknown(data['sender']!, _senderMeta),
      );
    } else if (isInserting) {
      context.missing(_senderMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('processed')) {
      context.handle(
        _processedMeta,
        processed.isAcceptableOrUnknown(data['processed']!, _processedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sms map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sms(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      processed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}processed'],
      )!,
    );
  }

  @override
  $SmsTableTable createAlias(String alias) {
    return $SmsTableTable(attachedDatabase, alias);
  }
}

class Sms extends DataClass implements Insertable<Sms> {
  final int id;
  final String sender;
  final String message;
  final int timestamp;
  final int processed;
  const Sms({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.processed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sender'] = Variable<String>(sender);
    map['message'] = Variable<String>(message);
    map['timestamp'] = Variable<int>(timestamp);
    map['processed'] = Variable<int>(processed);
    return map;
  }

  SmsTableCompanion toCompanion(bool nullToAbsent) {
    return SmsTableCompanion(
      id: Value(id),
      sender: Value(sender),
      message: Value(message),
      timestamp: Value(timestamp),
      processed: Value(processed),
    );
  }

  factory Sms.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sms(
      id: serializer.fromJson<int>(json['id']),
      sender: serializer.fromJson<String>(json['sender']),
      message: serializer.fromJson<String>(json['message']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      processed: serializer.fromJson<int>(json['processed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sender': serializer.toJson<String>(sender),
      'message': serializer.toJson<String>(message),
      'timestamp': serializer.toJson<int>(timestamp),
      'processed': serializer.toJson<int>(processed),
    };
  }

  Sms copyWith({
    int? id,
    String? sender,
    String? message,
    int? timestamp,
    int? processed,
  }) => Sms(
    id: id ?? this.id,
    sender: sender ?? this.sender,
    message: message ?? this.message,
    timestamp: timestamp ?? this.timestamp,
    processed: processed ?? this.processed,
  );
  Sms copyWithCompanion(SmsTableCompanion data) {
    return Sms(
      id: data.id.present ? data.id.value : this.id,
      sender: data.sender.present ? data.sender.value : this.sender,
      message: data.message.present ? data.message.value : this.message,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      processed: data.processed.present ? data.processed.value : this.processed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sms(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('message: $message, ')
          ..write('timestamp: $timestamp, ')
          ..write('processed: $processed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sender, message, timestamp, processed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sms &&
          other.id == this.id &&
          other.sender == this.sender &&
          other.message == this.message &&
          other.timestamp == this.timestamp &&
          other.processed == this.processed);
}

class SmsTableCompanion extends UpdateCompanion<Sms> {
  final Value<int> id;
  final Value<String> sender;
  final Value<String> message;
  final Value<int> timestamp;
  final Value<int> processed;
  const SmsTableCompanion({
    this.id = const Value.absent(),
    this.sender = const Value.absent(),
    this.message = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.processed = const Value.absent(),
  });
  SmsTableCompanion.insert({
    this.id = const Value.absent(),
    required String sender,
    required String message,
    required int timestamp,
    this.processed = const Value.absent(),
  }) : sender = Value(sender),
       message = Value(message),
       timestamp = Value(timestamp);
  static Insertable<Sms> custom({
    Expression<int>? id,
    Expression<String>? sender,
    Expression<String>? message,
    Expression<int>? timestamp,
    Expression<int>? processed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sender != null) 'sender': sender,
      if (message != null) 'message': message,
      if (timestamp != null) 'timestamp': timestamp,
      if (processed != null) 'processed': processed,
    });
  }

  SmsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? sender,
    Value<String>? message,
    Value<int>? timestamp,
    Value<int>? processed,
  }) {
    return SmsTableCompanion(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      processed: processed ?? this.processed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sender.present) {
      map['sender'] = Variable<String>(sender.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (processed.present) {
      map['processed'] = Variable<int>(processed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmsTableCompanion(')
          ..write('id: $id, ')
          ..write('sender: $sender, ')
          ..write('message: $message, ')
          ..write('timestamp: $timestamp, ')
          ..write('processed: $processed')
          ..write(')'))
        .toString();
  }
}

class $SMSParsingPatternsTable extends SMSParsingPatterns
    with TableInfo<$SMSParsingPatternsTable, SMSParsingPattern> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SMSParsingPatternsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _senderIdentifierMeta = const VerificationMeta(
    'senderIdentifier',
  );
  @override
  late final GeneratedColumn<String> senderIdentifier = GeneratedColumn<String>(
    'sender_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternNameMeta = const VerificationMeta(
    'patternName',
  );
  @override
  late final GeneratedColumn<String> patternName = GeneratedColumn<String>(
    'pattern_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageStructureMeta = const VerificationMeta(
    'messageStructure',
  );
  @override
  late final GeneratedColumn<String> messageStructure = GeneratedColumn<String>(
    'message_structure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPatternMeta = const VerificationMeta(
    'amountPattern',
  );
  @override
  late final GeneratedColumn<String> amountPattern = GeneratedColumn<String>(
    'amount_pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _counterpartyPatternMeta =
      const VerificationMeta('counterpartyPattern');
  @override
  late final GeneratedColumn<String> counterpartyPattern =
      GeneratedColumn<String>(
        'counterparty_pattern',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _datePatternMeta = const VerificationMeta(
    'datePattern',
  );
  @override
  late final GeneratedColumn<String> datePattern = GeneratedColumn<String>(
    'date_pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referencePatternMeta = const VerificationMeta(
    'referencePattern',
  );
  @override
  late final GeneratedColumn<String> referencePattern = GeneratedColumn<String>(
    'reference_pattern',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _defaultCategoryIdMeta = const VerificationMeta(
    'defaultCategoryId',
  );
  @override
  late final GeneratedColumn<String> defaultCategoryId =
      GeneratedColumn<String>(
        'default_category_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _defaultAccountIdMeta = const VerificationMeta(
    'defaultAccountId',
  );
  @override
  late final GeneratedColumn<String> defaultAccountId = GeneratedColumn<String>(
    'default_account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _autoSelectAccountMeta = const VerificationMeta(
    'autoSelectAccount',
  );
  @override
  late final GeneratedColumn<int> autoSelectAccount = GeneratedColumn<int>(
    'auto_select_account',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _sampleSmsMeta = const VerificationMeta(
    'sampleSms',
  );
  @override
  late final GeneratedColumn<String> sampleSms = GeneratedColumn<String>(
    'sample_sms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _createdTimestampMeta = const VerificationMeta(
    'createdTimestamp',
  );
  @override
  late final GeneratedColumn<int> createdTimestamp = GeneratedColumn<int>(
    'created_timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedTimestampMeta = const VerificationMeta(
    'lastUsedTimestamp',
  );
  @override
  late final GeneratedColumn<int> lastUsedTimestamp = GeneratedColumn<int>(
    'last_used_timestamp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    senderIdentifier,
    patternName,
    messageStructure,
    amountPattern,
    counterpartyPattern,
    datePattern,
    referencePattern,
    transactionType,
    isActive,
    defaultCategoryId,
    defaultAccountId,
    autoSelectAccount,
    senderName,
    sampleSms,
    createdTimestamp,
    lastUsedTimestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 's_m_s_parsing_patterns';
  @override
  VerificationContext validateIntegrity(
    Insertable<SMSParsingPattern> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sender_identifier')) {
      context.handle(
        _senderIdentifierMeta,
        senderIdentifier.isAcceptableOrUnknown(
          data['sender_identifier']!,
          _senderIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_senderIdentifierMeta);
    }
    if (data.containsKey('pattern_name')) {
      context.handle(
        _patternNameMeta,
        patternName.isAcceptableOrUnknown(
          data['pattern_name']!,
          _patternNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_patternNameMeta);
    }
    if (data.containsKey('message_structure')) {
      context.handle(
        _messageStructureMeta,
        messageStructure.isAcceptableOrUnknown(
          data['message_structure']!,
          _messageStructureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageStructureMeta);
    }
    if (data.containsKey('amount_pattern')) {
      context.handle(
        _amountPatternMeta,
        amountPattern.isAcceptableOrUnknown(
          data['amount_pattern']!,
          _amountPatternMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPatternMeta);
    }
    if (data.containsKey('counterparty_pattern')) {
      context.handle(
        _counterpartyPatternMeta,
        counterpartyPattern.isAcceptableOrUnknown(
          data['counterparty_pattern']!,
          _counterpartyPatternMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_counterpartyPatternMeta);
    }
    if (data.containsKey('date_pattern')) {
      context.handle(
        _datePatternMeta,
        datePattern.isAcceptableOrUnknown(
          data['date_pattern']!,
          _datePatternMeta,
        ),
      );
    }
    if (data.containsKey('reference_pattern')) {
      context.handle(
        _referencePatternMeta,
        referencePattern.isAcceptableOrUnknown(
          data['reference_pattern']!,
          _referencePatternMeta,
        ),
      );
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('default_category_id')) {
      context.handle(
        _defaultCategoryIdMeta,
        defaultCategoryId.isAcceptableOrUnknown(
          data['default_category_id']!,
          _defaultCategoryIdMeta,
        ),
      );
    }
    if (data.containsKey('default_account_id')) {
      context.handle(
        _defaultAccountIdMeta,
        defaultAccountId.isAcceptableOrUnknown(
          data['default_account_id']!,
          _defaultAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('auto_select_account')) {
      context.handle(
        _autoSelectAccountMeta,
        autoSelectAccount.isAcceptableOrUnknown(
          data['auto_select_account']!,
          _autoSelectAccountMeta,
        ),
      );
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    }
    if (data.containsKey('sample_sms')) {
      context.handle(
        _sampleSmsMeta,
        sampleSms.isAcceptableOrUnknown(data['sample_sms']!, _sampleSmsMeta),
      );
    }
    if (data.containsKey('created_timestamp')) {
      context.handle(
        _createdTimestampMeta,
        createdTimestamp.isAcceptableOrUnknown(
          data['created_timestamp']!,
          _createdTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdTimestampMeta);
    }
    if (data.containsKey('last_used_timestamp')) {
      context.handle(
        _lastUsedTimestampMeta,
        lastUsedTimestamp.isAcceptableOrUnknown(
          data['last_used_timestamp']!,
          _lastUsedTimestampMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SMSParsingPattern map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SMSParsingPattern(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      senderIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_identifier'],
      )!,
      patternName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern_name'],
      )!,
      messageStructure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_structure'],
      )!,
      amountPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_pattern'],
      )!,
      counterpartyPattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counterparty_pattern'],
      )!,
      datePattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_pattern'],
      ),
      referencePattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference_pattern'],
      ),
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      defaultCategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_category_id'],
      )!,
      defaultAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_account_id'],
      )!,
      autoSelectAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auto_select_account'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      sampleSms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sample_sms'],
      )!,
      createdTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_timestamp'],
      )!,
      lastUsedTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_used_timestamp'],
      ),
    );
  }

  @override
  $SMSParsingPatternsTable createAlias(String alias) {
    return $SMSParsingPatternsTable(attachedDatabase, alias);
  }
}

class SMSParsingPattern extends DataClass
    implements Insertable<SMSParsingPattern> {
  final int id;
  final String senderIdentifier;
  final String patternName;
  final String messageStructure;
  final String amountPattern;
  final String counterpartyPattern;
  final String? datePattern;
  final String? referencePattern;
  final String transactionType;
  final int isActive;
  final String defaultCategoryId;
  final String defaultAccountId;
  final int autoSelectAccount;
  final String senderName;
  final String sampleSms;
  final int createdTimestamp;
  final int? lastUsedTimestamp;
  const SMSParsingPattern({
    required this.id,
    required this.senderIdentifier,
    required this.patternName,
    required this.messageStructure,
    required this.amountPattern,
    required this.counterpartyPattern,
    this.datePattern,
    this.referencePattern,
    required this.transactionType,
    required this.isActive,
    required this.defaultCategoryId,
    required this.defaultAccountId,
    required this.autoSelectAccount,
    required this.senderName,
    required this.sampleSms,
    required this.createdTimestamp,
    this.lastUsedTimestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sender_identifier'] = Variable<String>(senderIdentifier);
    map['pattern_name'] = Variable<String>(patternName);
    map['message_structure'] = Variable<String>(messageStructure);
    map['amount_pattern'] = Variable<String>(amountPattern);
    map['counterparty_pattern'] = Variable<String>(counterpartyPattern);
    if (!nullToAbsent || datePattern != null) {
      map['date_pattern'] = Variable<String>(datePattern);
    }
    if (!nullToAbsent || referencePattern != null) {
      map['reference_pattern'] = Variable<String>(referencePattern);
    }
    map['transaction_type'] = Variable<String>(transactionType);
    map['is_active'] = Variable<int>(isActive);
    map['default_category_id'] = Variable<String>(defaultCategoryId);
    map['default_account_id'] = Variable<String>(defaultAccountId);
    map['auto_select_account'] = Variable<int>(autoSelectAccount);
    map['sender_name'] = Variable<String>(senderName);
    map['sample_sms'] = Variable<String>(sampleSms);
    map['created_timestamp'] = Variable<int>(createdTimestamp);
    if (!nullToAbsent || lastUsedTimestamp != null) {
      map['last_used_timestamp'] = Variable<int>(lastUsedTimestamp);
    }
    return map;
  }

  SMSParsingPatternsCompanion toCompanion(bool nullToAbsent) {
    return SMSParsingPatternsCompanion(
      id: Value(id),
      senderIdentifier: Value(senderIdentifier),
      patternName: Value(patternName),
      messageStructure: Value(messageStructure),
      amountPattern: Value(amountPattern),
      counterpartyPattern: Value(counterpartyPattern),
      datePattern: datePattern == null && nullToAbsent
          ? const Value.absent()
          : Value(datePattern),
      referencePattern: referencePattern == null && nullToAbsent
          ? const Value.absent()
          : Value(referencePattern),
      transactionType: Value(transactionType),
      isActive: Value(isActive),
      defaultCategoryId: Value(defaultCategoryId),
      defaultAccountId: Value(defaultAccountId),
      autoSelectAccount: Value(autoSelectAccount),
      senderName: Value(senderName),
      sampleSms: Value(sampleSms),
      createdTimestamp: Value(createdTimestamp),
      lastUsedTimestamp: lastUsedTimestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedTimestamp),
    );
  }

  factory SMSParsingPattern.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SMSParsingPattern(
      id: serializer.fromJson<int>(json['id']),
      senderIdentifier: serializer.fromJson<String>(json['senderIdentifier']),
      patternName: serializer.fromJson<String>(json['patternName']),
      messageStructure: serializer.fromJson<String>(json['messageStructure']),
      amountPattern: serializer.fromJson<String>(json['amountPattern']),
      counterpartyPattern: serializer.fromJson<String>(
        json['counterpartyPattern'],
      ),
      datePattern: serializer.fromJson<String?>(json['datePattern']),
      referencePattern: serializer.fromJson<String?>(json['referencePattern']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      isActive: serializer.fromJson<int>(json['isActive']),
      defaultCategoryId: serializer.fromJson<String>(json['defaultCategoryId']),
      defaultAccountId: serializer.fromJson<String>(json['defaultAccountId']),
      autoSelectAccount: serializer.fromJson<int>(json['autoSelectAccount']),
      senderName: serializer.fromJson<String>(json['senderName']),
      sampleSms: serializer.fromJson<String>(json['sampleSms']),
      createdTimestamp: serializer.fromJson<int>(json['createdTimestamp']),
      lastUsedTimestamp: serializer.fromJson<int?>(json['lastUsedTimestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'senderIdentifier': serializer.toJson<String>(senderIdentifier),
      'patternName': serializer.toJson<String>(patternName),
      'messageStructure': serializer.toJson<String>(messageStructure),
      'amountPattern': serializer.toJson<String>(amountPattern),
      'counterpartyPattern': serializer.toJson<String>(counterpartyPattern),
      'datePattern': serializer.toJson<String?>(datePattern),
      'referencePattern': serializer.toJson<String?>(referencePattern),
      'transactionType': serializer.toJson<String>(transactionType),
      'isActive': serializer.toJson<int>(isActive),
      'defaultCategoryId': serializer.toJson<String>(defaultCategoryId),
      'defaultAccountId': serializer.toJson<String>(defaultAccountId),
      'autoSelectAccount': serializer.toJson<int>(autoSelectAccount),
      'senderName': serializer.toJson<String>(senderName),
      'sampleSms': serializer.toJson<String>(sampleSms),
      'createdTimestamp': serializer.toJson<int>(createdTimestamp),
      'lastUsedTimestamp': serializer.toJson<int?>(lastUsedTimestamp),
    };
  }

  SMSParsingPattern copyWith({
    int? id,
    String? senderIdentifier,
    String? patternName,
    String? messageStructure,
    String? amountPattern,
    String? counterpartyPattern,
    Value<String?> datePattern = const Value.absent(),
    Value<String?> referencePattern = const Value.absent(),
    String? transactionType,
    int? isActive,
    String? defaultCategoryId,
    String? defaultAccountId,
    int? autoSelectAccount,
    String? senderName,
    String? sampleSms,
    int? createdTimestamp,
    Value<int?> lastUsedTimestamp = const Value.absent(),
  }) => SMSParsingPattern(
    id: id ?? this.id,
    senderIdentifier: senderIdentifier ?? this.senderIdentifier,
    patternName: patternName ?? this.patternName,
    messageStructure: messageStructure ?? this.messageStructure,
    amountPattern: amountPattern ?? this.amountPattern,
    counterpartyPattern: counterpartyPattern ?? this.counterpartyPattern,
    datePattern: datePattern.present ? datePattern.value : this.datePattern,
    referencePattern: referencePattern.present
        ? referencePattern.value
        : this.referencePattern,
    transactionType: transactionType ?? this.transactionType,
    isActive: isActive ?? this.isActive,
    defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
    defaultAccountId: defaultAccountId ?? this.defaultAccountId,
    autoSelectAccount: autoSelectAccount ?? this.autoSelectAccount,
    senderName: senderName ?? this.senderName,
    sampleSms: sampleSms ?? this.sampleSms,
    createdTimestamp: createdTimestamp ?? this.createdTimestamp,
    lastUsedTimestamp: lastUsedTimestamp.present
        ? lastUsedTimestamp.value
        : this.lastUsedTimestamp,
  );
  SMSParsingPattern copyWithCompanion(SMSParsingPatternsCompanion data) {
    return SMSParsingPattern(
      id: data.id.present ? data.id.value : this.id,
      senderIdentifier: data.senderIdentifier.present
          ? data.senderIdentifier.value
          : this.senderIdentifier,
      patternName: data.patternName.present
          ? data.patternName.value
          : this.patternName,
      messageStructure: data.messageStructure.present
          ? data.messageStructure.value
          : this.messageStructure,
      amountPattern: data.amountPattern.present
          ? data.amountPattern.value
          : this.amountPattern,
      counterpartyPattern: data.counterpartyPattern.present
          ? data.counterpartyPattern.value
          : this.counterpartyPattern,
      datePattern: data.datePattern.present
          ? data.datePattern.value
          : this.datePattern,
      referencePattern: data.referencePattern.present
          ? data.referencePattern.value
          : this.referencePattern,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      defaultCategoryId: data.defaultCategoryId.present
          ? data.defaultCategoryId.value
          : this.defaultCategoryId,
      defaultAccountId: data.defaultAccountId.present
          ? data.defaultAccountId.value
          : this.defaultAccountId,
      autoSelectAccount: data.autoSelectAccount.present
          ? data.autoSelectAccount.value
          : this.autoSelectAccount,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      sampleSms: data.sampleSms.present ? data.sampleSms.value : this.sampleSms,
      createdTimestamp: data.createdTimestamp.present
          ? data.createdTimestamp.value
          : this.createdTimestamp,
      lastUsedTimestamp: data.lastUsedTimestamp.present
          ? data.lastUsedTimestamp.value
          : this.lastUsedTimestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SMSParsingPattern(')
          ..write('id: $id, ')
          ..write('senderIdentifier: $senderIdentifier, ')
          ..write('patternName: $patternName, ')
          ..write('messageStructure: $messageStructure, ')
          ..write('amountPattern: $amountPattern, ')
          ..write('counterpartyPattern: $counterpartyPattern, ')
          ..write('datePattern: $datePattern, ')
          ..write('referencePattern: $referencePattern, ')
          ..write('transactionType: $transactionType, ')
          ..write('isActive: $isActive, ')
          ..write('defaultCategoryId: $defaultCategoryId, ')
          ..write('defaultAccountId: $defaultAccountId, ')
          ..write('autoSelectAccount: $autoSelectAccount, ')
          ..write('senderName: $senderName, ')
          ..write('sampleSms: $sampleSms, ')
          ..write('createdTimestamp: $createdTimestamp, ')
          ..write('lastUsedTimestamp: $lastUsedTimestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    senderIdentifier,
    patternName,
    messageStructure,
    amountPattern,
    counterpartyPattern,
    datePattern,
    referencePattern,
    transactionType,
    isActive,
    defaultCategoryId,
    defaultAccountId,
    autoSelectAccount,
    senderName,
    sampleSms,
    createdTimestamp,
    lastUsedTimestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SMSParsingPattern &&
          other.id == this.id &&
          other.senderIdentifier == this.senderIdentifier &&
          other.patternName == this.patternName &&
          other.messageStructure == this.messageStructure &&
          other.amountPattern == this.amountPattern &&
          other.counterpartyPattern == this.counterpartyPattern &&
          other.datePattern == this.datePattern &&
          other.referencePattern == this.referencePattern &&
          other.transactionType == this.transactionType &&
          other.isActive == this.isActive &&
          other.defaultCategoryId == this.defaultCategoryId &&
          other.defaultAccountId == this.defaultAccountId &&
          other.autoSelectAccount == this.autoSelectAccount &&
          other.senderName == this.senderName &&
          other.sampleSms == this.sampleSms &&
          other.createdTimestamp == this.createdTimestamp &&
          other.lastUsedTimestamp == this.lastUsedTimestamp);
}

class SMSParsingPatternsCompanion extends UpdateCompanion<SMSParsingPattern> {
  final Value<int> id;
  final Value<String> senderIdentifier;
  final Value<String> patternName;
  final Value<String> messageStructure;
  final Value<String> amountPattern;
  final Value<String> counterpartyPattern;
  final Value<String?> datePattern;
  final Value<String?> referencePattern;
  final Value<String> transactionType;
  final Value<int> isActive;
  final Value<String> defaultCategoryId;
  final Value<String> defaultAccountId;
  final Value<int> autoSelectAccount;
  final Value<String> senderName;
  final Value<String> sampleSms;
  final Value<int> createdTimestamp;
  final Value<int?> lastUsedTimestamp;
  const SMSParsingPatternsCompanion({
    this.id = const Value.absent(),
    this.senderIdentifier = const Value.absent(),
    this.patternName = const Value.absent(),
    this.messageStructure = const Value.absent(),
    this.amountPattern = const Value.absent(),
    this.counterpartyPattern = const Value.absent(),
    this.datePattern = const Value.absent(),
    this.referencePattern = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.defaultCategoryId = const Value.absent(),
    this.defaultAccountId = const Value.absent(),
    this.autoSelectAccount = const Value.absent(),
    this.senderName = const Value.absent(),
    this.sampleSms = const Value.absent(),
    this.createdTimestamp = const Value.absent(),
    this.lastUsedTimestamp = const Value.absent(),
  });
  SMSParsingPatternsCompanion.insert({
    this.id = const Value.absent(),
    required String senderIdentifier,
    required String patternName,
    required String messageStructure,
    required String amountPattern,
    required String counterpartyPattern,
    this.datePattern = const Value.absent(),
    this.referencePattern = const Value.absent(),
    required String transactionType,
    this.isActive = const Value.absent(),
    this.defaultCategoryId = const Value.absent(),
    this.defaultAccountId = const Value.absent(),
    this.autoSelectAccount = const Value.absent(),
    this.senderName = const Value.absent(),
    this.sampleSms = const Value.absent(),
    required int createdTimestamp,
    this.lastUsedTimestamp = const Value.absent(),
  }) : senderIdentifier = Value(senderIdentifier),
       patternName = Value(patternName),
       messageStructure = Value(messageStructure),
       amountPattern = Value(amountPattern),
       counterpartyPattern = Value(counterpartyPattern),
       transactionType = Value(transactionType),
       createdTimestamp = Value(createdTimestamp);
  static Insertable<SMSParsingPattern> custom({
    Expression<int>? id,
    Expression<String>? senderIdentifier,
    Expression<String>? patternName,
    Expression<String>? messageStructure,
    Expression<String>? amountPattern,
    Expression<String>? counterpartyPattern,
    Expression<String>? datePattern,
    Expression<String>? referencePattern,
    Expression<String>? transactionType,
    Expression<int>? isActive,
    Expression<String>? defaultCategoryId,
    Expression<String>? defaultAccountId,
    Expression<int>? autoSelectAccount,
    Expression<String>? senderName,
    Expression<String>? sampleSms,
    Expression<int>? createdTimestamp,
    Expression<int>? lastUsedTimestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (senderIdentifier != null) 'sender_identifier': senderIdentifier,
      if (patternName != null) 'pattern_name': patternName,
      if (messageStructure != null) 'message_structure': messageStructure,
      if (amountPattern != null) 'amount_pattern': amountPattern,
      if (counterpartyPattern != null)
        'counterparty_pattern': counterpartyPattern,
      if (datePattern != null) 'date_pattern': datePattern,
      if (referencePattern != null) 'reference_pattern': referencePattern,
      if (transactionType != null) 'transaction_type': transactionType,
      if (isActive != null) 'is_active': isActive,
      if (defaultCategoryId != null) 'default_category_id': defaultCategoryId,
      if (defaultAccountId != null) 'default_account_id': defaultAccountId,
      if (autoSelectAccount != null) 'auto_select_account': autoSelectAccount,
      if (senderName != null) 'sender_name': senderName,
      if (sampleSms != null) 'sample_sms': sampleSms,
      if (createdTimestamp != null) 'created_timestamp': createdTimestamp,
      if (lastUsedTimestamp != null) 'last_used_timestamp': lastUsedTimestamp,
    });
  }

  SMSParsingPatternsCompanion copyWith({
    Value<int>? id,
    Value<String>? senderIdentifier,
    Value<String>? patternName,
    Value<String>? messageStructure,
    Value<String>? amountPattern,
    Value<String>? counterpartyPattern,
    Value<String?>? datePattern,
    Value<String?>? referencePattern,
    Value<String>? transactionType,
    Value<int>? isActive,
    Value<String>? defaultCategoryId,
    Value<String>? defaultAccountId,
    Value<int>? autoSelectAccount,
    Value<String>? senderName,
    Value<String>? sampleSms,
    Value<int>? createdTimestamp,
    Value<int?>? lastUsedTimestamp,
  }) {
    return SMSParsingPatternsCompanion(
      id: id ?? this.id,
      senderIdentifier: senderIdentifier ?? this.senderIdentifier,
      patternName: patternName ?? this.patternName,
      messageStructure: messageStructure ?? this.messageStructure,
      amountPattern: amountPattern ?? this.amountPattern,
      counterpartyPattern: counterpartyPattern ?? this.counterpartyPattern,
      datePattern: datePattern ?? this.datePattern,
      referencePattern: referencePattern ?? this.referencePattern,
      transactionType: transactionType ?? this.transactionType,
      isActive: isActive ?? this.isActive,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      autoSelectAccount: autoSelectAccount ?? this.autoSelectAccount,
      senderName: senderName ?? this.senderName,
      sampleSms: sampleSms ?? this.sampleSms,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      lastUsedTimestamp: lastUsedTimestamp ?? this.lastUsedTimestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (senderIdentifier.present) {
      map['sender_identifier'] = Variable<String>(senderIdentifier.value);
    }
    if (patternName.present) {
      map['pattern_name'] = Variable<String>(patternName.value);
    }
    if (messageStructure.present) {
      map['message_structure'] = Variable<String>(messageStructure.value);
    }
    if (amountPattern.present) {
      map['amount_pattern'] = Variable<String>(amountPattern.value);
    }
    if (counterpartyPattern.present) {
      map['counterparty_pattern'] = Variable<String>(counterpartyPattern.value);
    }
    if (datePattern.present) {
      map['date_pattern'] = Variable<String>(datePattern.value);
    }
    if (referencePattern.present) {
      map['reference_pattern'] = Variable<String>(referencePattern.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (defaultCategoryId.present) {
      map['default_category_id'] = Variable<String>(defaultCategoryId.value);
    }
    if (defaultAccountId.present) {
      map['default_account_id'] = Variable<String>(defaultAccountId.value);
    }
    if (autoSelectAccount.present) {
      map['auto_select_account'] = Variable<int>(autoSelectAccount.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (sampleSms.present) {
      map['sample_sms'] = Variable<String>(sampleSms.value);
    }
    if (createdTimestamp.present) {
      map['created_timestamp'] = Variable<int>(createdTimestamp.value);
    }
    if (lastUsedTimestamp.present) {
      map['last_used_timestamp'] = Variable<int>(lastUsedTimestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SMSParsingPatternsCompanion(')
          ..write('id: $id, ')
          ..write('senderIdentifier: $senderIdentifier, ')
          ..write('patternName: $patternName, ')
          ..write('messageStructure: $messageStructure, ')
          ..write('amountPattern: $amountPattern, ')
          ..write('counterpartyPattern: $counterpartyPattern, ')
          ..write('datePattern: $datePattern, ')
          ..write('referencePattern: $referencePattern, ')
          ..write('transactionType: $transactionType, ')
          ..write('isActive: $isActive, ')
          ..write('defaultCategoryId: $defaultCategoryId, ')
          ..write('defaultAccountId: $defaultAccountId, ')
          ..write('autoSelectAccount: $autoSelectAccount, ')
          ..write('senderName: $senderName, ')
          ..write('sampleSms: $sampleSms, ')
          ..write('createdTimestamp: $createdTimestamp, ')
          ..write('lastUsedTimestamp: $lastUsedTimestamp')
          ..write(')'))
        .toString();
  }
}

class $SendersTable extends Senders with TableInfo<$SendersTable, Sender> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SendersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bank_accounts (id)',
    ),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isIgnoredMeta = const VerificationMeta(
    'isIgnored',
  );
  @override
  late final GeneratedColumn<int> isIgnored = GeneratedColumn<int>(
    'is_ignored',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ignoreReasonMeta = const VerificationMeta(
    'ignoreReason',
  );
  @override
  late final GeneratedColumn<String> ignoreReason = GeneratedColumn<String>(
    'ignore_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ignoredAtMeta = const VerificationMeta(
    'ignoredAt',
  );
  @override
  late final GeneratedColumn<int> ignoredAt = GeneratedColumn<int>(
    'ignored_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    senderName,
    accountId,
    description,
    isIgnored,
    ignoreReason,
    ignoredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'senders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sender> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_senderNameMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_ignored')) {
      context.handle(
        _isIgnoredMeta,
        isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta),
      );
    }
    if (data.containsKey('ignore_reason')) {
      context.handle(
        _ignoreReasonMeta,
        ignoreReason.isAcceptableOrUnknown(
          data['ignore_reason']!,
          _ignoreReasonMeta,
        ),
      );
    }
    if (data.containsKey('ignored_at')) {
      context.handle(
        _ignoredAtMeta,
        ignoredAt.isAcceptableOrUnknown(data['ignored_at']!, _ignoredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  Sender map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sender(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      isIgnored: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_ignored'],
      )!,
      ignoreReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ignore_reason'],
      ),
      ignoredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ignored_at'],
      ),
    );
  }

  @override
  $SendersTable createAlias(String alias) {
    return $SendersTable(attachedDatabase, alias);
  }
}

class Sender extends DataClass implements Insertable<Sender> {
  final int id;
  final String senderName;
  final String accountId;
  final String description;
  final int isIgnored;
  final String? ignoreReason;
  final int? ignoredAt;
  const Sender({
    required this.id,
    required this.senderName,
    required this.accountId,
    required this.description,
    required this.isIgnored,
    this.ignoreReason,
    this.ignoredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sender_name'] = Variable<String>(senderName);
    map['account_id'] = Variable<String>(accountId);
    map['description'] = Variable<String>(description);
    map['is_ignored'] = Variable<int>(isIgnored);
    if (!nullToAbsent || ignoreReason != null) {
      map['ignore_reason'] = Variable<String>(ignoreReason);
    }
    if (!nullToAbsent || ignoredAt != null) {
      map['ignored_at'] = Variable<int>(ignoredAt);
    }
    return map;
  }

  SendersCompanion toCompanion(bool nullToAbsent) {
    return SendersCompanion(
      id: Value(id),
      senderName: Value(senderName),
      accountId: Value(accountId),
      description: Value(description),
      isIgnored: Value(isIgnored),
      ignoreReason: ignoreReason == null && nullToAbsent
          ? const Value.absent()
          : Value(ignoreReason),
      ignoredAt: ignoredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(ignoredAt),
    );
  }

  factory Sender.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sender(
      id: serializer.fromJson<int>(json['id']),
      senderName: serializer.fromJson<String>(json['senderName']),
      accountId: serializer.fromJson<String>(json['accountId']),
      description: serializer.fromJson<String>(json['description']),
      isIgnored: serializer.fromJson<int>(json['isIgnored']),
      ignoreReason: serializer.fromJson<String?>(json['ignoreReason']),
      ignoredAt: serializer.fromJson<int?>(json['ignoredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'senderName': serializer.toJson<String>(senderName),
      'accountId': serializer.toJson<String>(accountId),
      'description': serializer.toJson<String>(description),
      'isIgnored': serializer.toJson<int>(isIgnored),
      'ignoreReason': serializer.toJson<String?>(ignoreReason),
      'ignoredAt': serializer.toJson<int?>(ignoredAt),
    };
  }

  Sender copyWith({
    int? id,
    String? senderName,
    String? accountId,
    String? description,
    int? isIgnored,
    Value<String?> ignoreReason = const Value.absent(),
    Value<int?> ignoredAt = const Value.absent(),
  }) => Sender(
    id: id ?? this.id,
    senderName: senderName ?? this.senderName,
    accountId: accountId ?? this.accountId,
    description: description ?? this.description,
    isIgnored: isIgnored ?? this.isIgnored,
    ignoreReason: ignoreReason.present ? ignoreReason.value : this.ignoreReason,
    ignoredAt: ignoredAt.present ? ignoredAt.value : this.ignoredAt,
  );
  Sender copyWithCompanion(SendersCompanion data) {
    return Sender(
      id: data.id.present ? data.id.value : this.id,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      description: data.description.present
          ? data.description.value
          : this.description,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
      ignoreReason: data.ignoreReason.present
          ? data.ignoreReason.value
          : this.ignoreReason,
      ignoredAt: data.ignoredAt.present ? data.ignoredAt.value : this.ignoredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sender(')
          ..write('id: $id, ')
          ..write('senderName: $senderName, ')
          ..write('accountId: $accountId, ')
          ..write('description: $description, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('ignoreReason: $ignoreReason, ')
          ..write('ignoredAt: $ignoredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    senderName,
    accountId,
    description,
    isIgnored,
    ignoreReason,
    ignoredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sender &&
          other.id == this.id &&
          other.senderName == this.senderName &&
          other.accountId == this.accountId &&
          other.description == this.description &&
          other.isIgnored == this.isIgnored &&
          other.ignoreReason == this.ignoreReason &&
          other.ignoredAt == this.ignoredAt);
}

class SendersCompanion extends UpdateCompanion<Sender> {
  final Value<int> id;
  final Value<String> senderName;
  final Value<String> accountId;
  final Value<String> description;
  final Value<int> isIgnored;
  final Value<String?> ignoreReason;
  final Value<int?> ignoredAt;
  final Value<int> rowid;
  const SendersCompanion({
    this.id = const Value.absent(),
    this.senderName = const Value.absent(),
    this.accountId = const Value.absent(),
    this.description = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.ignoreReason = const Value.absent(),
    this.ignoredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SendersCompanion.insert({
    required int id,
    required String senderName,
    required String accountId,
    this.description = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.ignoreReason = const Value.absent(),
    this.ignoredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       senderName = Value(senderName),
       accountId = Value(accountId);
  static Insertable<Sender> custom({
    Expression<int>? id,
    Expression<String>? senderName,
    Expression<String>? accountId,
    Expression<String>? description,
    Expression<int>? isIgnored,
    Expression<String>? ignoreReason,
    Expression<int>? ignoredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (senderName != null) 'sender_name': senderName,
      if (accountId != null) 'account_id': accountId,
      if (description != null) 'description': description,
      if (isIgnored != null) 'is_ignored': isIgnored,
      if (ignoreReason != null) 'ignore_reason': ignoreReason,
      if (ignoredAt != null) 'ignored_at': ignoredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SendersCompanion copyWith({
    Value<int>? id,
    Value<String>? senderName,
    Value<String>? accountId,
    Value<String>? description,
    Value<int>? isIgnored,
    Value<String?>? ignoreReason,
    Value<int?>? ignoredAt,
    Value<int>? rowid,
  }) {
    return SendersCompanion(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      accountId: accountId ?? this.accountId,
      description: description ?? this.description,
      isIgnored: isIgnored ?? this.isIgnored,
      ignoreReason: ignoreReason ?? this.ignoreReason,
      ignoredAt: ignoredAt ?? this.ignoredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isIgnored.present) {
      map['is_ignored'] = Variable<int>(isIgnored.value);
    }
    if (ignoreReason.present) {
      map['ignore_reason'] = Variable<String>(ignoreReason.value);
    }
    if (ignoredAt.present) {
      map['ignored_at'] = Variable<int>(ignoredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SendersCompanion(')
          ..write('id: $id, ')
          ..write('senderName: $senderName, ')
          ..write('accountId: $accountId, ')
          ..write('description: $description, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('ignoreReason: $ignoreReason, ')
          ..write('ignoredAt: $ignoredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TransactionTagsTable transactionTags = $TransactionTagsTable(
    this,
  );
  late final $BankAccountsTable bankAccounts = $BankAccountsTable(this);
  late final $SmsTableTable smsTable = $SmsTableTable(this);
  late final $SMSParsingPatternsTable sMSParsingPatterns =
      $SMSParsingPatternsTable(this);
  late final $SendersTable senders = $SendersTable(this);
  late final TransactionDao transactionDao = TransactionDao(
    this as AppDatabase,
  );
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final TagDao tagDao = TagDao(this as AppDatabase);
  late final BankAccountDao bankAccountDao = BankAccountDao(
    this as AppDatabase,
  );
  late final SmsDao smsDao = SmsDao(this as AppDatabase);
  late final PatternDao patternDao = PatternDao(this as AppDatabase);
  late final SenderDao senderDao = SenderDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    categories,
    tags,
    transactionTags,
    bankAccounts,
    smsTable,
    sMSParsingPatterns,
    senders,
  ];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required String counterParty,
      required double amount,
      required DateTime timestamp,
      required String categoryId,
      Value<String> description,
      required String accountId,
      required String transactionType,
      Value<String> referenceNumber,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<String> counterParty,
      Value<double> amount,
      Value<DateTime> timestamp,
      Value<String> categoryId,
      Value<String> description,
      Value<String> accountId,
      Value<String> transactionType,
      Value<String> referenceNumber,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterParty => $composableBuilder(
    column: $table.counterParty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterParty => $composableBuilder(
    column: $table.counterParty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get counterParty => $composableBuilder(
    column: $table.counterParty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
    column: $table.referenceNumber,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> counterParty = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<String> referenceNumber = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                counterParty: counterParty,
                amount: amount,
                timestamp: timestamp,
                categoryId: categoryId,
                description: description,
                accountId: accountId,
                transactionType: transactionType,
                referenceNumber: referenceNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String counterParty,
                required double amount,
                required DateTime timestamp,
                required String categoryId,
                Value<String> description = const Value.absent(),
                required String accountId,
                required String transactionType,
                Value<String> referenceNumber = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                counterParty: counterParty,
                amount: amount,
                timestamp: timestamp,
                categoryId: categoryId,
                description: description,
                accountId: accountId,
                transactionType: transactionType,
                referenceNumber: referenceNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String icon,
      required String name,
      required int color,
      Value<String> description,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> icon,
      Value<String> name,
      Value<int> color,
      Value<String> description,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                icon: icon,
                name: name,
                color: color,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String icon,
                required String name,
                required int color,
                Value<String> description = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                icon: icon,
                name: name,
                color: color,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      required String name,
      required String color,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> color,
    });

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
          Tag,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> color = const Value.absent(),
              }) => TagsCompanion(id: id, name: name, color: color),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String color,
              }) => TagsCompanion.insert(id: id, name: name, color: color),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
      Tag,
      PrefetchHooks Function()
    >;
typedef $$TransactionTagsTableCreateCompanionBuilder =
    TransactionTagsCompanion Function({
      Value<int> id,
      required String tagId,
      required String transactionId,
    });
typedef $$TransactionTagsTableUpdateCompanionBuilder =
    TransactionTagsCompanion Function({
      Value<int> id,
      Value<String> tagId,
      Value<String> transactionId,
    });

class $$TransactionTagsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionTagsTable> {
  $$TransactionTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);
}

class $$TransactionTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionTagsTable,
          TransactionTag,
          $$TransactionTagsTableFilterComposer,
          $$TransactionTagsTableOrderingComposer,
          $$TransactionTagsTableAnnotationComposer,
          $$TransactionTagsTableCreateCompanionBuilder,
          $$TransactionTagsTableUpdateCompanionBuilder,
          (
            TransactionTag,
            BaseReferences<
              _$AppDatabase,
              $TransactionTagsTable,
              TransactionTag
            >,
          ),
          TransactionTag,
          PrefetchHooks Function()
        > {
  $$TransactionTagsTableTableManager(
    _$AppDatabase db,
    $TransactionTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
              }) => TransactionTagsCompanion(
                id: id,
                tagId: tagId,
                transactionId: transactionId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tagId,
                required String transactionId,
              }) => TransactionTagsCompanion.insert(
                id: id,
                tagId: tagId,
                transactionId: transactionId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionTagsTable,
      TransactionTag,
      $$TransactionTagsTableFilterComposer,
      $$TransactionTagsTableOrderingComposer,
      $$TransactionTagsTableAnnotationComposer,
      $$TransactionTagsTableCreateCompanionBuilder,
      $$TransactionTagsTableUpdateCompanionBuilder,
      (
        TransactionTag,
        BaseReferences<_$AppDatabase, $TransactionTagsTable, TransactionTag>,
      ),
      TransactionTag,
      PrefetchHooks Function()
    >;
typedef $$BankAccountsTableCreateCompanionBuilder =
    BankAccountsCompanion Function({
      Value<int> id,
      required String accountName,
      required String accountNumber,
      Value<String> description,
    });
typedef $$BankAccountsTableUpdateCompanionBuilder =
    BankAccountsCompanion Function({
      Value<int> id,
      Value<String> accountName,
      Value<String> accountNumber,
      Value<String> description,
    });

class $$BankAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BankAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BankAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get accountName => $composableBuilder(
    column: $table.accountName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$BankAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankAccountsTable,
          BankAccount,
          $$BankAccountsTableFilterComposer,
          $$BankAccountsTableOrderingComposer,
          $$BankAccountsTableAnnotationComposer,
          $$BankAccountsTableCreateCompanionBuilder,
          $$BankAccountsTableUpdateCompanionBuilder,
          (
            BankAccount,
            BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccount>,
          ),
          BankAccount,
          PrefetchHooks Function()
        > {
  $$BankAccountsTableTableManager(_$AppDatabase db, $BankAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> accountName = const Value.absent(),
                Value<String> accountNumber = const Value.absent(),
                Value<String> description = const Value.absent(),
              }) => BankAccountsCompanion(
                id: id,
                accountName: accountName,
                accountNumber: accountNumber,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String accountName,
                required String accountNumber,
                Value<String> description = const Value.absent(),
              }) => BankAccountsCompanion.insert(
                id: id,
                accountName: accountName,
                accountNumber: accountNumber,
                description: description,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BankAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankAccountsTable,
      BankAccount,
      $$BankAccountsTableFilterComposer,
      $$BankAccountsTableOrderingComposer,
      $$BankAccountsTableAnnotationComposer,
      $$BankAccountsTableCreateCompanionBuilder,
      $$BankAccountsTableUpdateCompanionBuilder,
      (
        BankAccount,
        BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccount>,
      ),
      BankAccount,
      PrefetchHooks Function()
    >;
typedef $$SmsTableTableCreateCompanionBuilder =
    SmsTableCompanion Function({
      Value<int> id,
      required String sender,
      required String message,
      required int timestamp,
      Value<int> processed,
    });
typedef $$SmsTableTableUpdateCompanionBuilder =
    SmsTableCompanion Function({
      Value<int> id,
      Value<String> sender,
      Value<String> message,
      Value<int> timestamp,
      Value<int> processed,
    });

class $$SmsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SmsTableTable> {
  $$SmsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get processed => $composableBuilder(
    column: $table.processed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SmsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SmsTableTable> {
  $$SmsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sender => $composableBuilder(
    column: $table.sender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get processed => $composableBuilder(
    column: $table.processed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SmsTableTable> {
  $$SmsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sender =>
      $composableBuilder(column: $table.sender, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get processed =>
      $composableBuilder(column: $table.processed, builder: (column) => column);
}

class $$SmsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SmsTableTable,
          Sms,
          $$SmsTableTableFilterComposer,
          $$SmsTableTableOrderingComposer,
          $$SmsTableTableAnnotationComposer,
          $$SmsTableTableCreateCompanionBuilder,
          $$SmsTableTableUpdateCompanionBuilder,
          (Sms, BaseReferences<_$AppDatabase, $SmsTableTable, Sms>),
          Sms,
          PrefetchHooks Function()
        > {
  $$SmsTableTableTableManager(_$AppDatabase db, $SmsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sender = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<int> processed = const Value.absent(),
              }) => SmsTableCompanion(
                id: id,
                sender: sender,
                message: message,
                timestamp: timestamp,
                processed: processed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sender,
                required String message,
                required int timestamp,
                Value<int> processed = const Value.absent(),
              }) => SmsTableCompanion.insert(
                id: id,
                sender: sender,
                message: message,
                timestamp: timestamp,
                processed: processed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SmsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SmsTableTable,
      Sms,
      $$SmsTableTableFilterComposer,
      $$SmsTableTableOrderingComposer,
      $$SmsTableTableAnnotationComposer,
      $$SmsTableTableCreateCompanionBuilder,
      $$SmsTableTableUpdateCompanionBuilder,
      (Sms, BaseReferences<_$AppDatabase, $SmsTableTable, Sms>),
      Sms,
      PrefetchHooks Function()
    >;
typedef $$SMSParsingPatternsTableCreateCompanionBuilder =
    SMSParsingPatternsCompanion Function({
      Value<int> id,
      required String senderIdentifier,
      required String patternName,
      required String messageStructure,
      required String amountPattern,
      required String counterpartyPattern,
      Value<String?> datePattern,
      Value<String?> referencePattern,
      required String transactionType,
      Value<int> isActive,
      Value<String> defaultCategoryId,
      Value<String> defaultAccountId,
      Value<int> autoSelectAccount,
      Value<String> senderName,
      Value<String> sampleSms,
      required int createdTimestamp,
      Value<int?> lastUsedTimestamp,
    });
typedef $$SMSParsingPatternsTableUpdateCompanionBuilder =
    SMSParsingPatternsCompanion Function({
      Value<int> id,
      Value<String> senderIdentifier,
      Value<String> patternName,
      Value<String> messageStructure,
      Value<String> amountPattern,
      Value<String> counterpartyPattern,
      Value<String?> datePattern,
      Value<String?> referencePattern,
      Value<String> transactionType,
      Value<int> isActive,
      Value<String> defaultCategoryId,
      Value<String> defaultAccountId,
      Value<int> autoSelectAccount,
      Value<String> senderName,
      Value<String> sampleSms,
      Value<int> createdTimestamp,
      Value<int?> lastUsedTimestamp,
    });

class $$SMSParsingPatternsTableFilterComposer
    extends Composer<_$AppDatabase, $SMSParsingPatternsTable> {
  $$SMSParsingPatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderIdentifier => $composableBuilder(
    column: $table.senderIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get patternName => $composableBuilder(
    column: $table.patternName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageStructure => $composableBuilder(
    column: $table.messageStructure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountPattern => $composableBuilder(
    column: $table.amountPattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get counterpartyPattern => $composableBuilder(
    column: $table.counterpartyPattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datePattern => $composableBuilder(
    column: $table.datePattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get referencePattern => $composableBuilder(
    column: $table.referencePattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultCategoryId => $composableBuilder(
    column: $table.defaultCategoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultAccountId => $composableBuilder(
    column: $table.defaultAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get autoSelectAccount => $composableBuilder(
    column: $table.autoSelectAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sampleSms => $composableBuilder(
    column: $table.sampleSms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUsedTimestamp => $composableBuilder(
    column: $table.lastUsedTimestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SMSParsingPatternsTableOrderingComposer
    extends Composer<_$AppDatabase, $SMSParsingPatternsTable> {
  $$SMSParsingPatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderIdentifier => $composableBuilder(
    column: $table.senderIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get patternName => $composableBuilder(
    column: $table.patternName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageStructure => $composableBuilder(
    column: $table.messageStructure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountPattern => $composableBuilder(
    column: $table.amountPattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get counterpartyPattern => $composableBuilder(
    column: $table.counterpartyPattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datePattern => $composableBuilder(
    column: $table.datePattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get referencePattern => $composableBuilder(
    column: $table.referencePattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultCategoryId => $composableBuilder(
    column: $table.defaultCategoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultAccountId => $composableBuilder(
    column: $table.defaultAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get autoSelectAccount => $composableBuilder(
    column: $table.autoSelectAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sampleSms => $composableBuilder(
    column: $table.sampleSms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUsedTimestamp => $composableBuilder(
    column: $table.lastUsedTimestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SMSParsingPatternsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SMSParsingPatternsTable> {
  $$SMSParsingPatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderIdentifier => $composableBuilder(
    column: $table.senderIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get patternName => $composableBuilder(
    column: $table.patternName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageStructure => $composableBuilder(
    column: $table.messageStructure,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amountPattern => $composableBuilder(
    column: $table.amountPattern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get counterpartyPattern => $composableBuilder(
    column: $table.counterpartyPattern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datePattern => $composableBuilder(
    column: $table.datePattern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get referencePattern => $composableBuilder(
    column: $table.referencePattern,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get defaultCategoryId => $composableBuilder(
    column: $table.defaultCategoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultAccountId => $composableBuilder(
    column: $table.defaultAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get autoSelectAccount => $composableBuilder(
    column: $table.autoSelectAccount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sampleSms =>
      $composableBuilder(column: $table.sampleSms, builder: (column) => column);

  GeneratedColumn<int> get createdTimestamp => $composableBuilder(
    column: $table.createdTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastUsedTimestamp => $composableBuilder(
    column: $table.lastUsedTimestamp,
    builder: (column) => column,
  );
}

class $$SMSParsingPatternsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SMSParsingPatternsTable,
          SMSParsingPattern,
          $$SMSParsingPatternsTableFilterComposer,
          $$SMSParsingPatternsTableOrderingComposer,
          $$SMSParsingPatternsTableAnnotationComposer,
          $$SMSParsingPatternsTableCreateCompanionBuilder,
          $$SMSParsingPatternsTableUpdateCompanionBuilder,
          (
            SMSParsingPattern,
            BaseReferences<
              _$AppDatabase,
              $SMSParsingPatternsTable,
              SMSParsingPattern
            >,
          ),
          SMSParsingPattern,
          PrefetchHooks Function()
        > {
  $$SMSParsingPatternsTableTableManager(
    _$AppDatabase db,
    $SMSParsingPatternsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SMSParsingPatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SMSParsingPatternsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SMSParsingPatternsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> senderIdentifier = const Value.absent(),
                Value<String> patternName = const Value.absent(),
                Value<String> messageStructure = const Value.absent(),
                Value<String> amountPattern = const Value.absent(),
                Value<String> counterpartyPattern = const Value.absent(),
                Value<String?> datePattern = const Value.absent(),
                Value<String?> referencePattern = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<String> defaultCategoryId = const Value.absent(),
                Value<String> defaultAccountId = const Value.absent(),
                Value<int> autoSelectAccount = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String> sampleSms = const Value.absent(),
                Value<int> createdTimestamp = const Value.absent(),
                Value<int?> lastUsedTimestamp = const Value.absent(),
              }) => SMSParsingPatternsCompanion(
                id: id,
                senderIdentifier: senderIdentifier,
                patternName: patternName,
                messageStructure: messageStructure,
                amountPattern: amountPattern,
                counterpartyPattern: counterpartyPattern,
                datePattern: datePattern,
                referencePattern: referencePattern,
                transactionType: transactionType,
                isActive: isActive,
                defaultCategoryId: defaultCategoryId,
                defaultAccountId: defaultAccountId,
                autoSelectAccount: autoSelectAccount,
                senderName: senderName,
                sampleSms: sampleSms,
                createdTimestamp: createdTimestamp,
                lastUsedTimestamp: lastUsedTimestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String senderIdentifier,
                required String patternName,
                required String messageStructure,
                required String amountPattern,
                required String counterpartyPattern,
                Value<String?> datePattern = const Value.absent(),
                Value<String?> referencePattern = const Value.absent(),
                required String transactionType,
                Value<int> isActive = const Value.absent(),
                Value<String> defaultCategoryId = const Value.absent(),
                Value<String> defaultAccountId = const Value.absent(),
                Value<int> autoSelectAccount = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String> sampleSms = const Value.absent(),
                required int createdTimestamp,
                Value<int?> lastUsedTimestamp = const Value.absent(),
              }) => SMSParsingPatternsCompanion.insert(
                id: id,
                senderIdentifier: senderIdentifier,
                patternName: patternName,
                messageStructure: messageStructure,
                amountPattern: amountPattern,
                counterpartyPattern: counterpartyPattern,
                datePattern: datePattern,
                referencePattern: referencePattern,
                transactionType: transactionType,
                isActive: isActive,
                defaultCategoryId: defaultCategoryId,
                defaultAccountId: defaultAccountId,
                autoSelectAccount: autoSelectAccount,
                senderName: senderName,
                sampleSms: sampleSms,
                createdTimestamp: createdTimestamp,
                lastUsedTimestamp: lastUsedTimestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SMSParsingPatternsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SMSParsingPatternsTable,
      SMSParsingPattern,
      $$SMSParsingPatternsTableFilterComposer,
      $$SMSParsingPatternsTableOrderingComposer,
      $$SMSParsingPatternsTableAnnotationComposer,
      $$SMSParsingPatternsTableCreateCompanionBuilder,
      $$SMSParsingPatternsTableUpdateCompanionBuilder,
      (
        SMSParsingPattern,
        BaseReferences<
          _$AppDatabase,
          $SMSParsingPatternsTable,
          SMSParsingPattern
        >,
      ),
      SMSParsingPattern,
      PrefetchHooks Function()
    >;
typedef $$SendersTableCreateCompanionBuilder =
    SendersCompanion Function({
      required int id,
      required String senderName,
      required String accountId,
      Value<String> description,
      Value<int> isIgnored,
      Value<String?> ignoreReason,
      Value<int?> ignoredAt,
      Value<int> rowid,
    });
typedef $$SendersTableUpdateCompanionBuilder =
    SendersCompanion Function({
      Value<int> id,
      Value<String> senderName,
      Value<String> accountId,
      Value<String> description,
      Value<int> isIgnored,
      Value<String?> ignoreReason,
      Value<int?> ignoredAt,
      Value<int> rowid,
    });

class $$SendersTableFilterComposer
    extends Composer<_$AppDatabase, $SendersTable> {
  $$SendersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ignoreReason => $composableBuilder(
    column: $table.ignoreReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ignoredAt => $composableBuilder(
    column: $table.ignoredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SendersTableOrderingComposer
    extends Composer<_$AppDatabase, $SendersTable> {
  $$SendersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ignoreReason => $composableBuilder(
    column: $table.ignoreReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ignoredAt => $composableBuilder(
    column: $table.ignoredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SendersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SendersTable> {
  $$SendersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);

  GeneratedColumn<String> get ignoreReason => $composableBuilder(
    column: $table.ignoreReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ignoredAt =>
      $composableBuilder(column: $table.ignoredAt, builder: (column) => column);
}

class $$SendersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SendersTable,
          Sender,
          $$SendersTableFilterComposer,
          $$SendersTableOrderingComposer,
          $$SendersTableAnnotationComposer,
          $$SendersTableCreateCompanionBuilder,
          $$SendersTableUpdateCompanionBuilder,
          (Sender, BaseReferences<_$AppDatabase, $SendersTable, Sender>),
          Sender,
          PrefetchHooks Function()
        > {
  $$SendersTableTableManager(_$AppDatabase db, $SendersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SendersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SendersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SendersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> isIgnored = const Value.absent(),
                Value<String?> ignoreReason = const Value.absent(),
                Value<int?> ignoredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SendersCompanion(
                id: id,
                senderName: senderName,
                accountId: accountId,
                description: description,
                isIgnored: isIgnored,
                ignoreReason: ignoreReason,
                ignoredAt: ignoredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int id,
                required String senderName,
                required String accountId,
                Value<String> description = const Value.absent(),
                Value<int> isIgnored = const Value.absent(),
                Value<String?> ignoreReason = const Value.absent(),
                Value<int?> ignoredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SendersCompanion.insert(
                id: id,
                senderName: senderName,
                accountId: accountId,
                description: description,
                isIgnored: isIgnored,
                ignoreReason: ignoreReason,
                ignoredAt: ignoredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SendersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SendersTable,
      Sender,
      $$SendersTableFilterComposer,
      $$SendersTableOrderingComposer,
      $$SendersTableAnnotationComposer,
      $$SendersTableCreateCompanionBuilder,
      $$SendersTableUpdateCompanionBuilder,
      (Sender, BaseReferences<_$AppDatabase, $SendersTable, Sender>),
      Sender,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TransactionTagsTableTableManager get transactionTags =>
      $$TransactionTagsTableTableManager(_db, _db.transactionTags);
  $$BankAccountsTableTableManager get bankAccounts =>
      $$BankAccountsTableTableManager(_db, _db.bankAccounts);
  $$SmsTableTableTableManager get smsTable =>
      $$SmsTableTableTableManager(_db, _db.smsTable);
  $$SMSParsingPatternsTableTableManager get sMSParsingPatterns =>
      $$SMSParsingPatternsTableTableManager(_db, _db.sMSParsingPatterns);
  $$SendersTableTableManager get senders =>
      $$SendersTableTableManager(_db, _db.senders);
}
