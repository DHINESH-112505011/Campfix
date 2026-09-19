import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/complaint_draft.dart';
import '../../../widgets/campfix_text_field.dart';
import '../../../widgets/campfix_button.dart';
import '../../../widgets/campfix_outlined_button.dart';
import '../../../widgets/campfix_step_progress.dart';

class ReportStep2Screen extends StatefulWidget {
  final ComplaintDraft draft;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ReportStep2Screen({
    super.key,
    required this.draft,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ReportStep2Screen> createState() => _ReportStep2ScreenState();
}

class _ReportStep2ScreenState extends State<ReportStep2Screen> {
  late final TextEditingController _buildingController;
  late final TextEditingController _blockController;
  late final TextEditingController _floorController;
  late final TextEditingController _roomController;
  late final TextEditingController _specificController;

  @override
  void initState() {
    super.initState();
    _buildingController = TextEditingController(text: widget.draft.building);
    _blockController = TextEditingController(text: widget.draft.block);
    _floorController = TextEditingController(text: widget.draft.floor);
    _roomController = TextEditingController(text: widget.draft.room);
    _specificController = TextEditingController(text: widget.draft.specificLocation);

    for (final c in [_buildingController, _roomController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _blockController.dispose();
    _floorController.dispose();
    _roomController.dispose();
    _specificController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _buildingController.text.trim().isNotEmpty && _roomController.text.trim().isNotEmpty;

  void _handleNext() {
    widget.draft
      ..building = _buildingController.text.trim()
      ..block = _blockController.text.trim()
      ..floor = _floorController.text.trim()
      ..room = _roomController.text.trim()
      ..specificLocation = _specificController.text.trim();
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Problem'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: widget.onBack,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CampFixStepProgress(currentStep: 1, totalSteps: 4),
              const SizedBox(height: AppSpacing.xl),
              Text('Where is the problem?', style: textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xs),
              Text('Help us find it quickly.', style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: ListView(
                  children: [
                    CampFixTextField(
                      label: 'Building *',
                      hint: 'e.g. Main Block',
                      controller: _buildingController,
                      prefixIcon: Icons.apartment_rounded,
                      validator: (_) => null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: CampFixTextField(
                            label: 'Block',
                            hint: 'e.g. A',
                            controller: _blockController,
                            validator: (_) => null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: CampFixTextField(
                            label: 'Floor',
                            hint: 'e.g. 2nd',
                            controller: _floorController,
                            validator: (_) => null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CampFixTextField(
                      label: 'Room *',
                      hint: 'e.g. Room 204',
                      controller: _roomController,
                      prefixIcon: Icons.meeting_room_rounded,
                      validator: (_) => null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CampFixTextField(
                      label: 'Specific Location (optional)',
                      hint: 'e.g. Near the window',
                      controller: _specificController,
                      validator: (_) => null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CampFixOutlinedButton(
                      label: 'Use Current Location',
                      icon: Icons.my_location_rounded,
                      onPressed: () {
                        // GPS is optional per project rules - wired to a real
                        // location service only if the user opts in. Stubbed here.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location services coming in a later phase')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CampFixButton(
                label: 'Next',
                onPressed: _canContinue ? _handleNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}