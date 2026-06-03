
class ApiResponse {
  final String answer;
  final String? intent;
  final String? updatedSummary;
  final double? responseTimeSeconds;

  ApiResponse({
    required this.answer,
    this.intent,
    this.updatedSummary,
    this.responseTimeSeconds,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      answer: json['answer'] ?? '',
      intent: json['intent'],
      updatedSummary: json['updated_summary'],
      responseTimeSeconds: (json['response_time_s'] as num?)?.toDouble(),
    );
  }
}
