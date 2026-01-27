class Category {
  final int id;
  final String icon;
  final String name;
  final int color;
  final String description;

  Category({
    required this.id,
    required this.icon,
    required this.name,
    required this.color,
    this.description = '',
  });

  Category copyWith({
    int? id,
    String? icon,
    String? name,
    int? color,
    String? description,
  }) {
    return Category(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      name: name ?? this.name,
      color: color ?? this.color,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'color': color,
      'description': description,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      icon: map['icon'] as String,
      name: map['name'] as String,
      color: map['color'] as int,
      description: map['description'] as String? ?? '',
    );
  }
}
