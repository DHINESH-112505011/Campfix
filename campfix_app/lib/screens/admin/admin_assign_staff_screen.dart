import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/errors/app_exception.dart';
import '../../models/complaint.dart';
import '../../models/staff_member.dart';
import '../../repositories/staff_repository.dart';
import '../../repositories/assignment_repository.dart';
import '../../widgets/campfix_staff_picker_tile.dart';
import '../../widgets/campfix_button.dart';
import '../../widgets/campfix_text_field.dart';

class AdminAssignStaffScreen extends StatefulWidget {
  final Complaint complaint;
  final bool isReassign;

  const AdminAssignStaffScreen({
    super.key,
    required this.complaint,
    this.isReassign = false,
  });

  @override
  State<AdminAssignStaffScreen> createState() => _AdminAssignStaffScreenState();
}

class _AdminAssignStaffScreenState extends State<AdminAssignStaffScreen> {
  final StaffRepository _staffRepository = StaffRepository();
  final AssignmentRepository _assignmentRepository = AssignmentRepository();
  final TextEditingController _notesController = TextEditingController();

  late Future<List<StaffMember>> _staffFuture;
  String? _selectedStaffId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _staffFuture = _staffRepository.getAvailableStaff();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleAssign() async {
    if (_selectedStaffId == null) return;

    setState(() => _isSubmitting = true);
    try {
      if (widget.isReassign) {
        await _assignmentRepository.reassignStaff(
          complaintId: widget.complaint.id,
          newStaffId: _selectedStaffId!,
          notes: _notesController.text.trim(),
        );
      } else {
        await _assignmentRepository.assignStaff(
          complaintId: widget.complaint.id,
          staffId: _selectedStaffId!,
          notes: _notesController.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isReassign ? 'Reassign Staff' : 'Assign Staff'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.complaint.complaintNumber, style: textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(widget.complaint.title, style: textTheme.titleMedium),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<List<StaffMember>>(
                future: _staffFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final staffList = snapshot.data!;
                  if (staffList.isEmpty) {
                    return Center(
                      child: Text('No available staff found.', style: textTheme.bodyMedium),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: staffList.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final staff = staffList[index];
                      return CampFixStaffPickerTile(
                        staff: staff,
                        isSelected: staff.id == _selectedStaffId,
                        onTap: () => setState(() => _selectedStaffId = staff.id),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  CampFixTextField(
                    label: 'Notes (optional)',
                    hint: 'Any special instructions...',
                    controller: _notesController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  CampFixButton(
                    label: widget.isReassign ? 'Reassign' : 'Assign',
                    isLoading: _isSubmitting,
                    onPressed: _selectedStaffId == null ? null : _handleAssign,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}