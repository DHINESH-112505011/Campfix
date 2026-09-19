import 'package:flutter/material.dart';
import '../../../models/complaint_draft.dart';
import '../../../repositories/complaint_repository.dart';
import 'report_step1_screen.dart';
import 'report_step2_screen.dart';
import 'report_step3_screen.dart';
import 'report_step4_screen.dart';
import 'report_success_screen.dart';

/// Hosts the 4-step complaint wizard. Manages the shared ComplaintDraft
/// and step navigation. Each step screen only knows about the draft and
/// simple onNext/onBack callbacks - it has no knowledge of the other steps.
class ReportWizardScreen extends StatefulWidget {
  final String? initialCategoryId;

  const ReportWizardScreen({super.key, this.initialCategoryId});

  @override
  State<ReportWizardScreen> createState() => _ReportWizardScreenState();
}

class _ReportWizardScreenState extends State<ReportWizardScreen> {
  final ComplaintRepository _repository = ComplaintRepository();
  late final ComplaintDraft _draft;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _draft = ComplaintDraft(categoryId: widget.initialCategoryId);
  }

  void _goToStep(int step) => setState(() => _currentStep = step);

  Future<void> _handleSubmit() async {
    final complaintNumber = await _repository.submitComplaint(_draft);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ReportSuccessScreen(complaintNumber: complaintNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return ReportStep1Screen(
          draft: _draft,
          onNext: () => _goToStep(1),
        );
      case 1:
        return ReportStep2Screen(
          draft: _draft,
          onNext: () => _goToStep(2),
          onBack: () => _goToStep(0),
        );
      case 2:
        return ReportStep3Screen(
          draft: _draft,
          onNext: () => _goToStep(3),
          onBack: () => _goToStep(1),
        );
      case 3:
      default:
        return ReportStep4Screen(
          draft: _draft,
          onBack: () => _goToStep(2),
          onSubmit: _handleSubmit,
        );
    }
  }
}