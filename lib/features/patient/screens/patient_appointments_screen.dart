import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/dialogs/app_dialogs.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';
import '../models/appointment_model.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAppointments() {
    context.read<AppointmentBloc>().add(const FetchAppointmentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.myAppointments,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primary,
          tabs: [
            Tab(text: l10n.upcomingAppointments),
            Tab(text: l10n.pastAppointments),
          ],
        ),
      ),
      body: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentCancelSuccess) {
            AppDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: '${state.message}\n${state.refundStatus}',
              onPressed: _loadAppointments,
            );
          } else if (state is AppointmentFailure) {
            AppDialogs.showError(
              context: context,
              title: l10n.error,
              message: state.errorMessage,
            );
          }
        },
        builder: (context, state) {
          if (state is AppointmentLoading && state is! AppointmentActionInProgress) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is AppointmentFailure) {
            return AppErrorWidget(
              errorMessage: state.errorMessage,
              onRetry: _loadAppointments,
            );
          }

          if (state is AppointmentsLoadSuccess || state is AppointmentActionInProgress || state is AppointmentCancelSuccess) {
            List<AppointmentModel> allList = [];
            if (state is AppointmentsLoadSuccess) {
              allList = state.appointments;
            } else {
              // Keep showing previous items during cancellation action loaders
              // Find active state
              final bloc = context.read<AppointmentBloc>();
              if (bloc.state is AppointmentsLoadSuccess) {
                allList = (bloc.state as AppointmentsLoadSuccess).appointments;
              }
            }

            final upcoming = allList
                .where((e) => e.status == 'pending' || e.status == 'confirmed')
                .toList();
            final past = allList
                .where((e) =>
                    e.status == 'completed' ||
                    e.status == 'cancelled' ||
                    e.status == 'rejected')
                .toList();

            return Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAppointmentsList(context, upcoming, isUpcoming: true),
                    _buildAppointmentsList(context, past, isUpcoming: false),
                  ],
                ),
                if (state is AppointmentActionInProgress)
                  Container(
                    color: Colors.black.withValues(alpha: 0.3),
                    child: const Center(
                      child: AppLoadingIndicator(),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    List<AppointmentModel> list, {
    required bool isUpcoming,
  }) {
    final l10n = AppLocalizations.of(context);

    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _loadAppointments(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: AppEmptyState(
                icon: Icons.calendar_today_outlined,
                title: l10n.noAppointments,
                description: 'You can browse doctors and book an appointment.',
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final appointment = list[index];
          return _buildAppointmentCard(context, appointment, isUpcoming)
              .animate()
              .fadeIn(delay: (index * 50).ms)
              .slideX(begin: 0.05);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentModel appointment,
    bool isUpcoming,
  ) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    // Cancel possibility
    final canCancel = isUpcoming &&
        (appointment.status == 'pending' || appointment.status == 'confirmed');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.doctorName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                ),
                _buildStatusBadge(context, appointment.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              appointment.specialization,
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              Icons.medical_services_outlined,
              '${appointment.service} (${appointment.price.toStringAsFixed(2)} SP)',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.calendar_today_rounded,
              '${appointment.appointmentDate}  •  ${DateFormatters.formatTime(appointment.appointmentTime)}',
            ),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.notes_rounded,
                appointment.notes!,
              ),
            ],
            if (canCancel) ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                  text: l10n.cancel,
                  isOutline: true,
                  onPressed: () => _showCancelDialog(context, appointment.id),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    Color badgeColor = colors.textSecondary;
    String badgeText = status;

    switch (status) {
      case 'pending':
        badgeColor = Colors.orange;
        badgeText = l10n.status_pending;
        break;
      case 'confirmed':
        badgeColor = colors.success;
        badgeText = l10n.status_confirmed;
        break;
      case 'completed':
        badgeColor = colors.primary;
        badgeText = l10n.status_completed;
        break;
      case 'rejected':
        badgeColor = colors.error;
        badgeText = l10n.status_rejected;
        break;
      case 'cancelled':
        badgeColor = Colors.grey;
        badgeText = l10n.status_cancelled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        badgeText,
        style: context.textTheme.bodySmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, int id) {
    final l10n = AppLocalizations.of(context);
    final appointmentBloc = context.read<AppointmentBloc>();
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.cancelAppointmentConfirm),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Note: Cancellations within 24 hours of the appointment will incur a penalty charge deduction from your wallet deposit.',
                style: TextStyle(
                  color: dialogContext.appColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              AppTextField(
                labelText: l10n.cancellationReason,
                controller: reasonController,
                hintText: 'Reason for cancellation',
              ),
            ],
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
                appointmentBloc.add(
                  CancelAppointmentEvent(id: id, reason: reasonController.text),
                );
              },
              child: const Text('Confirm Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
