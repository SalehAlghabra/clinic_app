import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../bloc/doctor_detail_bloc.dart';
import '../bloc/doctor_detail_event.dart';
import '../bloc/doctor_detail_state.dart';
import '../models/doctor_model.dart';
import '../models/schedule_model.dart';
import '../models/service_model.dart';

class DoctorDetailScreen extends StatefulWidget {
  final int doctorId;

  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<DoctorDetailBloc>()
        .add(FetchDoctorDetailRequested(widget.doctorId));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.doctorsTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<DoctorDetailBloc, DoctorDetailState>(
        builder: (context, state) {
          if (state is DoctorDetailLoading) {
            return const Center(child: AppLoadingIndicator());
          } else if (state is DoctorDetailFailure) {
            return AppErrorWidget(
              errorMessage: state.errorMessage,
              onRetry: () => context
                  .read<DoctorDetailBloc>()
                  .add(FetchDoctorDetailRequested(widget.doctorId)),
            );
          } else if (state is DoctorDetailSuccess) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Header Info
                        _buildDoctorHeader(context, state.doctor),

                        const SizedBox(height: AppDimensions.paddingL),

                        // Services
                        Text(
                          l10n.medicalRecordsTitle, // Placeholder for Service
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 8),
                        if (state.services.isEmpty)
                          Text(
                            'No services registered for this doctor.',
                            style: TextStyle(color: colors.textSecondary),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.services.length,
                            itemBuilder: (context, index) {
                              final service = state.services[index];
                              return _buildServiceItem(context, service)
                                  .animate()
                                  .fadeIn(delay: (250 + index * 50).ms);
                            },
                          ),

                        const SizedBox(height: AppDimensions.paddingL),

                        // Schedules
                        Text(
                          l10n.appointmentsTitle, // Placeholder for Work Days
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ).animate().fadeIn(delay: 400.ms),
                        const SizedBox(height: 8),
                        if (state.schedules.isEmpty)
                          Text(
                            'No work schedule available.',
                            style: TextStyle(color: colors.textSecondary),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.schedules.length,
                            itemBuilder: (context, index) {
                              final schedule = state.schedules[index];
                              return _buildScheduleItem(context, schedule)
                                  .animate()
                                  .fadeIn(delay: (450 + index * 50).ms);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // CTA Button Container
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(top: BorderSide(color: colors.border)),
                  ),
                  child: AppButton(
                    text: l10n.bookAppointment,
                    onPressed: () {
                      // Handled in booking phase (Phase 4)
                    },
                  ),
                ).animate().slideY(begin: 0.2, duration: 400.ms),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDoctorHeader(BuildContext context, DoctorModel doctor) {
    final colors = context.appColors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.person_rounded, color: colors.primary, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        doctor.specialization,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
            Text(
              doctor.bio!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.text,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Icon(Icons.email_outlined, size: 16, color: colors.textSecondary),
              const SizedBox(width: 8),
              Text(
                doctor.email,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone_enabled_outlined, size: 16, color: colors.textSecondary),
              const SizedBox(width: 8),
              Text(
                doctor.phone ?? 'No phone number',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildServiceItem(BuildContext context, ServiceModel service) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              service.serviceName,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            Text(
              '${service.price.toStringAsFixed(2)} SP',
              style: context.textTheme.titleMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, ScheduleModel schedule) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              schedule.dayOfWeek.toUpperCase(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 16, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '${DateFormatters.formatTime(schedule.startTime)} - ${DateFormatters.formatTime(schedule.endTime)}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
