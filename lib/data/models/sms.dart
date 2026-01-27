class SMSMessage {
  final int id;
  final String sender;
  final String message;
  final int timestamp;
  final bool processed;

  SMSMessage({
    required this.id,
    required this.sender,
    required this.message,
    required this.timestamp,
    this.processed = false,
  });

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  SMSMessage copyWith({
    int? id,
    String? sender,
    String? message,
    int? timestamp,
    bool? processed,
  }) {
    return SMSMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      processed: processed ?? this.processed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender,
      'message': message,
      'timestamp': timestamp,
      'processed': processed ? 1 : 0,
    };
  }

  factory SMSMessage.fromMap(Map<String, dynamic> map) {
    return SMSMessage(
      id: map['id'] as int,
      sender: map['sender'] as String,
      message: map['message'] as String,
      timestamp: map['timestamp'] as int,
      processed: (map['processed'] as int?) == 1,
    );
  }
}
