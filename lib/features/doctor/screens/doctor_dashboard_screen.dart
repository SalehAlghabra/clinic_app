import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/dialogs/app_dialogs.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../bloc/doctor_appointments_bloc.dart';
import '../bloc/doctor_appointments_event.dart';
import '../bloc/doctor_appointments_state.dart';
import '../models/doctor_appointment_model.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

import '../../../shared/widgets/app_top_actions.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DoctorAppointmentsBloc>().add(const FetchDoctorAppointmentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final name = authState is AuthAuthenticated ? authState.user.name : '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                Text(
                  'Have a great day at clinic!',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          AppTopActions(),
          SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<DoctorAppointmentsBloc, DoctorAppointmentsState>(
        listener: (context, state) {
          if (state is DoctorAppointmentActionSuccess) {
            AppDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: state.message,
              onPressed: _loadData,
            );
          } else if (state is DoctorAppointmentsFailure) {
            AppDialogs.showError(
              context: context,
              title: l10n.error,
              message: state.errorMessage,
            );
          }
        },
        builder: (context, state) {
          if (state is DoctorAppointmentsLoading && state is! DoctorAppointmentActionInProgress) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is DoctorAppointmentsFailure && state is! DoctorAppointmentsLoadSuccess) {
            return AppErrorWidget(
              errorMessage: state.errorMessage,
              onRetry: _loadData,
            );
          }

          List<DoctorAppointmentModel> appointments = [];
          if (state is DoctorAppointmentsLoadSuccess) {
            appointments = state.appointments;
          } else {
            final bloc = context.read<DoctorAppointmentsBloc>();
            if (bloc.state is DoctorAppointmentsLoadSuccess) {
              appointments = (bloc.state as DoctorAppointmentsLoadSuccess).appointments;
            }
          }

          final pendingCount = appointments.where((e) => e.status == 'pending').length;
          final confirmedCount = appointments.where((e) => e.status == 'confirmed').length;
          final completedCount = appointments.where((e) => e.status == 'completed').length;

          // Today's appointments (with flexible date parsing)
          final now = DateTime.now();
          final todayStr = DateFormat('yyyy-MM-dd').format(now);
          final todayAppointments = appointments.where((e) {
            final apptDateStr = e.appointmentDate.trim();
            if (apptDateStr.isEmpty) return false;
            if (apptDateStr.startsWith(todayStr)) return true;
            try {
              final parsed = DateTime.parse(apptDateStr).toLocal();
              return parsed.year == now.year && parsed.month == now.month && parsed.day == now.day;
            } catch (_) {
              return false;
            }
          }).toList();

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              l10n.appointmentsPending,
                              pendingCount.toString(),
                              Colors.orange,
                              Icons.pending_actions_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              l10n.appointmentsConfirmed,
                              confirmedCount.toString(),
                              colors.success,
                              Icons.check_circle_outline_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Completed',
                              completedCount.toString(),
                              colors.primary,
                              Icons.verified_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              context,
                              'Total Visits',
                              appointments.length.toString(),
                              colors.text,
                              Icons.medical_services_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingL),

                      // Quick Actions Section
                      Text(
                        'Quick Actions',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingS),

                      AppCard(
                        child: InkWell(
                          onTap: () => _showCancelDayDialog(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.error.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.event_busy_rounded, color: colors.error, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.cancelDay,
                                        style: context.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colors.text,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Cancel & refund all appointments on a day',
                                        style: context.textTheme.bodyMedium?.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingL),

                      // Today's schedule section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Schedule",
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/doctor/appointments'),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.paddingS),

                      if (todayAppointments.isEmpty)
                        AppCard(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.event_available_rounded, size: 48, color: colors.primary.withValues(alpha: 0.3)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No visits scheduled for today!',
                                    style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todayAppointments.length,
                          itemBuilder: (context, index) {
                            final app = todayAppointments[index];
                            return _buildTodayAppointmentCard(context, app);
                          },
                        ),
                    ],
                  ),
                ),
                if (state is DoctorAppointmentActionInProgress)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: AppLoadingIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    final colors = context.appColors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointmentCard(BuildContext context, DoctorAppointmentModel app) {
    final colors = context.appColors;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.border),
      ),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          child: Text(
            app.patientName.isNotEmpty ? app.patientName[0].toUpperCase() : 'P',
            style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          app.patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Consultation Fee: \$${app.consultationFee.toStringAsFixed(2)}  •  ${DateFormatters.formatTime(app.appointmentTime)}',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        trailing: _buildStatusChip(context, app.status),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final colors = context.appColors;
    Color color = colors.textSecondary;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = colors.success;
        break;
      case 'completed':
        color = colors.primary;
        break;
      case 'cancelled':
        color = Colors.grey;
        break;
      case 'rejected':
        color = colors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showCancelDayDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<DoctorAppointmentsBloc>();
    DateTime? selectedDate;
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(l10n.cancelDay),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.cancelDayConfirm,
                      style: TextStyle(color: dialogContext.appColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    // Date selector button
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: dialogContext.appColors.border),
                      ),
                      leading: Icon(Icons.calendar_today_rounded, color: dialogContext.appColors.primary),
                      title: Text(
                        selectedDate == null
                            ? l10n.selectDate
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () async {
                        final now = DateTime.now();
                        final date = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: now,
                          lastDate: now.add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      labelText: l10n.cancellationReasonLabel,
                      controller: reasonController,
                      hintText: 'Enter reason for cancellation',
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dialogContext.appColors.error,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: selectedDate == null
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          bloc.add(CancelDayAppointmentsEvent(
                            date: DateFormat('yyyy-MM-dd').format(selectedDate!),
                            reason: reasonController.text,
                          ));
                        },
                  child: const Text('Confirm Cancel Day', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
