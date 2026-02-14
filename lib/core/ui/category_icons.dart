abstract class CategoryIcons {
  static const foodAndDining = [
    'restaurant',
    'fastfood',
    'pizza',
    'coffee',
    'breakfast_dining',
    'dinner_dining',
    'lunch_dining',
    'icecream',
    'cake',
    'liquor',
    'local_bar',
    'ramen_dining',
    'set_meal',
    'restaurant_menu',
  ];

  static const transportation = [
    'directions_car',
    'directions_bike',
    'directions_walk',
    'directions_bus',
    'directions_railway',
    'directions_transit',
    'flight',
    'flight_land',
    'flight_takeoff',
    'train',
    'subway',
    'tram',
    'local_taxi',
    'electric_car',
    'airport_shuttle',
    'pedal_bike',
    'two_wheeler',
    'moped',
    'electric_scooter',
  ];

  static const shopping = [
    'shopping_cart',
    'store',
    'shopping_bag',
    'local_mall',
    'payment',
    'receipt',
    'point_of_sale',
  ];

  static const entertainment = [
    'theater_comedy',
    'movie_filter',
    'movie_creation',
    'live_tv',
    'sports_esports',
    'sports_soccer',
    'sports_basketball',
    'sports_baseball',
    'sports_cricket',
    'sports_tennis',
    'sports_golf',
    'sports',
    'fitness_center',
    'games',
    'videogame_asset',
  ];

  static const healthAndWellness = [
    'medical_services',
    'health_and_safety',
    'local_hospital',
    'local_pharmacy',
    'medication',
    'vaccines',
    'psychology',
    'self_improvement',
    'spa',
    'healing',
    'monitor_heart',
  ];

  static const utilities = [
    'water_drop',
    'bolt',
    'gas_meter',
    'lightbulb_outline',
    'wb_sunny',
    'ac_unit',
    'thermostat',
    'cleaning_services',
  ];

  static const education = [
    'school',
    'book',
    'menu_book',
    'import_contacts',
    'library_books',
    'library_add',
    'class',
    'science',
  ];

  static const personalCare = ['face', 'content_cut'];

  static const travel = [
    'luggage',
    'hotel',
    'beach_access',
    'hiking',
    'nature',
  ];

  static const subscriptionsAndBills = ['subscriptions', 'receipt_long'];

  static const miscellaneous = ['home', 'work', 'pets', 'category'];

  static const all = [
    ...foodAndDining,
    ...transportation,
    ...shopping,
    ...entertainment,
    ...healthAndWellness,
    ...utilities,
    ...education,
    ...personalCare,
    ...travel,
    ...subscriptionsAndBills,
    ...miscellaneous,
  ];
}

abstract class FinanceIcons {
  static const all = [
    'account_balance',
    'credit_card',
    'account_balance_wallet',
    'savings',
    'attach_money',
    'payment',
    'receipt',
    'point_of_sale',
  ];
}
