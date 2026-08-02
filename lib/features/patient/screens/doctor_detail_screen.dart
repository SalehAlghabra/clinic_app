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
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider(
          create: (_) => AppointmentBloc(patientRepo),
          child: _BookingBottomSheet(
            doctor: doctor,
            patientRepository: patientRepo,
            schedules: schedules,
          ),
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
                        fontWeight: FontWeight.extrabold,
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

class _BookingBottomSheet extends StatefulWidget {
  final DoctorModel doctor;
  final PatientRepository patientRepository;
  final List<ScheduleModel> schedules;

  const _BookingBottomSheet({
    required this.doctor,
    required this.patientRepository,
    required this.schedules,
  });

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
        bottom: MediaQuery.of(sheetContext(context)).viewInsets.bottom + AppDimensions.paddingM,
      ),
      child: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentPreviewSuccess) {
            _showPreviewDialog(context, state.preview);
          } else if (state is AppointmentFailure) {
            AppDialogs.showError(
              context: context,
              title: l10n.error,
              message: state.errorMessage,
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.bookAppointment,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.doctor.name} (${widget.doctor.specialization}) — Fee: \$${widget.doctor.consultationFee.toStringAsFixed(2)}',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),

                // Date Selection
                Text(
                  l10n.selectDate,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _pickDate(context),
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
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
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

                // Time Slots Selector
                Text(
                  l10n.selectTimeSlot,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 8),
                if (_selectedDate == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        l10n.selectDate,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ),
                  )
                else
                  _buildSlotsSection(context, state),

                const SizedBox(height: AppDimensions.paddingM),

                // Notes Field
                AppTextField(
                  labelText: l10n.notesLabel,
                  controller: _notesController,
                  hintText: 'Optional notes for the doctor',
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Submit Button
                AppButton(
                  text: l10n.confirm,
                  isLoading: state is AppointmentLoading,
                  onPressed: _selectedDate != null && _selectedTime != null
                      ? () {
                          final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                          context.read<AppointmentBloc>().add(
                                PreviewAppointmentEvent(
                                  doctorId: widget.doctor.id,
                                  date: dateStr,
                                  time: _selectedTime!,
                                ),
                              );
                        }
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  BuildContext sheetContext(BuildContext context) => context;

  int _dayNameToWeekday(String dayName) {
    switch (dayName.toLowerCase().trim()) {
      case 'monday':
        return DateTime.monday;
      case 'tuesday':
        return DateTime.tuesday;
      case 'wednesday':
        return DateTime.wednesday;
      case 'thursday':
        return DateTime.thursday;
      case 'friday':
        return DateTime.friday;
      case 'saturday':
        return DateTime.saturday;
      case 'sunday':
        return DateTime.sunday;
      default:
        return 0;
    }
  }

  void _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final appointmentBloc = context.read<AppointmentBloc>();

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

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      selectableDayPredicate: (date) {
        if (allowedWeekdays.isEmpty) return true;
        return allowedWeekdays.contains(date.weekday);
      },
      builder: (context, child) {
        final colors = context.appColors;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primary,
              onPrimary: Colors.white,
              surface: colors.surface,
              onSurface: colors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTime = null;
      });
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      appointmentBloc.add(
        FetchAvailableSlotsEvent(doctorId: widget.doctor.id, date: dateStr),
      );
    }
  }

  Widget _buildSlotsSection(BuildContext context, AppointmentState state) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    if (state is AppointmentLoading && _selectedTime == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: AppLoadingIndicator(),
        ),
      );
    }

    if (state is AvailableSlotsLoadSuccess) {
      final slots = state.slots;
      if (slots.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              l10n.noDataFound,
              style: TextStyle(color: colors.error, fontWeight: FontWeight.w600),
            ),
          ),
        );
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: slots.map((slot) {
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
              setState(() {
                _selectedTime = selected ? slot : null;
              });
            },
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  void _showPreviewDialog(BuildContext context, AppointmentPreviewModel preview) {
    final appointmentBloc = context.read<AppointmentBloc>();
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: appointmentBloc,
          child: BlocConsumer<AppointmentBloc, AppointmentState>(
            listener: (context, state) {
              if (state is AppointmentBookSuccess) {
                Navigator.of(dialogContext).pop(); // pop dialog
                Navigator.of(context).pop(); // pop sheet
                AppDialogs.showSuccess(
                  context: context,
                  title: l10n.success,
                  message: state.message,
                  onPressed: () {
                    context.go('/patient/appointments');
                  },
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
              return AlertDialog(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: Text(
                  l10n.bookingSummary,
                  style: TextStyle(color: colors.text, fontWeight: FontWeight.bold),
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking details list
                      _buildDetailRow(context, 'Doctor', preview.bookingSummary.doctorName),
                      _buildDetailRow(
                        context,
                        'Date',
                        preview.bookingSummary.appointmentDate,
                      ),
                      _buildDetailRow(
                        context,
                        'Time',
                        DateFormatters.formatTime(preview.bookingSummary.appointmentTime),
                      ),
                      const Divider(height: 24),
                      Text(
                        l10n.paymentDetails,
                        style: TextStyle(
                          color: colors.text,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentRow(
                        context,
                        'Consultation Fee',
                        '\$${preview.bookingSummary.consultationFee.toStringAsFixed(2)}',
                      ),
                      _buildPaymentRow(
                        context,
                        l10n.depositRequired,
                        '\$${preview.paymentSummary.depositRequired.toStringAsFixed(2)}',
                        isHighlighted: true,
                      ),
                      _buildPaymentRow(
                        context,
                        l10n.walletBalance,
                        '\$${preview.paymentSummary.walletBalance.toStringAsFixed(2)}',
                      ),
                      if (preview.paymentSummary.balanceAfter != null)
                        _buildPaymentRow(
                          context,
                          l10n.balanceAfter,
                          '\$${preview.paymentSummary.balanceAfter!.toStringAsFixed(2)}',
                          isGreen: true,
                        ),
                      _buildPaymentRow(
                        context,
                        'Remaining at Clinic',
                        '\$${preview.paymentSummary.remainingAtVisit.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 16),

                      // Insufficient Balance Warning Card
                      if (!preview.paymentSummary.hasSufficient)
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
                                    color: colors.error,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: state is AppointmentActionInProgress
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                  if (preview.paymentSummary.hasSufficient)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: state is AppointmentActionInProgress
                          ? null
                          : () {
                              final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
                              context.read<AppointmentBloc>().add(
                                    BookAppointmentEvent(
                                      doctorId: widget.doctor.id,
                                      date: dateStr,
                                      time: _selectedTime!,
                                      notes: _notesController.text,
                                    ),
                                  );
                            },
                      child: state is AppointmentActionInProgress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(l10n.confirm, style: const TextStyle(color: Colors.white)),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                        context.go('/patient/wallet');
                      },
                      child: const Text('Top Up Wallet', style: TextStyle(color: Colors.white)),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 13)),
          Text(value, style: TextStyle(color: colors.text, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(BuildContext context, String label, String value,
      {bool isHighlighted = false, bool isGreen = false}) {
    final colors = context.appColors;
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
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
