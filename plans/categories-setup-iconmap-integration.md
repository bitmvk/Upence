# Categories Setup Page - IconMap Integration Plan

## Overview
Update `categories_setup_page.dart` to use the `iconMap` from `core/ui/icon_mapper.dart` the same way `accounts_setup_page.dart` does. The database stores the icon as a string key (e.g., "category", "shopping_cart"), and when loading an icon, it uses the `iconMap` to get the corresponding `IconData`.

## Current State

### accounts_setup_page.dart (Reference Implementation)
- **Import**: `import 'package:upence/core/ui/icon_mapper.dart';`
- **Icon Display**: Uses `iconMap[account.icon]` to get IconData
- **Icon Storage**: Stores icon as string key (e.g., "account_balance")
- **Dropdown**: Uses filtered list from `iconMap` with `entry.key` as value

### categories_setup_page.dart (Needs Updates)
- **Import**: Missing `icon_mapper.dart` import
- **Icon Display**: Uses `IconData(int.parse(category.icon), fontFamily: 'MaterialIcons')` - parses hex string
- **Icon Storage**: Stores icon as hex string (e.g., '0xe157')
- **Dropdown**: Uses hardcoded DropdownMenuItems with hex string values

## Required Changes

### 1. Add Import
```dart
import 'package:upence/core/ui/icon_mapper.dart';
```

### 2. Update _CategoryCard Widget (Line 118-123)
**Current:**
```dart
leading: CircleAvatar(
  backgroundColor: Color(category.color),
  child: Icon(
    IconData(int.parse(category.icon), fontFamily: 'MaterialIcons'),
    color: Colors.white,
  ),
),
```

**New:**
```dart
leading: CircleAvatar(
  backgroundColor: Color(category.color),
  child: Icon(
    iconMap[category.icon] ?? Icons.category,
    color: Colors.white,
  ),
),
```

### 3. Update _CategoryDialogState Class (Lines 151-167)

**Current:**
```dart
class _CategoryDialogState extends State<_CategoryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _icon = '0xe157';
  Color _color = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
    if (widget.category != null) {
      _icon = widget.category!.icon;
      _color = Color(widget.category!.color);
    }
  }
  // ...
}
```

**New:**
```dart
class _CategoryDialogState extends State<_CategoryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _icon = "category";
  Color _color = Colors.deepPurple;
  
  final categoryIcons = iconMap.entries
      .where(
        (e) => [
          // Food & Dining
          'restaurant', 'fastfood', 'pizza', 'coffee', 'breakfast_dining',
          'dinner_dining', 'lunch_dining', 'icecream', 'cake', 'liquor',
          'local_bar', 'ramen_dining', 'set_meal', 'restaurant_menu',
          // Transportation
          'directions_car', 'directions_bike', 'directions_walk',
          'directions_bus', 'directions_railway', 'directions_transit',
          'flight', 'flight_land', 'flight_takeoff', 'train', 'subway',
          'tram', 'local_taxi', 'electric_car', 'airport_shuttle',
          'pedal_bike', 'two_wheeler', 'moped', 'electric_scooter',
          // Shopping
          'shopping_cart', 'store', 'shopping_bag', 'local_mall',
          'payment', 'receipt', 'point_of_sale',
          // Entertainment
          'theater_comedy', 'movie_filter', 'movie_creation', 'live_tv',
          'sports_esports', 'sports_soccer', 'sports_basketball',
          'sports_baseball', 'sports_cricket', 'sports_tennis',
          'sports_golf', 'sports', 'fitness_center', 'games',
          'videogame_asset',
          // Health & Wellness
          'medical_services', 'health_and_safety', 'local_hospital',
          'local_pharmacy', 'medication', 'vaccines', 'psychology',
          'self_improvement', 'spa', 'healing', 'monitor_heart',
          // Utilities & Services
          'water_drop', 'bolt', 'gas_meter', 'lightbulb_outline',
          'wb_sunny', 'ac_unit', 'thermostat', 'cleaning_services',
          // Education
          'school', 'book', 'menu_book', 'import_contacts',
          'library_books', 'library_add', 'class', 'science',
          // Personal Care
          'face', 'content_cut', 'spa',
          // Travel
          'luggage', 'hotel', 'beach_access', 'hiking', 'nature',
          // Subscriptions & Bills
          'subscriptions', 'receipt_long',
          // Miscellaneous
          'home', 'work', 'pets', 'category',
        ].contains(e.key),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.category?.description ?? '',
    );
    if (widget.category != null) {
      _icon = widget.category!.icon;
      _color = Color(widget.category!.color);
    }
  }
  // ...
}
```

