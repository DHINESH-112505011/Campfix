import 'dart:io';

/// Mutable in-progress complaint being built across the 4-step wizard.
/// Not submitted until the final Review & Submit step.
class ComplaintDraft {
  String? categoryId;
  String? categoryName;
  String title;
  String description;

  String campus;
  String building;
  String block;
  String floor;
  String room;
  String specificLocation;

  File? imageFile;

  // Simulated AI output, filled in during Review step (real AI in Phase 15)
  String? aiCategory;
  String? aiPriority;
  double? aiConfidence;

  ComplaintDraft({
    this.categoryId,
    this.categoryName,
    this.title = '',
    this.description = '',
    this.campus = 'Main Campus',
    this.building = '',
    this.block = '',
    this.floor = '',
    this.room = '',
    this.specificLocation = '',
    this.imageFile,
    this.aiCategory,
    this.aiPriority,
    this.aiConfidence,
  });

  bool get isStep1Valid =>
      categoryId != null && title.trim().isNotEmpty && description.trim().isNotEmpty;

  bool get isStep2Valid => building.trim().isNotEmpty && room.trim().isNotEmpty;
}