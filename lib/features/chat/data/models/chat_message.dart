import 'dart:convert';

enum MessageStatus { sending, delivered, error }

enum MessageSender { user, bot }

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final MessageStatus status;
  final double? responseTimeSeconds;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.status = MessageStatus.delivered,
    this.responseTimeSeconds,
  });

  ChatMessage copyWith({
    String? text,
    MessageStatus? status,
    double? responseTimeSeconds,
  }) {
    return ChatMessage(
      id: id,
      text: text ?? this.text,
      sender: sender,
      timestamp: timestamp,
      status: status ?? this.status,
      responseTimeSeconds: responseTimeSeconds ?? this.responseTimeSeconds,
    );
  }

  // ---- Serialisation ----
  // Error messages are intentionally not persisted — they are transient
  // states tied to a specific session. On reload they would be confusing
  // ("Unable to connect" from a previous session is no longer relevant).
  // We store them in the list normally but mark them on deserialisation
  // so _loadMessages() can filter them out.

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
      'sender': sender.name,           // stores "user" or "bot"
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,           // stores "delivered", "error", etc.
      'responseTimeSeconds': responseTimeSeconds,
    };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        text: json['text'] as String,
        sender: MessageSender.values.byName(json['sender'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: MessageStatus.values.byName(json['status'] as String),
        responseTimeSeconds: (json['responseTimeSeconds'] as num?)?.toDouble(),
      );

  /// Convenience: encode a list of messages to a JSON string for storage.
  static String encodeList(List<ChatMessage> messages) =>
      jsonEncode(messages.map((m) => m.toJson()).toList());

  /// Convenience: decode a JSON string back into a list of messages.
  static List<ChatMessage> decodeList(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
