import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_card.dart';
import '../models/invoice_model.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isPaid = invoice.paymentStatus == 'paid';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Invoice Details',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        child: Column(
          children: [
            // Receipt card container
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoice #${invoice.id}',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            invoice.issuedAt != null
                                ? DateFormatters.formatDateString(invoice.issuedAt!)
                                : DateFormatters.formatDateString(invoice.visitDate),
                            style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                      _buildStatusBadge(context, invoice.paymentStatus),
                    ],
                  ),
                  const Divider(height: 32),

                  // Consult Detail info
                  Text(
                    'SERVICES PROVIDED',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              invoice.service,
                              style: context.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Dr. ${invoice.doctorName}',
                              style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${invoice.totalAmount.toStringAsFixed(2)} SP',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Pricing summary list
                  Text(
                    'BILL SUMMARY',
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    context,
                    label: 'Total consultation fee',
                    value: '${invoice.totalAmount.toStringAsFixed(2)} SP',
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                    context,
                    label: 'Deposit paid from wallet',
                    value: '-${invoice.depositAmount.toStringAsFixed(2)} SP',
                    valueColor: colors.success,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    context,
                    label: isPaid ? 'Amount Paid' : 'Remaining balance due',
                    value: '${(isPaid ? invoice.totalAmount : invoice.remainingAmount).toStringAsFixed(2)} SP',
                    isBold: true,
                    valueColor: isPaid ? colors.primary : colors.error,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
            const SizedBox(height: AppDimensions.paddingL),

            // Help section / note
            _buildBottomNote(context, isPaid),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    final colors = context.appColors;
    final style = isBold
        ? context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.text)
        : context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: isBold
              ? context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? colors.text,
                )
              : context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? colors.text,
                ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final colors = context.appColors;
    final isPaid = status == 'paid';
    final badgeColor = isPaid ? colors.success : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: context.textTheme.bodySmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNote(BuildContext context, bool isPaid) {
    final colors = context.appColors;
    return AppCard(
      color: isPaid
          ? colors.success.withValues(alpha: 0.05)
          : colors.warning.withValues(alpha: 0.05),
      borderSide: BorderSide(
        color: isPaid
            ? colors.success.withValues(alpha: 0.2)
            : colors.warning.withValues(alpha: 0.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPaid ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
            color: isPaid ? colors.success : colors.warning,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPaid ? 'Payment Confirmed' : 'Payment Due at Clinic',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPaid
                      ? 'This invoice has been fully paid. Thank you for choosing our clinic.'
                      : 'Please pay the remaining amount of ${invoice.remainingAmount.toStringAsFixed(2)} SP at the clinic desk during your visit using cash or card.',
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}
