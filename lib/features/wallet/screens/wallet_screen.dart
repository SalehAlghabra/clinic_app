import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';
import '../models/wallet_transaction_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  void _loadWalletData() {
    context.read<WalletBloc>().add(const FetchWalletDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.walletTitle,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colors.text),
            onPressed: _loadWalletData,
          ),
        ],
      ),
      body: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is WalletFailure) {
            return AppErrorWidget(
              errorMessage: state.errorMessage,
              onRetry: _loadWalletData,
            );
          }

          if (state is WalletLoadSuccess) {
            final balance = state.balance;
            final transactions = state.transactions;

            return RefreshIndicator(
              onRefresh: () async => _loadWalletData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Balance Card
                    _buildBalanceCard(context, balance.walletBalance, balance.violationCount),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Top-up Instructions banner
                    _buildTopupBanner(context),
                    const SizedBox(height: AppDimensions.paddingL),

                    // Section title for Transactions
                    Row(
                      children: [
                        Icon(Icons.history_toggle_off_rounded, color: colors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.walletTransactions,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.paddingS),

                    if (transactions.isEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Center(
                          child: AppEmptyState(
                            icon: Icons.receipt_long_outlined,
                            title: 'No Transaction Logs',
                            description: 'All your deposit and booking deductions will show up here.',
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return _buildTransactionItem(context, tx)
                              .animate()
                              .fadeIn(delay: (index * 40).ms)
                              .slideY(begin: 0.05);
                        },
                      ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double totalBalance, int violations) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.walletBalance,
            style: context.textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${totalBalance.toStringAsFixed(2)} SP',
            style: context.textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '$violations Violations',
                      style: context.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Fee deposit standard: 50.00 SP',
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopupBanner(BuildContext context) {
    final colors = context.appColors;
    return AppCard(
      color: colors.secondary.withValues(alpha: 0.05),
      borderSide: BorderSide(color: colors.secondary.withValues(alpha: 0.2)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.secondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How to top-up?',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'To add funds to your wallet balance, please visit the clinic receptionist desk or call administration at +963 11 9999.',
                  style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, WalletTransactionModel tx) {
    final colors = context.appColors;
    final l10n = AppLocalizations.of(context);

    // Identify color & sign based on type
    Color txColor = colors.error;
    String sign = '-';
    String localizedType = tx.type;

    switch (tx.type) {
      case 'deposit':
        txColor = colors.success;
        sign = '+';
        localizedType = l10n.transactionType_deposit;
        break;
      case 'booking_deduct':
        txColor = colors.error;
        sign = '-';
        localizedType = l10n.transactionType_booking_deduct;
        break;
      case 'refund_full':
        txColor = colors.success;
        sign = '+';
        localizedType = l10n.transactionType_refund_full;
        break;
      case 'refund_partial':
        txColor = colors.success;
        sign = '+';
        localizedType = l10n.transactionType_refund_partial;
        break;
      case 'penalty':
        txColor = Colors.orange;
        sign = '-';
        localizedType = l10n.transactionType_penalty;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: AppCard(
        child: Row(
          children: [
            // Icon representing transaction type
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: txColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tx.type == 'deposit' || tx.type.startsWith('refund')
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: txColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),

            // Description and Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description ?? localizedType,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatters.formatDateString(tx.createdAt),
                    style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$sign${tx.amount.toStringAsFixed(2)} SP',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: txColor,
                  ),
                ),
                Text(
                  'Bal: ${tx.balanceAfter.toStringAsFixed(0)}',
                  style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
