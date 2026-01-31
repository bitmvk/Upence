class RegexSenderPattern {
  final int id;
  final String regexPattern;
  final String? description;
  final int priority;
  final bool isActive;
  final int createdTimestamp;

  RegexSenderPattern({
    required this.id,
    required this.regexPattern,
    this.description,
    this.priority = 0,
    this.isActive = true,
    required this.createdTimestamp,
  });

  RegexSenderPattern copyWith({
    int? id,
    String? regexPattern,
    String? description,
    int? priority,
    bool? isActive,
    int? createdTimestamp,
  }) {
    return RegexSenderPattern(
      id: id ?? this.id,
      regexPattern: regexPattern ?? this.regexPattern,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
    );
  }
}
