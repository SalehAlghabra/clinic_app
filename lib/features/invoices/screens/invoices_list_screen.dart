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
import '../bloc/invoices_bloc.dart';
import '../bloc/invoices_event.dart';
import '../bloc/invoices_state.dart';
import '../models/invoice_model.dart';

class InvoicesListScreen extends StatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  State<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends State<InvoicesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInvoices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInvoices() {
    context.read<InvoicesBloc>().add(const FetchPatientInvoicesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.invoicesTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colors.primary,
          unselectedLabelColor: colors.textSecondary,
          indicatorColor: colors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Paid'),
            Tab(text: 'Unpaid'),
          ],
        ),
      ),
      body: BlocBuilder<InvoicesBloc, InvoicesState>(
        builder: (context, state) {
          if (state is InvoicesLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is InvoicesFailure) {
            return AppErrorWidget(
              errorMessage: state.errorMessage,
              onRetry: _loadInvoices,
            );
          }

          if (state is InvoicesLoadSuccess) {
            final invoices = state.invoices;

            final paidInvoices = invoices.where((i) => i.paymentStatus == 'paid').toList();
            final unpaidInvoices = invoices.where((i) => i.paymentStatus == 'unpaid').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildInvoicesList(context, invoices),
                _buildInvoicesList(context, paidInvoices),
                _buildInvoicesList(context, unpaidInvoices),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInvoicesList(BuildContext context, List<InvoiceModel> list) {
    if (list.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _loadInvoices(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            AppEmptyState(
              icon: Icons.receipt_outlined,
              title: 'No Invoices Found',
              description: 'You have no invoices generated for consultations.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadInvoices(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final invoice = list[index];
          return _buildInvoiceCard(context, invoice)
              .animate()
              .fadeIn(delay: (index * 40).ms)
              .slideY(begin: 0.05);
        },
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, InvoiceModel invoice) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        onTap: () => context.push('/patient/invoices/details', extra: invoice),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice #${invoice.id}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                _buildStatusBadge(context, invoice.paymentStatus),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.medical_services_outlined, size: 16, color: colors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dr. ${invoice.doctorName}',
                    style: context.textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: colors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  DateFormatters.formatDateString(invoice.visitDate),
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount:',
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  '\$${invoice.totalAmount.toStringAsFixed(2)}',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final colors = context.appColors;
    final isPaid = status == 'paid';
    final badgeColor = isPaid ? colors.success : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
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
}
