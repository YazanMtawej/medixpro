import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medixpro/l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/notification_item.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<SettingsCubit>().loadNotifications());
  }

  Color _categoryColor(String category) {
    switch (category) {
      case "patient":     return AppColors.primary;
      case "appointment": return AppColors.success;
      case "medication":  return Colors.purple;
      case "report":      return AppColors.warning;
      case "auth":        return AppColors.info;
      case "warning":     return AppColors.error;
      default:            return AppColors.lightTextSecondary;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case "patient":     return Icons.person_outline;
      case "appointment": return Icons.calendar_month_outlined;
      case "medication":  return Icons.medication_outlined;
      case "report":      return Icons.description_outlined;
      case "auth":        return Icons.lock_outline;
      case "warning":     return Icons.warning_amber_outlined;
      default:            return Icons.notifications_outlined;
    }
  }

  String _timeAgo(String createdAt) {
    final l10n = AppLocalizations.of(context);
    if (createdAt.isEmpty) return "";
    final dt = DateTime.tryParse(createdAt)?.toLocal();
    if (dt == null) return "";
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return l10n.justNow;
    if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24)   return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? AppColors.gradientDark
                        : AppColors.gradientLight,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Text(
                l10n.notifications,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == "mark_all") {
                    context.read<SettingsCubit>().markAllAsRead();
                  } else if (v == "clear_all") {
                    context.read<SettingsCubit>().clearAll();
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: "mark_all",
                    child: Row(children: [
                      const Icon(Icons.done_all, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.markAllAsRead),
                    ]),
                  ),
                  PopupMenuItem(
                    value: "clear_all",
                    child: Row(children: [
                      const Icon(Icons.delete_sweep_outlined, size: 18),
                      const SizedBox(width: 8),
                      Text(l10n.clearAll),
                    ]),
                  ),
                ],
              ),
            ],
          ),

          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              if (state is SettingsLoading) {
                return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()));
              }

              if (state is NotificationsLoaded) {
                if (state.notifications.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.chipBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.notifications_off_outlined,
                                size: 52,
                                color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noNotifications,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final n = state.notifications[i];
                        final color = _categoryColor(n.category);
                        return _NotifCard(
                          notif: n,
                          color: color,
                          icon: _categoryIcon(n.category),
                          timeAgo: _timeAgo(n.createdAt),
                          isDark: isDark,
                          onTap: () {
                            if (!n.isRead) {
                              context
                                  .read<SettingsCubit>()
                                  .markAsRead(n.id);
                            }
                          },
                          onDelete: () => context
                              .read<SettingsCubit>()
                              .deleteNotification(n.id),
                        );
                      },
                      childCount: state.notifications.length,
                    ),
                  ),
                );
              }

              return const SliverFillRemaining(child: SizedBox());
            },
          ),
        ],
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationItem notif;
  final Color            color;
  final IconData         icon;
  final String           timeAgo;
  final bool             isDark;
  final VoidCallback     onTap;
  final VoidCallback     onDelete;

  const _NotifCard({
    required this.notif,
    required this.color,
    required this.icon,
    required this.timeAgo,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key("notif_${notif.id}"),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: notif.isRead
              ? (isDark ? AppColors.darkCard : AppColors.lightCard)
              : (isDark
                  ? color.withOpacity(0.08)
                  : color.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: notif.isRead
                  ? (isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight)
                  : color,
              width: notif.isRead ? 0.8 : 3,
            ),
            top: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8),
            right: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8),
            bottom: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notif.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: notif.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            if (!notif.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}