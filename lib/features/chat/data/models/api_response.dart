
class ApiResponse {
  final String answer;
  final String? intent;
  final String? updatedSummary;

  ApiResponse({
    required this.answer,
    this.intent,
    this.updatedSummary,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      answer: json['answer'] ?? '',
      intent: json['intent'],
      updatedSummary: json['updated_summary']
    );
  }
}