### 4. Update DropdownButtonFormField (Lines 201-238)

**Current:**
```dart
DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Icon',
    border: OutlineInputBorder(),
  ),
  initialValue: _icon,
  items: const [
    DropdownMenuItem(value: '0xe157', child: Icon(Icons.category)),
    DropdownMenuItem(value: '0xe856', child: Icon(Icons.shopping_cart)),
    DropdownMenuItem(value: '0xe7ef', child: Icon(Icons.restaurant)),
    DropdownMenuItem(value: '0xe53e', child: Icon(Icons.directions_car)),
    DropdownMenuItem(value: '0xe7fd', child: Icon(Icons.home)),
    DropdownMenuItem(value: '0xe88f', child: Icon(Icons.work)),
    DropdownMenuItem(value: '0xe853', child: Icon(Icons.health_and_safety)),
    DropdownMenuItem(value: '0xe86c', child: Icon(Icons.school)),
    DropdownMenuItem(value: '0xe41b', child: Icon(Icons.flight)),
    DropdownMenuItem(value: '0xe7b1', child: Icon(Icons.games)),
  ],
  onChanged: (value) {
    if (value != null) {
      setState(() {
        _icon = value;
      });
    }
  },
),
```

**New:**
```dart
DropdownButtonFormField<String>(
  decoration: const InputDecoration(
    labelText: 'Icon',
    border: OutlineInputBorder(),
  ),
  initialValue: _icon,
  items: categoryIcons.map((entry) {
    return DropdownMenuItem<String>(
      value: entry.key, // Use the key as the value
      child: Icon(entry.value), // Use the IconData for display
    );
  }).toList(),
  onChanged: (value) {
    if (value != null) {
      setState(() {
        _icon = value;
      });
    }
  },
),
```

## Data Flow Diagram

```mermaid
flowchart TD
    A[User selects icon from dropdown] --> B[Store string key in _icon]
    B --> C[Save Category to database]
    C --> D[Database stores icon as string key]
    D --> E[Load Category from database]
    E --> F[iconMap[category.icon] retrieves IconData]
    F --> G[Display icon in UI]
    
    style A fill:#e1f5ff
    style B fill:#fff4e1
    style C fill:#e8f5e9
    style D fill:#fff3e0
    style E fill:#e8f5e9
    style F fill:#fff4e1
    style G fill:#e1f5ff
```

## Benefits of This Change

1. **Consistency**: Same pattern used across accounts and categories setup pages
2. **Maintainability**: Single source of truth for icon mappings
3. **Type Safety**: String keys are more readable and less error-prone than hex codes
4. **Extensibility**: Easy to add new icons by updating the filtered list
5. **Database Compatibility**: Text column stores string keys directly

## Migration Considerations

**Note**: Existing categories in the database with hex string icons (e.g., '0xe157') will need to be migrated to use the new string keys. This is a data migration task that should be handled separately.

## Testing Checklist

- [ ] Verify icon displays correctly in _CategoryCard
- [ ] Verify dropdown shows all category-relevant icons
- [ ] Verify icon selection works correctly
- [ ] Verify icon is saved as string key to database
- [ ] Verify icon is loaded correctly from database
- [ ] Test editing existing categories
- [ ] Test adding new categories
