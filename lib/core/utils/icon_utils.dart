import 'package:flutter/material.dart';

class IconUtils {
  static const List<String> _handpickedIconNames = [
    'account_balance',
    'account_balance_wallet',
    'attach_money',
    'credit_card',
    'payment',
    'money',
    'receipt',
    'sell',
    'shopping_cart',
    'shopping_bag',
    'store',
    'local_offer',
    'point_of_sale',
    'savings',
    'wallet',
    'directions_car',
    'directions_bus',
    'flight',
    'directions_bike',
    'local_taxi',
    'directions_transit',
    'hotel',
    'location_on',
    'train',
    'restaurant',
    'restaurant_menu',
    'fastfood',
    'coffee',
    'local_cafe',
    'local_bar',
    'local_dining',
    'local_pizza',
    'icecream',
    'local_drink',
    'home',
    'home_work',
    'handyman',
    'water_drop',
    'power',
    'wifi',
    'electric_bolt',
    'lightbulb',
    'thermostat',
    'cleaning_services',
    'local_hospital',
    'medical_services',
    'health_and_safety',
    'fitness_center',
    'spa',
    'medical_information',
    'self_improvement',
    'accessible',
    'medication',
    'movie',
    'games',
    'music_note',
    'live_tv',
    'theater_comedy',
    'sports',
    'sports_esports',
    'headphones',
    'videocam',
    'photo_camera',
    'work',
    'school',
    'business',
    'menu_book',
    'local_library',
    'laptop',
    'assignment',
    'edit',
    'description',
    'attach_file',
    'phone',
    'email',
    'chat',
    'message',
    'notifications',
    'contact_mail',
    'language',
    'share',
    'person_add',
    'group',
    'pets',
    'child_care',
    'car_repair',
    'build',
    'settings',
    'help',
    'info',
    'check_circle',
    'error',
    'warning',
    'stars',
    'favorite',
    'bookmark',
    'schedule',
    'event',
  ];

  static Map<String, IconData>? _cache;
  static bool _loadError = false;
  static String? _errorMessage;

  static Map<String, IconData> get _handpickedIcons {
    return {for (var name in _handpickedIconNames) name: _getIconByName(name)};
  }

  static IconData _getIconByName(String name) {
    switch (name) {
      case 'account_balance':
        return Icons.account_balance;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'attach_money':
        return Icons.attach_money;
      case 'credit_card':
        return Icons.credit_card;
      case 'payment':
        return Icons.payment;
      case 'money':
        return Icons.money;
      case 'receipt':
        return Icons.receipt;
      case 'sell':
        return Icons.sell;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'store':
        return Icons.store;
      case 'local_offer':
        return Icons.local_offer;
      case 'point_of_sale':
        return Icons.point_of_sale;
      case 'savings':
        return Icons.savings;
      case 'wallet':
        return Icons.wallet;
      case 'directions_car':
        return Icons.directions_car;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'flight':
        return Icons.flight;
      case 'directions_bike':
        return Icons.directions_bike;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'directions_transit':
        return Icons.directions_transit;
      case 'hotel':
        return Icons.hotel;
      case 'location_on':
        return Icons.location_on;
      case 'train':
        return Icons.train;
      case 'restaurant':
        return Icons.restaurant;
      case 'restaurant_menu':
        return Icons.restaurant_menu;
      case 'fastfood':
        return Icons.fastfood;
      case 'coffee':
        return Icons.coffee;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'local_bar':
        return Icons.local_bar;
      case 'local_dining':
        return Icons.local_dining;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'icecream':
        return Icons.icecream;
      case 'local_drink':
        return Icons.local_drink;
      case 'home':
        return Icons.home;
      case 'home_work':
        return Icons.home_work;
      case 'handyman':
        return Icons.handyman;
      case 'water_drop':
        return Icons.water_drop;
      case 'power':
        return Icons.power;
      case 'wifi':
        return Icons.wifi;
      case 'electric_bolt':
        return Icons.electric_bolt;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'thermostat':
        return Icons.thermostat;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'medical_services':
        return Icons.medical_services;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'spa':
        return Icons.spa;
      case 'medical_information':
        return Icons.medical_information;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'accessible':
        return Icons.accessible;
      case 'medication':
        return Icons.medication;
      case 'movie':
        return Icons.movie;
      case 'games':
        return Icons.games;
      case 'music_note':
        return Icons.music_note;
      case 'live_tv':
        return Icons.live_tv;
      case 'theater_comedy':
        return Icons.theater_comedy;
      case 'sports':
        return Icons.sports;
      case 'sports_esports':
        return Icons.sports_esports;
      case 'headphones':
        return Icons.headphones;
      case 'videocam':
        return Icons.videocam;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'work':
        return Icons.work;
      case 'school':
        return Icons.school;
      case 'business':
        return Icons.business;
      case 'menu_book':
        return Icons.menu_book;
      case 'local_library':
        return Icons.local_library;
      case 'laptop':
        return Icons.laptop;
      case 'assignment':
        return Icons.assignment;
      case 'edit':
        return Icons.edit;
      case 'description':
        return Icons.description;
      case 'attach_file':
        return Icons.attach_file;
      case 'phone':
        return Icons.phone;
      case 'email':
        return Icons.email;
      case 'chat':
        return Icons.chat;
      case 'message':
        return Icons.message;
      case 'notifications':
        return Icons.notifications;
      case 'contact_mail':
        return Icons.contact_mail;
      case 'language':
        return Icons.language;
      case 'share':
        return Icons.share;
      case 'person_add':
        return Icons.person_add;
      case 'group':
        return Icons.group;
      case 'pets':
        return Icons.pets;
      case 'child_care':
        return Icons.child_care;
      case 'car_repair':
        return Icons.car_repair;
      case 'build':
        return Icons.build;
      case 'settings':
        return Icons.settings;
      case 'help':
        return Icons.help;
      case 'info':
        return Icons.info;
      case 'check_circle':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'stars':
        return Icons.stars;
      case 'favorite':
        return Icons.favorite;
      case 'bookmark':
        return Icons.bookmark;
      case 'schedule':
        return Icons.schedule;
      case 'event':
        return Icons.event;
      default:
        return Icons.category;
    }
  }

  static void populateCache(Map<String, IconData> icons) {
    _cache = icons;
  }

  static void setLoadError(String message) {
    _loadError = true;
    _errorMessage = message;
  }

  static IconData getIcon(String iconName) {
    if (_cache != null) {
      return _cache![iconName] ?? Icons.category;
    }
    final handpicked = _handpickedIcons[iconName];
    if (handpicked != null) return handpicked;
    return Icons.category;
  }

  static bool get cacheReady => _cache != null;
  static bool get hasLoadError => _loadError;
  static String? get errorMessage => _errorMessage;
  static List<String> get handpickedIconNames =>
      List.from(_handpickedIconNames);
  static Map<String, IconData> get handpickedIcons => _handpickedIcons;
}
