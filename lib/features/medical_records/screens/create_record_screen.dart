import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/dialogs/app_dialogs.dart';
import '../bloc/medical_records_bloc.dart';
import '../bloc/medical_records_event.dart';
import '../bloc/medical_records_state.dart';

class CreateRecordScreen extends StatefulWidget {
  final int appointmentId;
  final String patientName;

  const CreateRecordScreen({
    super.key,
    required this.appointmentId,
    required this.patientName,
  });

  @override
  State<CreateRecordScreen> createState() => _CreateRecordScreenState();
}

class _CreateRecordScreenState extends State<CreateRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MedicalRecordsBloc>().add(
            CreateMedicalRecordEvent(
              appointmentId: widget.appointmentId,
              symptoms: _symptomsController.text.trim(),
              diagnosis: _diagnosisController.text.trim(),
              doctorNotes: _notesController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.createMedicalRecord,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: colors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<MedicalRecordsBloc, MedicalRecordsState>(
        listener: (context, state) {
          if (state is CreateMedicalRecordSuccess) {
            AppDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: l10n.recordCreatedSuccess,
              onPressed: () {
                // Navigate to the newly created record details to allow adding prescriptions
                context.pushReplacement('/medical-records/${state.record.id}');
              },
            );
          } else if (state is MedicalRecordsFailure) {
            AppDialogs.showError(
              context: context,
              title: l10n.error,
              message: state.errorMessage,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is MedicalRecordsActionInProgress;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Info header
                      AppCard(
                        color: colors.primary.withValues(alpha: 0.05),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded, color: colors.primary, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.patientName,
                                    style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                                  ),
                                  Text(
                                    widget.patientName,
                                    style: context.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingL),

                      // Symptoms text input
                      AppTextField(
                        labelText: l10n.symptoms,
                        controller: _symptomsController,
                        hintText: 'Enter symptoms reported by the patient...',
                        maxLines: 3,
                        validator: null, // Optional field
                      ),
                      const SizedBox(height: AppDimensions.paddingM),

                      // Diagnosis text input
                      AppTextField(
                        labelText: '${l10n.diagnosis} *',
                        controller: _diagnosisController,
                        hintText: 'Enter medical diagnosis here...',
                        maxLines: 3,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Diagnosis is required to create a medical record.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppDimensions.paddingM),

                      // Notes text input
                      AppTextField(
                        labelText: l10n.doctorNotes,
                        controller: _notesController,
                        hintText: 'Enter additional clinical notes (optional)...',
                        maxLines: 4,
                        validator: null,
                      ),
                      const SizedBox(height: AppDimensions.paddingXL),

                      // Submit button
                      AppButton(
                        text: l10n.createMedicalRecord,
                        onPressed: isLoading ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(child: AppLoadingIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
