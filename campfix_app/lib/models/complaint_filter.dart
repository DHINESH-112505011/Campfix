class ComplaintFilter {
  final String? search;
  final String? status;
  final String? priority;
  final String? categoryId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ComplaintFilter({
    this.search,
    this.status,
    this.priority,
    this.categoryId,
    this.dateFrom,
    this.dateTo,
  });

  bool get isEmpty =>
      search == null &&
      status == null &&
      priority == null &&
      categoryId == null &&
      dateFrom == null &&
      dateTo == null;

  int get activeCount {
    var count = 0;
    if (status != null) count++;
    if (priority != null) count++;
    if (categoryId != null) count++;
    if (dateFrom != null || dateTo != null) count++;
    return count;
  }

  ComplaintFilter copyWith({
    String? search,
    String? status,
    String? priority,
    String? categoryId,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearStatus = false,
    bool clearPriority = false,
    bool clearCategory = false,
    bool clearDates = false,
  }) {
    return ComplaintFilter(
      search: search ?? this.search,
      status: clearStatus ? null : (status ?? this.status),
      priority: clearPriority ? null : (priority ?? this.priority),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      dateFrom: clearDates ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDates ? null : (dateTo ?? this.dateTo),
    );
  }

  Map<String, dynamic> toQuery() {
    return {
      if (search != null && search!.isNotEmpty) 'search': search,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (categoryId != null) 'categoryId': categoryId,
      if (dateFrom != null) 'dateFrom': dateFrom!.toIso8601String(),
      if (dateTo != null) 'dateTo': dateTo!.toIso8601String(),
    };
  }
}