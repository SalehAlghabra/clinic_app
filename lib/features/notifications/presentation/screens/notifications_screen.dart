import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../auth/bloc/auth_bloc.dart';
import '../../../auth/bloc/auth_state.dart';
import '../../data/models/notification_model.dart';
import '../../data/repository/notification_repository.dart';

class NotificationsScreen extends StatefulWidget {
  final NotificationRepository repository;

  const NotificationsScreen({super.key, required this.repository});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await widget.repository.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _onNotificationTap(NotificationModel item) {
    final type = item.type.toLowerCase();
    final entityType = (item.entityType ?? '').toLowerCase();

    final authState = context.read<AuthBloc>().state;
    final isDoctor = authState is AuthAuthenticated && authState.user.role == 'doctor';

    if (isDoctor) {
      if (type.contains('appointment') || entityType == 'appointment') {
        context.go('/doctor/appointments');
      } else {
        context.go('/doctor/dashboard');
      }
    } else {
      if (type.contains('appointment') || entityType == 'appointment') {
        context.go('/patient/appointments');
      } else if (type.contains('wallet') || entityType == 'wallet') {
        context.go('/patient/wallet');
      } else if (type.contains('invoice') || type.contains('payment') || entityType == 'invoice') {
        context.go('/patient/invoices');
      }
    }
  }

  IconData _getIconForType(String type, String? entityType) {
    final t = type.toLowerCase();
    final e = (entityType ?? '').toLowerCase();

    if (t.contains('appointment') || e == 'appointment') {
      if (t.contains('cancel') || t.contains('reject')) {
        return Icons.event_busy_rounded;
      }
      return Icons.event_available_rounded;
    } else if (t.contains('wallet') || e == 'wallet') {
      return Icons.account_balance_wallet_rounded;
    } else if (t.contains('invoice') || t.contains('payment') || e == 'invoice') {
      return Icons.receipt_long_rounded;
    }
    return Icons.notifications_active_rounded;
  }

  Color _getColorForType(BuildContext context, String type, String? entityType) {
    final colors = context.appColors;
    final t = type.toLowerCase();
    final e = (entityType ?? '').toLowerCase();

    if (t.contains('cancel') || t.contains('reject')) {
      return colors.error;
    } else if (t.contains('wallet') || e == 'wallet') {
      return colors.warning;
    } else if (t.contains('confirm') || t.contains('completed') || t.contains('paid')) {
      return colors.success;
    }
    return colors.primary;
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null) return '';
    try {
      final parsed = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMM yyyy • hh:mm a').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final titleText = isArabic ? 'مركز الإشعارات' : 'Notification Center';
    final emptyText = isArabic ? 'لا توجد إشعارات حالياً' : 'No notifications yet.';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: colors.error, size: 48),
                          const SizedBox(height: 12),
                          Text(_errorMessage!, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadNotifications,
                            icon: const Icon(Icons.refresh),
                            label: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_none_rounded, size: 64, color: Theme.of(context).hintColor),
                            const SizedBox(height: 12),
                            Text(
                              emptyText,
                              style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = _notifications[index];
                          final icon = _getIconForType(item.type, item.entityType);
                          final color = _getColorForType(context, item.type, item.entityType);

                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _onNotificationTap(item),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(icon, color: color, size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item.body,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                            ),
                                          ),
                                          if (item.createdAt != null) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              _formatDate(item.createdAt),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Theme.of(context).hintColor,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: Theme.of(context).hintColor,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
