class Sender {
  final int id;
  final String senderName;
  final String accountId;
  final String description;
  final bool isIgnored;
  final String? ignoreReason;
  final int? ignoredAt;

  Sender({
    required this.id,
    required this.senderName,
    this.accountId = '',
    this.description = '',
    this.isIgnored = false,
    this.ignoreReason,
    this.ignoredAt,
  });

  Sender copyWith({
    int? id,
    String? senderName,
    String? accountId,
    String? description,
    bool? isIgnored,
    String? ignoreReason,
    int? ignoredAt,
  }) {
    return Sender(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      accountId: accountId ?? this.accountId,
      description: description ?? this.description,
      isIgnored: isIgnored ?? this.isIgnored,
      ignoreReason: ignoreReason ?? this.ignoreReason,
      ignoredAt: ignoredAt ?? this.ignoredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderName': senderName,
      'accountId': accountId,
      'description': description,
      'isIgnored': isIgnored ? 1 : 0,
      'ignoreReason': ignoreReason,
      'ignoredAt': ignoredAt,
    };
  }

  factory Sender.fromMap(Map<String, dynamic> map) {
    return Sender(
      id: map['id'] as int,
      senderName: map['senderName'] as String,
      accountId: map['accountId'] as String? ?? '',
      description: map['description'] as String? ?? '',
      isIgnored: (map['isIgnored'] as int?) == 1,
      ignoreReason: map['ignoreReason'] as String?,
      ignoredAt: map['ignoredAt'] as int?,
    );
  }
}
