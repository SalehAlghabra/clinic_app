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
import '../bloc/medical_records_bloc.dart';
import '../bloc/medical_records_event.dart';
import '../bloc/medical_records_state.dart';
import '../models/medical_record_model.dart';

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    context.read<MedicalRecordsBloc>().add(const FetchPatientMedicalRecordsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.medicalHistory,
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
      body: BlocBuilder<MedicalRecordsBloc, MedicalRecordsState>(
        builder: (context, state) {
          if (state is MedicalRecordsLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is MedicalRecordsFailure) {
            return AppErrorWidget(
              errorMessage: state.errorMessage,
              onRetry: _loadRecords,
            );
          }

          if (state is PatientMedicalRecordsLoadSuccess) {
            final records = state.records;

            if (records.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => _loadRecords(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    AppEmptyState(
                      icon: Icons.assignment_outlined,
                      title: l10n.noMedicalRecords,
                      description: 'No medical checkup sheets or records exist on your file.',
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadRecords(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return _buildRecordCard(context, record)
                      .animate()
                      .fadeIn(delay: (index * 50).ms)
                      .slideY(begin: 0.05);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRecordCard(BuildContext context, MedicalRecordModel record) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        onTap: () => context.push('/patient/records/${record.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatters.formatDateString(record.visitDate),
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Dr. ${record.doctorName}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
            if (record.diagnosis != null && record.diagnosis!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.diagnosis}: ',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      record.diagnosis!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (record.prescriptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.medication_liquid_rounded, size: 12, color: colors.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${record.prescriptions.length} Meds',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}
