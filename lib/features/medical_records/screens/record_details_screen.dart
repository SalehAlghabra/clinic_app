import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/dialogs/app_dialogs.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../bloc/medical_records_bloc.dart';
import '../bloc/medical_records_event.dart';
import '../bloc/medical_records_state.dart';
import '../models/medical_record_model.dart';
import 'add_prescription_dialog.dart';

class RecordDetailsScreen extends StatefulWidget {
  final int recordId;

  const RecordDetailsScreen({super.key, required this.recordId});

  @override
  State<RecordDetailsScreen> createState() => _RecordDetailsScreenState();
}

class _RecordDetailsScreenState extends State<RecordDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecordDetails();
  }

  void _loadRecordDetails() {
    context.read<MedicalRecordsBloc>().add(FetchMedicalRecordDetailsEvent(widget.recordId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    // Identify if the logged-in user is a doctor
    final authState = context.read<AuthBloc>().state;
    final isDoctor = authState is AuthAuthenticated && authState.user.role == 'doctor';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.medicalRecordsTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<MedicalRecordsBloc, MedicalRecordsState>(
        listener: (context, state) {
          if (state is AddPrescriptionSuccess) {
            AppDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: l10n.prescriptionAddedSuccess,
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
          // If in progress but we already have details loaded, show loading overlay instead of full spinner
          final inProgress = state is MedicalRecordsActionInProgress;

          if (state is MedicalRecordsLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is MedicalRecordsFailure && state is! MedicalRecordDetailsLoadSuccess) {
            return AppErrorWidget(
              errorMessage: state.errorMessage,
              onRetry: _loadRecordDetails,
            );
          }

          MedicalRecordModel? record;
          if (state is MedicalRecordDetailsLoadSuccess) {
            record = state.record;
          } else {
            // Fallback to bloc state if temporarily in action-in-progress state
            final bloc = context.read<MedicalRecordsBloc>();
            if (bloc.state is MedicalRecordDetailsLoadSuccess) {
              record = (bloc.state as MedicalRecordDetailsLoadSuccess).record;
            }
          }

          if (record == null) {
            return const Center(child: AppLoadingIndicator());
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Visit Header Card
                    _buildHeaderCard(context, record),
                    const SizedBox(height: AppDimensions.paddingM),

                    // Symptoms Section
                    if (record.symptoms != null && record.symptoms!.isNotEmpty) ...[
                      _buildSectionTitle(context, l10n.symptoms, Icons.sick_outlined),
                      const SizedBox(height: AppDimensions.paddingS),
                      AppCard(
                        child: Text(
                          record.symptoms!,
                          style: context.textTheme.bodyMedium?.copyWith(color: colors.text),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                    ],

                    // Diagnosis Section
                    if (record.diagnosis != null && record.diagnosis!.isNotEmpty) ...[
                      _buildSectionTitle(context, l10n.diagnosis, Icons.assignment_outlined),
                      const SizedBox(height: AppDimensions.paddingS),
                      AppCard(
                        child: Text(
                          record.diagnosis!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.text,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                    ],

                    // Doctor Notes Section
                    if (record.doctorNotes != null && record.doctorNotes!.isNotEmpty) ...[
                      _buildSectionTitle(context, l10n.doctorNotes, Icons.notes_rounded),
                      const SizedBox(height: AppDimensions.paddingS),
                      AppCard(
                        child: Text(
                          record.doctorNotes!,
                          style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                    ],

                    // Prescriptions Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle(context, l10n.prescriptions, Icons.medication_outlined),
                        if (isDoctor)
                          TextButton.icon(
                            icon: Icon(Icons.add_rounded, size: 18, color: colors.primary),
                            label: Text(
                              l10n.addPrescription,
                              style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _showAddPrescriptionDialog(context, record!.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingS),

                    if (record.prescriptions.isEmpty)
                      AppEmptyState(
                        icon: Icons.medication_liquid_rounded,
                        title: 'No Medications Prescribed',
                        description: 'No drug dosage forms are currently attached to this checkup sheet.',
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: record.prescriptions.length,
                        itemBuilder: (context, index) {
                          final p = record!.prescriptions[index];
                          return _buildPrescriptionCard(context, p)
                              .animate()
                              .fadeIn(delay: (index * 50).ms)
                              .slideX(begin: 0.05);
                        },
                      ),
                  ],
                ),
              ),
              if (inProgress)
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

  Widget _buildSectionTitle(BuildContext context, String text, IconData icon) {
    final colors = context.appColors;
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(BuildContext context, MedicalRecordModel record) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return AppCard(
      color: colors.primary.withValues(alpha: 0.05),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.visitDate}:',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              Text(
                DateFormatters.formatDateString(record.visitDate),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildHeaderRow(
            context,
            Icons.medical_services_outlined,
            'Doctor:',
            'Dr. ${record.doctorName}',
          ),
          if (record.patientName != null && record.patientName!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildHeaderRow(
              context,
              Icons.person_outline_rounded,
              'Patient:',
              record.patientName!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, IconData icon, String label, String value) {
    final colors = context.appColors;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.text,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, dynamic p) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.medicationName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.duration,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.loop_rounded, size: 14, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${l10n.dosage}: ${p.dosage}',
                  style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
            if (p.instructions != null && p.instructions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: colors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p.instructions!,
                      style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddPrescriptionDialog(BuildContext context, int recordId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<MedicalRecordsBloc>(),
        child: AddPrescriptionDialog(recordId: recordId),
      ),
    );
  }
}
