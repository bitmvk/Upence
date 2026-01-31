import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../../data/models/sms_rule.dart' as models;

class SMSRulesService {
  static final SMSRulesService _instance = SMSRulesService._internal();
  factory SMSRulesService() => _instance;
  SMSRulesService._internal();

  static const String _rulesKey = 'sms_rules_user_selections';
  static const String _defaultCountryKey = 'sms_rules_default_country';

  List<models.SMSRule> _bundledRules = [];
  List<models.SMSRule> _userRules = [];

  Future<void> initialize() async {
    await _loadBundledRules();
    await _loadUserSelections();
  }

  Future<void> _loadBundledRules() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/sms_rules/bundled_rules.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final countries = json['countries'] as List;

      _bundledRules.clear();
      for (final country in countries) {
        final countryCode = country['code'] as String;
        final rules = country['rules'] as List;
        for (final rule in rules) {
          _bundledRules.add(
            models.SMSRule(
              id: rule['id'] as String,
              name: rule['name'] as String,
              description: rule['description'] as String,
              pattern: rule['pattern'] as String,
              enabled: rule['enabled'] as bool? ?? true,
              countryCode: countryCode,
            ),
          );
        }
      }
      debugPrint('[SMSRules] Loaded ${_bundledRules.length} bundled rules');
    } catch (e) {
      debugPrint('[SMSRules] Error loading bundled rules: $e');
    }
  }

  Future<void> _loadUserSelections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectionsJson = prefs.getString(_rulesKey);
      if (selectionsJson != null) {
        final selections = jsonDecode(selectionsJson) as Map<String, bool>;

        for (final rule in _bundledRules) {
          if (selections.containsKey(rule.id)) {
            rule.enabled = selections[rule.id] as bool;
          }
        }
      }
    } catch (e) {
      debugPrint('[SMSRules] Error loading user selections: $e');
    }
  }

  Future<void> saveUserSelections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selections = <String, bool>{};

      for (final rule in _bundledRules) {
        selections[rule.id] = rule.enabled;
      }

      await prefs.setString(_rulesKey, jsonEncode(selections));
      debugPrint('[SMSRules] Saved user selections');
    } catch (e) {
      debugPrint('[SMSRules] Error saving user selections: $e');
    }
  }

  List<models.SMSRule> getBundledRules() => _bundledRules;

  List<models.SMSRule> getActiveRules() =>
      _bundledRules.where((r) => r.enabled == true).toList();

  List<models.SMSRule> getRulesByCountry(String countryCode) =>
      _bundledRules.where((r) => r.countryCode == countryCode).toList();

  Future<String?> getActiveCountryCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_defaultCountryKey);
  }

  Future<void> setActiveCountryCode(String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultCountryKey, countryCode);
  }

  bool matchesTransactionSender(String sender) {
    final activeRules = getActiveRules();
    for (final rule in activeRules) {
      try {
        final regex = RegExp(rule.pattern, caseSensitive: false);
        if (regex.hasMatch(sender)) {
          debugPrint('[SMSRules] Sender "$sender" matched rule: ${rule.name}');
          return true;
        }
      } catch (e) {
        debugPrint(
          '[SMSRules] Invalid regex in rule ${rule.id}: ${rule.pattern}',
        );
        continue;
      }
    }
    return false;
  }
}
