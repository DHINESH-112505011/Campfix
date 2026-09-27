class ComplaintFeedback {
  final String id;
  final String complaintId;
  final int rating;
  final bool resolvedSuccessfully;
  final String? comment;
  final DateTime createdAt;

  ComplaintFeedback({
    required this.id,
    required this.complaintId,
    required this.rating,
    required this.resolvedSuccessfully,
    this.comment,
    required this.createdAt,
  });

  factory ComplaintFeedback.fromJson(Map<String, dynamic> json) {
    return ComplaintFeedback(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      rating: json['rating'] as int,
      resolvedSuccessfully: json['resolved_successfully'] as bool,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}