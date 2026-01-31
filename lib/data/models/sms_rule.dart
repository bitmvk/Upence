class SMSRule {
  final String id;
  final String name;
  final String description;
  final String pattern;
  bool enabled;
  final String countryCode;

  SMSRule({
    required this.id,
    required this.name,
    required this.description,
    required this.pattern,
    this.enabled = true,
    required this.countryCode,
  });

  SMSRule copyWith({
    String? id,
    String? name,
    String? description,
    String? pattern,
    bool? enabled,
    String? countryCode,
  }) {
    return SMSRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pattern: pattern ?? this.pattern,
      enabled: enabled ?? this.enabled,
      countryCode: countryCode ?? this.countryCode,
    );
  }
}
