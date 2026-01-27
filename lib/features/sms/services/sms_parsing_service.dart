import '../../../data/models/sms_parsing_pattern.dart';
import '../../../data/models/sms.dart';
import '../../../data/models/transaction.dart';

class SMSParsingService {
  static const double _matchScoreThreshold = 0.5;

  List<SMSParsingPattern> findMatchingPatterns(
    SMSMessage sms,
    List<SMSParsingPattern> patterns,
  ) {
    final messageWords = sms.message.split(' ');

    final matchedPatterns = patterns
        .map((pattern) {
          final score = _calculateMatchScore(messageWords, pattern);
          final lastUsedPenalty = _calculateRecencyPenalty(pattern);
          final adjustedScore = score - lastUsedPenalty;

          return {'pattern': pattern, 'score': adjustedScore};
        })
        .where((result) => result['score'] as double >= _matchScoreThreshold)
        .toList();

    if (matchedPatterns.isEmpty) return [];

    matchedPatterns.sort((a, b) {
      final scoreA = a['score'] as double;
      final scoreB = b['score'] as double;
      return scoreB.compareTo(scoreA);
    });

    return matchedPatterns
        .map((result) => result['pattern'] as SMSParsingPattern)
        .toList();
  }

  double _calculateMatchScore(
    List<String> messageWords,
    SMSParsingPattern pattern,
  ) {
    final patternStructure = pattern.messageStructure;
    final structureParts = patternStructure.split(',');

    if (structureParts.length != messageWords.length) {
      final lengthDiff = (structureParts.length - messageWords.length).abs();
      return 1.0 - (lengthDiff * 0.1);
    }

    int matches = 0;
    for (int i = 0; i < messageWords.length && i < structureParts.length; i++) {
      final messageWord = messageWords[i].toLowerCase();
      final structurePart = structureParts[i].toLowerCase();

      if (structurePart == messageWord ||
          structurePart == '[text]' ||
          structurePart == '[number]') {
        matches++;
      }
    }

    return matches / messageWords.length;
  }

  double _calculateRecencyPenalty(SMSParsingPattern pattern) {
    if (pattern.lastUsedTimestamp == null) return 0.0;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastUsed = pattern.lastUsedTimestamp!;
    final daysSinceUse = (now - lastUsed) / (1000 * 60 * 60 * 24);

    if (daysSinceUse > 30) return 0.0;
    return (30 - daysSinceUse) / 1000;
  }

  Map<String, String?> extractFields(
    String message,
    SMSParsingPattern pattern,
  ) {
    final words = message.split(' ');

    final amount = _extractAmount(words, pattern.amountPattern);
    final counterparty = _extractCounterparty(
      words,
      pattern.counterpartyPattern,
    );
    final reference = pattern.referencePattern != null
        ? _extractReference(words, pattern.referencePattern!)
        : null;

    return {
      'amount': amount,
      'counterparty': counterparty,
      'reference': reference,
    };
  }

  String _extractAmount(List<String> words, String pattern) {
    final indices = pattern.split(',').map(int.parse).toList();

    if (indices.isEmpty || indices[0] >= words.length) return '';

    var amount = words[indices[0]];
    amount = amount.replaceAll(RegExp(r'[^\d.]'), '');
    amount = amount.replaceAll(RegExp(r'^\.+|\.$'), '');

    return amount;
  }

  String _extractCounterparty(List<String> words, String pattern) {
    final indices = pattern.split(',').map(int.parse).toList();

    if (indices.isEmpty) return '';

    final counterpartyWords = indices
        .where((i) => i < words.length)
        .map((i) => words[i])
        .toList();

    return counterpartyWords.join(' ');
  }

  String _extractReference(List<String> words, String pattern) {
    final indices = pattern.split(',').map(int.parse).toList();

    if (indices.isEmpty || indices[0] >= words.length) return '';

    return words[indices[0]];
  }

  String buildMessageStructure(String message) {
    final words = message.split(' ');

    return words
        .map((word) {
          if (_isNumeric(word)) {
            return '[NUMBER]';
          } else if (word.length <= 3) {
            return '[TEXT]';
          } else {
            return word.toUpperCase();
          }
        })
        .join(',');
  }

  bool _isNumeric(String str) {
    final numericRegex = RegExp(r'^[\d.,]+$');
    return numericRegex.hasMatch(str);
  }

  TransactionType detectTransactionType(String message) {
    final lowerMessage = message.toLowerCase();

    final creditKeywords = [
      'credited',
      'received',
      'added',
      'deposited',
      'refund',
      'cashback',
    ];

    final debitKeywords = [
      'debited',
      'spent',
      'paid',
      'purchase',
      'transfer',
      'withdrawn',
      'charged',
    ];

    for (final keyword in creditKeywords) {
      if (lowerMessage.contains(keyword)) {
        return TransactionType.credit;
      }
    }

    for (final keyword in debitKeywords) {
      if (lowerMessage.contains(keyword)) {
        return TransactionType.debit;
      }
    }

    return TransactionType.debit;
  }

  bool isBankMessage(String sender) {
    final bankPatterns = [
      RegExp(r'-S$'),
      RegExp(r'BANK', caseSensitive: false),
      RegExp(r'UPI', caseSensitive: false),
      RegExp(r'TRANSACTION', caseSensitive: false),
    ];

    for (final pattern in bankPatterns) {
      if (pattern.hasMatch(sender)) {
        return true;
      }
    }

    return false;
  }
}
