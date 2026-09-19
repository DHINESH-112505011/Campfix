import '../models/complaint.dart';
import '../models/complaint_draft.dart';

/// Provides complaint data to the UI. Currently returns realistic mock
/// data so Phase 4/5 UI can be fully built and tested. Phase 8 will
/// replace the method bodies with real API calls - the method signatures
/// below are designed to stay stable so screens never need to change.
class ComplaintRepository {
  static final List<Complaint> _mockComplaints = [
    Complaint(
      id: '1',
      complaintNumber: 'CF-2026-00025',
      title: 'Classroom Fan Not Working',
      description: 'The ceiling fan in Room 204 has stopped working.',
      category: 'Electrical',
      priority: 'HIGH',
      status: 'IN_PROGRESS',
      building: 'Main Block',
      room: 'Room 204',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    Complaint(
      id: '2',
      complaintNumber: 'CF-2026-00024',
      title: 'Water Leakage Near Washroom',
      description: 'Water is leaking near the hostel washroom entrance.',
      category: 'Civil',
      priority: 'CRITICAL',
      status: 'ASSIGNED',
      building: 'Hostel Block B',
      room: 'Ground Floor',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Complaint(
      id: '3',
      complaintNumber: 'CF-2026-00018',
      title: 'Broken Chair in Seminar Hall',
      description: 'One chair has a broken leg near the front row.',
      category: 'Furniture',
      priority: 'LOW',
      status: 'RESOLVED',
      building: 'Seminar Hall',
      room: 'Front Row',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  Future<List<Complaint>> getMyComplaints() async {
    await Future.delayed(const Duration(milliseconds: 400)); // simulate network
    return _mockComplaints;
  }

  Future<({int total, int active, int resolved})> getMyStats() async {
    final complaints = await getMyComplaints();
    final total = complaints.length;
    final resolved = complaints.where((c) => c.isResolved).length;
    final active = complaints.where((c) => c.isActive).length;
    return (total: total, active: active, resolved: resolved);
  }

  /// Simulates submission and generates a mock complaint number.
  /// Phase 8 will replace this with a real POST /api/complaints call,
  /// and Phase 9 will add the actual Cloudinary image upload step here.
  Future<String> submitComplaint(ComplaintDraft draft) async {
    await Future.delayed(const Duration(milliseconds: 900)); // simulate network
    final year = DateTime.now().year;
    final sequence = (_mockComplaints.length + 1).toString().padLeft(5, '0');
    final complaintNumber = 'CF-$year-$sequence';

    _mockComplaints.insert(
      0,
      Complaint(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        complaintNumber: complaintNumber,
        title: draft.title,
        description: draft.description,
        category: draft.categoryName ?? 'Other',
        priority: draft.aiPriority ?? 'MEDIUM',
        status: 'SUBMITTED',
        building: draft.building,
        room: draft.room,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return complaintNumber;
  }
}