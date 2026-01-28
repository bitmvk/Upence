import 'package:flutter/foundation.dart';
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
    final messageStructure = buildMessageStructure(sms.message);

    debugPrint('[MATCHING] Testing ${patterns.length} patterns against SMS');
    debugPrint('[MATCHING] SMS structure: $messageStructure');

    final matchedPatterns = patterns
        .map((pattern) {
          debugPrint('  → Evaluating pattern: ${pattern.patternName}');
          debugPrint('    Pattern structure: ${pattern.messageStructure}');

          final score = _calculateMatchScore(messageWords, pattern);
          final lastUsedPenalty = _calculateRecencyPenalty(pattern);
          final adjustedScore = score - lastUsedPenalty;

          debugPrint('    Raw match score: ${score.toStringAsFixed(3)}');
          debugPrint(
            '    Recency penalty: ${lastUsedPenalty.toStringAsFixed(3)}',
          );
          debugPrint('    Final score: ${adjustedScore.toStringAsFixed(3)}');
          debugPrint('    Threshold: $_matchScoreThreshold');
          debugPrint(
            '    Result: ${adjustedScore >= _matchScoreThreshold ? "✓ MATCHED" : "✗ BELOW THRESHOLD"}',
          );

          return {'pattern': pattern, 'score': adjustedScore};
        })
        .where((result) => result['score'] as double >= _matchScoreThreshold)
        .toList();

    if (matchedPatterns.isEmpty) {
      debugPrint(
        '[MATCHING] No patterns matched (all scores < $_matchScoreThreshold)',
      );
      return [];
    }

    debugPrint(
      '[MATCHING] ${matchedPatterns.length} pattern(s) matched threshold',
    );
    matchedPatterns.sort((a, b) {
      final scoreA = a['score'] as double;
      final scoreB = b['score'] as double;
      return scoreB.compareTo(scoreA);
    });

    debugPrint('[MATCHING] Sorted patterns by score:');
    for (int i = 0; i < matchedPatterns.length; i++) {
      final result = matchedPatterns[i];
      final pattern = result['pattern'] as SMSParsingPattern;
      final score = result['score'] as double;
      debugPrint(
        '  ${i + 1}. ${pattern.patternName}: ${score.toStringAsFixed(3)}',
      );
    }

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

    debugPrint('      Word comparison (${messageWords.length} words):');

    if (structureParts.length != messageWords.length) {
      final lengthDiff = (structureParts.length - messageWords.length).abs();
      debugPrint(
        '        ⚠ Length mismatch: Pattern has ${structureParts.length} parts, Message has ${messageWords.length} words',
      );
      debugPrint('        Length penalty: ${lengthDiff * 0.1}');
      final score = 1.0 - (lengthDiff * 0.1);
      debugPrint('        Score with penalty: ${score.toStringAsFixed(3)}');
      return score;
    }

    int matches = 0;
    debugPrint('        Comparing word by word:');
    for (int i = 0; i < messageWords.length && i < structureParts.length; i++) {
      final messageWord = messageWords[i].toLowerCase();
      final structurePart = structureParts[i].toLowerCase();

      final isMatch =
          structurePart == messageWord ||
          structurePart == '[text]' ||
          structurePart == '[number]';

      final matchSymbol = isMatch ? '✓' : '✗';
      final messagePreview = messageWord.length > 15
          ? '${messageWord.substring(0, 15)}...'
          : messageWord;

      debugPrint(
        '          [$i] $matchSymbol Pattern: "$structurePart" | Message: "$messagePreview"',
      );

      if (isMatch) {
        matches++;
      }
    }

    final score = matches / messageWords.length;
    debugPrint('        Matches: $matches/${messageWords.length} words');
    debugPrint(
      '        Match percentage: ${(score * 100).toStringAsFixed(1)}%',
    );
    debugPrint('        Final match score: ${score.toStringAsFixed(3)}');

    return score;
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
    debugPrint(
      '[EXTRACTION] Extracting fields using pattern: ${pattern.patternName}',
    );

    final words = message.split(' ');
    debugPrint('[EXTRACTION] Message has ${words.length} words');

    final amount = _extractAmount(words, pattern.amountPattern);
    debugPrint('[EXTRACTION] Amount result: "$amount"');

    final counterparty = _extractCounterparty(
      words,
      pattern.counterpartyPattern,
    );
    debugPrint('[EXTRACTION] Counterparty result: "$counterparty"');

    final reference = pattern.referencePattern != null
        ? _extractReference(words, pattern.referencePattern!)
        : null;
    debugPrint(
      '[EXTRACTION] Reference result: "${reference ?? "NULL (not set in pattern)"}"',
    );

    debugPrint(
      '[EXTRACTION] Final extracted fields: {amount: $amount, counterparty: $counterparty, reference: $reference}',
    );

    return {
      'amount': amount,
      'counterparty': counterparty,
      'reference': reference,
    };
  }

  String _extractAmount(List<String> words, String pattern) {
    debugPrint('[EXTRACTION] Extracting amount with pattern: "$pattern"');
    final indices = pattern.split(',').map(int.parse).toList();

    if (indices.isEmpty || indices[0] >= words.length) {
      debugPrint('[EXTRACTION] ⚠ Amount extraction failed: Invalid index');
      return '';
    }

    final index = indices[0];
    final rawWord = words[index];
    debugPrint('[EXTRACTION]   Word at index $index: "$rawWord"');

    var amount = rawWord.replaceAll(RegExp(r'[^\d.]'), '');
    amount = amount.replaceAll(RegExp(r'^\.+|\.$'), '');

    debugPrint('[EXTRACTION]   Cleaned amount: "$amount"');

    return amount;
  }

  String _extractCounterparty(List<String> words, String pattern) {
    debugPrint('[EXTRACTION] Extracting counterparty with pattern: "$pattern"');
    final indices = pattern.split(',').map(int.parse).toList();

    if (indices.isEmpty) {
      debugPrint('[EXTRACTION] ⚠ Counterparty extraction failed: No indices');
      return '';
    }

    debugPrint('[EXTRACTION]   Counterparty indices: $indices');

    final counterpartyWords = indices
        .where((i) => i < words.length)
        .map((i) => words[i])
        .toList();

    final result = counterpartyWords.join(' ');
    debugPrint('[EXTRACTION]   Counterparty words: $counterpartyWords');
    debugPrint('[EXTRACTION]   Final counterparty: "$result"');

    return result;
  }

  String _extractReference(List<String> words, String pattern) {
    debugPrint('[EXTRACTION] Extracting reference with pattern: "$pattern"');
    final indices = pattern.split(',').map(int.parse).toList();

    if (indices.isEmpty || indices[0] >= words.length) {
      debugPrint('[EXTRACTION] ⚠ Reference extraction failed: Invalid index');
      return '';
    }

    final index = indices[0];
    final word = words[index];
    debugPrint('[EXTRACTION]   Word at index $index: "$word"');

    return word;
  }

  String buildMessageStructure(String message) {
    final words = message.split(' ');

    debugPrint(
      '[STRUCTURE] Building message structure from ${words.length} words',
    );

    final structure = words
        .asMap()
        .entries
        .map((entry) {
          final index = entry.key;
          final word = entry.value;

          String structurePart;
          if (_isNumeric(word)) {
            structurePart = '[NUMBER]';
          } else if (word.length <= 3) {
            structurePart = '[TEXT]';
          } else {
            structurePart = word.toUpperCase();
          }

          final preview = word.length > 12
              ? '${word.substring(0, 12)}...'
              : word;
          debugPrint('  [$index] "$preview" → $structurePart');

          return structurePart;
        })
        .join(',');

    debugPrint('[STRUCTURE] Final structure: $structure');

    return structure;
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
