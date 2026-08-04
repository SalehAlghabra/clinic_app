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
import '../../../shared/dialogs/app_dialogs.dart';
import '../bloc/doctor_appointments_bloc.dart';
import '../bloc/doctor_appointments_event.dart';
import '../bloc/doctor_appointments_state.dart';
import '../models/doctor_appointment_model.dart';

import '../../../shared/widgets/app_top_actions.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAppointments() {
    context.read<DoctorAppointmentsBloc>().add(const FetchDoctorAppointmentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.appointmentsTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: const [
          AppTopActions(),
          SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primary,
          tabs: [
            Tab(text: l10n.appointmentsPending),
            Tab(text: l10n.appointmentsConfirmed),
            Tab(text: l10n.appointmentsHistory),
          ],
        ),
      ),
      body: BlocConsumer<DoctorAppointmentsBloc, DoctorAppointmentsState>(
        listener: (context, state) {
          if (state is DoctorAppointmentActionSuccess) {
            AppDialogs.showSuccess(
              context: context,
              title: l10n.success,
              message: state.message,
              onPressed: _loadAppointments,
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
              onRetry: _loadAppointments,
            );
          }

          List<DoctorAppointmentModel> allList = [];
          if (state is DoctorAppointmentsLoadSuccess) {
            allList = state.appointments;
          } else {
            final bloc = context.read<DoctorAppointmentsBloc>();
            if (bloc.state is DoctorAppointmentsLoadSuccess) {
              allList = (bloc.state as DoctorAppointmentsLoadSuccess).appointments;
            }
          }

          final pending = allList.where((e) => e.status == 'pending').toList();
          final confirmed = allList.where((e) => e.status == 'confirmed').toList();
          final history = allList
              .where((e) =>
                  e.status == 'completed' ||
                  e.status == 'rejected' ||
                  e.status == 'cancelled')
              .toList();

          return Stack(
            children: [
              TabBarView(
                controller: _tabController,
                children: [
                  _buildAppointmentsList(context, pending, 'pending'),
                  _buildAppointmentsList(context, confirmed, 'confirmed'),
                  _buildAppointmentsList(context, history, 'history'),
                ],
              ),
              if (state is DoctorAppointmentActionInProgress)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: AppLoadingIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(
    BuildContext context,
    List<DoctorAppointmentModel> list,
    String type,
  ) {
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
                icon: Icons.calendar_month_outlined,
                title: l10n.noAppointments,
                description: type == 'pending'
                    ? 'No pending appointment requests to review.'
                    : type == 'confirmed'
                        ? 'No confirmed visit slots for the upcoming schedule.'
                        : 'No appointments in your history log.',
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
          return _buildAppointmentCard(context, appointment)
              .animate()
              .fadeIn(delay: (index * 50).ms)
              .slideY(begin: 0.05);
        },
      ),
    );
  }

  void _showCompleteVisitDialog(BuildContext context, DoctorAppointmentModel app) {
    final costController = TextEditingController(text: '0.00');
    final noteController = TextEditingController();
    final bloc = context.read<DoctorAppointmentsBloc>();
    final colors = context.appColors;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Complete Appointment & Issue Invoice',
            style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient: ${app.patientName}',
                  style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Consultation Fee (Pre-paid): \$${app.consultationFee.toStringAsFixed(2)}',
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 24),
                TextField(
                  controller: costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Additional Cost (\$)',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Additional Notes / Lab Tests',
                    prefixIcon: const Icon(Icons.note_alt_outlined),
                    hintText: 'e.g. ECG test & blood work',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final extraCost = double.tryParse(costController.text.trim()) ?? 0.0;
                final extraNote = noteController.text.trim();
                Navigator.pop(dialogCtx);
                bloc.add(
                  UpdateAppointmentStatusEvent(
                    id: app.id,
                    status: 'completed',
                    additionalCost: extraCost,
                    additionalNote: extraNote,
                  ),
                );
              },
              child: const Text('Complete & Issue Invoice', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentCard(BuildContext context, DoctorAppointmentModel app) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<DoctorAppointmentsBloc>();

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
                    app.patientName,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                ),
                _buildStatusBadge(context, app.status),
              ],
            ),
            if (app.patientPhone.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.phone_outlined, size: 14, color: colors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    app.patientPhone,
                    style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            _buildInfoRow(
              context,
              Icons.monetization_on_outlined,
              'Consultation Fee: \$${app.consultationFee.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.calendar_today_rounded,
              '${DateFormatters.formatDateString(app.appointmentDate)}  •  ${DateFormatters.formatTime(app.appointmentTime)}',
            ),
            if (app.additionalCost > 0 || (app.additionalNote != null && app.additionalNote!.isNotEmpty)) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.medical_services_outlined,
                'Extra Cost: \$${app.additionalCost.toStringAsFixed(2)} (${app.additionalNote ?? ''})',
              ),
            ],
            if (app.notes != null && app.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.notes_rounded,
                app.notes!,
              ),
            ],
            if (app.status == 'pending') ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: l10n.rejectVisit,
                      isOutline: true,
                      onPressed: () async {
                        final ok = await AppDialogs.showConfirmation(
                          context: context,
                          title: l10n.rejectVisit,
                          message: 'Are you sure you want to reject this appointment request?',
                        );
                        if (ok == true) {
                          bloc.add(UpdateAppointmentStatusEvent(id: app.id, status: 'rejected'));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: l10n.confirmVisit,
                      onPressed: () {
                        bloc.add(UpdateAppointmentStatusEvent(id: app.id, status: 'confirmed'));
                      },
                    ),
                  ),
                ],
              ),
            ] else if (app.status == 'confirmed') ...[
              const Divider(height: 24),
              AppButton(
                text: l10n.completeVisit,
                onPressed: () => _showCompleteVisitDialog(context, app),
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
}
