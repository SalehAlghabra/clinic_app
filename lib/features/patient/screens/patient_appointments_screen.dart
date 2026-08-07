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
import '../repository/patient_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';

import '../../../shared/widgets/app_top_actions.dart';

class PatientAppointmentsScreen extends StatefulWidget {
  const PatientAppointmentsScreen({super.key});

  @override
  State<PatientAppointmentsScreen> createState() => _PatientAppointmentsScreenState();
}

class _PatientAppointmentsScreenState extends State<PatientAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AppointmentModel> _cachedAppointments = [];
  bool _cancelling = false;

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
            Tab(text: l10n.upcomingAppointments),
            Tab(text: l10n.pastAppointments),
          ],
        ),
      ),
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentsLoadSuccess) {
            _cachedAppointments = state.appointments;
          }

          if (state is AppointmentLoading && _cachedAppointments.isEmpty) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is AppointmentFailure && _cachedAppointments.isEmpty) {
            return AppErrorWidget(
              errorMessage: state.errorMessage,
              onRetry: _loadAppointments,
            );
          }

          final upcoming = _cachedAppointments
              .where((e) => e.status == 'pending' || e.status == 'confirmed')
              .toList();
          final past = _cachedAppointments
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
              // Show cancellation overlay only
              if (_cancelling)
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

    final canCancel = isUpcoming &&
        (appointment.status == 'pending' || appointment.status == 'confirmed');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    image: appointment.doctorProfilePictureUrl != null && appointment.doctorProfilePictureUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(appointment.doctorProfilePictureUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: (appointment.doctorProfilePictureUrl == null || appointment.doctorProfilePictureUrl!.isEmpty)
                      ? Icon(Icons.person_rounded, color: colors.primary, size: 24)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appointment.specialization,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(context, appointment.status),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              Icons.medical_services_outlined,
              'Consultation Fee: \$${appointment.consultationFee.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.calendar_today_rounded,
              '${DateFormatters.formatDateString(appointment.appointmentDate)}  •  ${DateFormatters.formatTime(appointment.appointmentTime)}',
            ),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.notes_rounded,
                appointment.notes!,
              ),
            ],
            if (appointment.additionalCost > 0) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.account_balance_wallet_outlined,
                'Additional Fee: \$${appointment.additionalCost.toStringAsFixed(2)} (${appointment.isPaid ? "Paid ✅" : "Unpaid ⚠️"})',
              ),
              if (appointment.additionalNote != null && appointment.additionalNote!.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildInfoRow(
                  context,
                  Icons.description_outlined,
                  appointment.additionalNote!,
                ),
              ],
            ],
            if (appointment.status == 'completed' && appointment.additionalCost > 0 && !appointment.isPaid) ...[
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.payment_rounded, size: 18),
                  label: Text('Pay Remaining Balance (\$${appointment.additionalCost.toStringAsFixed(2)})'),
                  onPressed: () => _showPayRemainingDialog(context, appointment),
                ),
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

  /// Cancel dialog — the actual API call is done directly here with async/await.
  /// No BlocConsumer bridges across navigation pops.
  void _showCancelDialog(BuildContext context, int id) {
    final l10n = AppLocalizations.of(context);
    final reasonController = TextEditingController();

    // Obtain PatientRepository directly from the AppointmentBloc
    final bloc = context.read<AppointmentBloc>();
    final repo = bloc.patientRepository;

    showDialog(
      context: context,
      barrierDismissible: false,
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
              onPressed: () async {
                // Close the cancel dialog first
                Navigator.of(dialogContext).pop();

                // Show cancellation loading overlay via local state
                if (mounted) setState(() => _cancelling = true);

                // Perform the API call directly — no Bloc event bridging
                final result = await repo.cancelAppointment(id, reason: reasonController.text);

                if (!mounted) return;

                setState(() => _cancelling = false);

                if (result.isSuccess) {
                  final resData = result.data!;
                  final message = resData['message'] as String? ?? 'Cancelled successfully';
                  final refundStatus = resData['refund_status'] as String? ?? '';
                  final displayMessage = refundStatus.isNotEmpty
                      ? '$message\n$refundStatus'
                      : message;

                  if (!mounted) return;
                  await AppDialogs.showSuccess(
                    context: context,
                    title: l10n.success,
                    message: displayMessage,
                    onPressed: _loadAppointments,
                  );
                } else {
                  if (!mounted) return;
                  await AppDialogs.showError(
                    context: context,
                    title: l10n.error,
                    message: result.failure?.message ?? 'Failed to cancel appointment',
                  );
                }
              },
              child: const Text('Confirm Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showPayRemainingDialog(BuildContext context, AppointmentModel appt) {
    final repo = RepositoryProvider.of<PatientRepository>(context);
    bool isPaying = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final colors = context.appColors;
            final isArabic = Localizations.localeOf(context).languageCode == 'ar';

            return AlertDialog(
              backgroundColor: colors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                isArabic ? 'دفع المبلغ المتبقي' : 'Pay Remaining Balance',
                style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic
                        ? 'هل تريد دفع المبلغ المتبقي للموعد قدره \$${appt.additionalCost.toStringAsFixed(2)} من محفظتك؟'
                        : 'Do you want to pay the remaining balance of \$${appt.additionalCost.toStringAsFixed(2)} for visit #${appt.id} from your wallet?',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  if (appt.additionalNote != null && appt.additionalNote!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Note: ${appt.additionalNote}',
                      style: TextStyle(color: colors.textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text(isArabic ? 'إلغاء' : 'Cancel', style: TextStyle(color: colors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: isPaying
                      ? null
                      : () async {
                          setDialogState(() => isPaying = true);
                          final res = await repo.payRemainingBalance(appt.id);
                          if (dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                            if (res.isSuccess) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isArabic
                                          ? 'تم دفع المبلغ المتبقي بنجاح! 💳'
                                          : 'Remaining balance paid successfully! 💳',
                                    ),
                                    backgroundColor: colors.success,
                                  ),
                                );
                                context.read<AuthBloc>().add(const AuthCheckRequested());
                                _loadAppointments();
                              }
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res.failure?.message ?? 'Payment failed'),
                                    backgroundColor: colors.error,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: isPaying
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isArabic ? 'تأكيد الدفع' : 'Confirm Payment'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
