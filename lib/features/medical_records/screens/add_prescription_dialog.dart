import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../bloc/medical_records_bloc.dart';
import '../bloc/medical_records_event.dart';

class AddPrescriptionDialog extends StatefulWidget {
  final int recordId;

  const AddPrescriptionDialog({super.key, required this.recordId});

  @override
  State<AddPrescriptionDialog> createState() => _AddPrescriptionDialogState();
}

class _AddPrescriptionDialogState extends State<AddPrescriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _medNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void dispose() {
    _medNameController.dispose();
    _dosageController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<MedicalRecordsBloc>().add(
            AddPrescriptionEvent(
              recordId: widget.recordId,
              medicationName: _medNameController.text.trim(),
              dosage: _dosageController.text.trim(),
              duration: _durationController.text.trim(),
              instructions: _instructionsController.text.trim(),
            ),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colors.surface,
      insetPadding: const EdgeInsets.all(24),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.addPrescription,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Medication Name field
                AppTextField(
                  labelText: '${l10n.medicationName} *',
                  controller: _medNameController,
                  hintText: 'e.g. Amoxicillin 500mg',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.validatorMedicationNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),

                // Dosage field
                AppTextField(
                  labelText: '${l10n.dosage} *',
                  controller: _dosageController,
                  hintText: 'e.g. One tablet twice daily',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.validatorDosageRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),

                // Duration field
                AppTextField(
                  labelText: '${l10n.duration} *',
                  controller: _durationController,
                  hintText: 'e.g. 7 Days',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return l10n.validatorDurationRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),

                // Instructions field
                AppTextField(
                  labelText: l10n.instructions,
                  controller: _instructionsController,
                  hintText: 'e.g. Take with food / before sleep...',
                  maxLines: 2,
                  validator: null,
                ),
                const SizedBox(height: AppDimensions.paddingL),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: l10n.cancel,
                        isOutline: true,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: l10n.save,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
