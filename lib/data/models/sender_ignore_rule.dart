class SenderIgnoreRule {
  final int id;
  final String ruleName;
  final String regexPattern;
  final String? description;
  final bool isActive;
  final bool isBundled;
  final int createdTimestamp;

  SenderIgnoreRule({
    required this.id,
    required this.ruleName,
    required this.regexPattern,
    this.description,
    this.isActive = true,
    this.isBundled = false,
    required this.createdTimestamp,
  });

  SenderIgnoreRule copyWith({
    int? id,
    String? ruleName,
    String? regexPattern,
    String? description,
    bool? isActive,
    bool? isBundled,
    int? createdTimestamp,
  }) {
    return SenderIgnoreRule(
      id: id ?? this.id,
      ruleName: ruleName ?? this.ruleName,
      regexPattern: regexPattern ?? this.regexPattern,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      isBundled: isBundled ?? this.isBundled,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
    );
  }
}
