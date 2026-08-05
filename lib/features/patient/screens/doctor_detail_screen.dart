import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/dialogs/app_dialogs.dart';
import '../bloc/doctor_detail_bloc.dart';
import '../bloc/doctor_detail_event.dart';
import '../bloc/doctor_detail_state.dart';

import '../models/doctor_model.dart';
import '../models/schedule_model.dart';
import '../models/appointment_preview_model.dart';
import '../repository/patient_repository.dart';

import '../../../shared/widgets/app_top_actions.dart';

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
        actions: const [
          AppTopActions(),
          SizedBox(width: 8),
        ],
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

                        // Schedules Section
                        Text(
                          l10n.appointmentsTitle,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
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
                                  .fadeIn(delay: (250 + index * 50).ms);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // CTA Booking Button
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(top: BorderSide(color: colors.border)),
                  ),
                  child: AppButton(
                    text: '${l10n.bookAppointment} (\$${state.doctor.consultationFee.toStringAsFixed(2)})',
                    onPressed: () => _showBookingBottomSheet(context, state.doctor, state.schedules),
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

  void _showBookingBottomSheet(BuildContext context, DoctorModel doctor, List<ScheduleModel> schedules) {
    final patientRepo = context.read<DoctorDetailBloc>().repository;
    // Capture a navigator reference BEFORE showing the sheet
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BookingBottomSheet(
          doctor: doctor,
          patientRepository: patientRepo,
          schedules: schedules,
          onBookingSuccess: (String message) {
            // Close the bottom sheet first
            navigator.pop();
            // Then show success dialog using the DoctorDetailScreen context
            if (context.mounted) {
              AppDialogs.showSuccess(
                context: context,
                title: AppLocalizations.of(context).success,
                message: message,
                onPressed: () {
                  if (context.mounted) {
                    router.go('/patient/appointments');
                  }
                },
              );
            }
          },
        );
      },
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
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  image: doctor.profilePictureUrl != null
                      ? DecorationImage(
                          image: NetworkImage(doctor.profilePictureUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: doctor.profilePictureUrl == null
                    ? Icon(Icons.person_rounded, color: colors.primary, size: 36)
                    : null,
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
                        color: colors.secondary.withValues(alpha: 0.12),
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
                    const SizedBox(height: 6),
                    Text(
                      'Consultation Fee: \$${doctor.consultationFee.toStringAsFixed(2)}',
                      style: context.textTheme.titleSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
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
          if (doctor.phone != null && doctor.phone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_enabled_outlined, size: 16, color: colors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  doctor.phone!,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
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

// ─────────────────────────────────────────────────────────────────────────────
// Booking bottom sheet — all state is LOCAL, no cross-context BlocConsumers
// ─────────────────────────────────────────────────────────────────────────────

enum _BookingPhase { selectSlot, preview, booking }

class _BookingBottomSheet extends StatefulWidget {
  final DoctorModel doctor;
  final PatientRepository patientRepository;
  final List<ScheduleModel> schedules;
  final void Function(String message) onBookingSuccess;

  const _BookingBottomSheet({
    required this.doctor,
    required this.patientRepository,
    required this.schedules,
    required this.onBookingSuccess,
  });

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  _BookingPhase _phase = _BookingPhase.selectSlot;

  // Selection state
  DateTime? _selectedDate;
  String? _selectedTime;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  final TextEditingController _notesController = TextEditingController();

  // Preview state
  AppointmentPreviewModel? _preview;
  bool _loadingPreview = false;
  String? _previewError;

  // Booking state
  String? _bookingError;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  int _dayNameToWeekday(String dayName) {
    switch (dayName.toLowerCase().trim()) {
      case 'monday': return DateTime.monday;
      case 'tuesday': return DateTime.tuesday;
      case 'wednesday': return DateTime.wednesday;
      case 'thursday': return DateTime.thursday;
      case 'friday': return DateTime.friday;
      case 'saturday': return DateTime.saturday;
      case 'sunday': return DateTime.sunday;
      default: return 0;
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final allowedWeekdays = widget.schedules
        .map((s) => _dayNameToWeekday(s.dayOfWeek))
        .where((w) => w > 0)
        .toSet();

    DateTime initialDate = now;
    if (allowedWeekdays.isNotEmpty) {
      while (!allowedWeekdays.contains(initialDate.weekday)) {
        initialDate = initialDate.add(const Duration(days: 1));
      }
    }

    final colors = context.appColors;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      selectableDayPredicate: (date) {
        if (allowedWeekdays.isEmpty) return true;
        return allowedWeekdays.contains(date.weekday);
      },
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: colors.primary,
            onPrimary: Colors.white,
            surface: colors.surface,
            onSurface: colors.text,
          ),
        ),
        child: child!,
      ),
    );

    if (date != null && mounted) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null;
        _availableSlots = [];
        _loadingSlots = true;
      });
      try {
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        final result = await widget.patientRepository.getAvailableSlots(
          widget.doctor.id, dateStr,
        );
        if (mounted) {
          setState(() {
            _loadingSlots = false;
            _availableSlots = result.isSuccess ? result.data! : [];
          });
        }
      } catch (_) {
        if (mounted) setState(() => _loadingSlots = false);
      }
    }
  }

  Future<void> _loadPreview() async {
    if (_selectedDate == null || _selectedTime == null) return;
    setState(() {
      _loadingPreview = true;
      _previewError = null;
    });
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final result = await widget.patientRepository.previewAppointment(
      doctorId: widget.doctor.id,
      date: dateStr,
      time: _selectedTime!,
    );
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() {
        _preview = result.data;
        _loadingPreview = false;
        _phase = _BookingPhase.preview;
      });
    } else {
      setState(() {
        _loadingPreview = false;
        _previewError = result.failure?.message ?? 'Failed to load preview';
      });
    }
  }

  Future<void> _confirmBooking() async {
    final preview = _preview;
    if (preview == null || _selectedDate == null || _selectedTime == null) return;

    setState(() {
      _phase = _BookingPhase.booking;
      _bookingError = null;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    final result = await widget.patientRepository.bookAppointment(
      doctorId: widget.doctor.id,
      date: dateStr,
      time: _selectedTime!,
      notes: _notesController.text,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      final message = (result.data!['message'] as String?) ?? 'Booked successfully';
      // Invoke the callback — DoctorDetailScreen will close the sheet and show success
      widget.onBookingSuccess(message);
    } else {
      setState(() {
        _phase = _BookingPhase.preview;
        _bookingError = result.failure?.message ?? 'Failed to book appointment';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppDimensions.paddingM,
        right: AppDimensions.paddingM,
        top: AppDimensions.paddingM,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.paddingM,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 5,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_phase == _BookingPhase.selectSlot) ...[
              _buildSelectSlotPhase(context, l10n, colors),
            ] else if (_phase == _BookingPhase.preview) ...[
              _buildPreviewPhase(context, l10n, colors),
            ] else ...[
              _buildLoadingPhase(context, l10n, colors),
            ],
          ],
        ),
      ),
    );
  }

  // ── Phase 1: Select date & slot ──────────────────────────────────────────
  Widget _buildSelectSlotPhase(BuildContext context, AppLocalizations l10n, dynamic colors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bookAppointment,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold, color: colors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.doctor.name} (${widget.doctor.specialization}) — Fee: \$${widget.doctor.consultationFee.toStringAsFixed(2)}',
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.primary, fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),

        // Date picker
        Text(l10n.selectDate,
            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.text)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate == null
                      ? l10n.selectDate
                      : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  style: TextStyle(
                    color: _selectedDate == null ? colors.textSecondary : colors.text,
                  ),
                ),
                Icon(Icons.calendar_today_rounded, color: colors.primary, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.paddingM),

        // Time slots
        Text(l10n.selectTimeSlot,
            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.text)),
        const SizedBox(height: 8),
        if (_selectedDate == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(l10n.selectDate, style: TextStyle(color: colors.textSecondary)),
            ),
          )
        else if (_loadingSlots)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: AppLoadingIndicator()),
          )
        else if (_availableSlots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(l10n.noDataFound,
                  style: TextStyle(color: colors.error, fontWeight: FontWeight.w600)),
            ),
          )
        else
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _availableSlots.map((slot) {
              final isSelected = _selectedTime == slot;
              return ChoiceChip(
                label: Text(
                  DateFormatters.formatTime(slot),
                  style: TextStyle(
                    color: isSelected ? Colors.white : colors.text,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                selectedColor: colors.primary,
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: isSelected ? colors.primary : colors.border),
                ),
                onSelected: (selected) {
                  setState(() => _selectedTime = selected ? slot : null);
                },
              );
            }).toList(),
          ),

        const SizedBox(height: AppDimensions.paddingM),

        // Notes
        AppTextField(
          labelText: l10n.notesLabel,
          controller: _notesController,
          hintText: 'Optional notes for the doctor',
        ),

        if (_previewError != null) ...[
          const SizedBox(height: 12),
          Text(_previewError!,
              style: TextStyle(color: colors.error, fontSize: 13)),
        ],

        const SizedBox(height: AppDimensions.paddingL),

        AppButton(
          text: l10n.confirm,
          isLoading: _loadingPreview,
          onPressed: _selectedDate != null && _selectedTime != null && !_loadingPreview
              ? _loadPreview
              : null,
        ),
      ],
    );
  }

  // ── Phase 2: Show preview / payment summary ──────────────────────────────
  Widget _buildPreviewPhase(BuildContext context, AppLocalizations l10n, dynamic colors) {
    final preview = _preview!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: colors.text, size: 18),
              onPressed: () => setState(() => _phase = _BookingPhase.selectSlot),
            ),
            Text(
              l10n.bookingSummary,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: colors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Detail rows
        _buildDetailRow(context, 'Doctor', preview.bookingSummary.doctorName, colors),
        _buildDetailRow(context, 'Date',
            DateFormatters.formatDateString(preview.bookingSummary.appointmentDate), colors),
        _buildDetailRow(context, 'Time',
            DateFormatters.formatTime(preview.bookingSummary.appointmentTime), colors),

        const Divider(height: 24),

        Text(l10n.paymentDetails,
            style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),

        _buildPaymentRow(context, 'Consultation Fee',
            '\$${preview.bookingSummary.consultationFee.toStringAsFixed(2)}', colors),
        _buildPaymentRow(context, l10n.depositRequired,
            '\$${preview.paymentSummary.depositRequired.toStringAsFixed(2)}', colors,
            isHighlighted: true),
        _buildPaymentRow(context, l10n.walletBalance,
            '\$${preview.paymentSummary.walletBalance.toStringAsFixed(2)}', colors),
        if (preview.paymentSummary.balanceAfter != null)
          _buildPaymentRow(context, l10n.balanceAfter,
              '\$${preview.paymentSummary.balanceAfter!.toStringAsFixed(2)}', colors,
              isGreen: true),
        _buildPaymentRow(context, 'Remaining at Clinic',
            '\$${preview.paymentSummary.remainingAtVisit.toStringAsFixed(2)}', colors),

        // Insufficient balance warning
        if (!preview.paymentSummary.hasSufficient) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: colors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.insufficientBalance,
                    style: TextStyle(
                      color: colors.error, fontSize: 13, fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_bookingError != null) ...[
          const SizedBox(height: 12),
          Text(_bookingError!, style: TextStyle(color: colors.error, fontSize: 13)),
        ],

        const SizedBox(height: 24),

        // Action buttons
        if (preview.paymentSummary.hasSufficient)
          AppButton(
            text: l10n.confirm,
            onPressed: _confirmBooking,
          )
        else
          AppButton(
            text: 'Top Up Wallet',
            onPressed: () {
              Navigator.of(context).pop();
              GoRouter.of(context).go('/patient/wallet');
            },
          ),

        const SizedBox(height: 8),

        AppButton(
          text: l10n.cancel,
          isOutline: true,
          onPressed: () => setState(() => _phase = _BookingPhase.selectSlot),
        ),
      ],
    );
  }

  // ── Phase 3: Full-screen booking in progress ─────────────────────────────
  Widget _buildLoadingPhase(BuildContext context, AppLocalizations l10n, dynamic colors) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLoadingIndicator(),
            const SizedBox(height: 20),
            Text('Booking your appointment...',
                style: TextStyle(color: colors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, dynamic colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: colors.text, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(BuildContext context, String label, String value, dynamic colors,
      {bool isHighlighted = false, bool isGreen = false}) {
    Color valueColor = colors.text;
    if (isHighlighted) valueColor = colors.primary;
    if (isGreen) valueColor = colors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(value,
              style: TextStyle(
                  color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
