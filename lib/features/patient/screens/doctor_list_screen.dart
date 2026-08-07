import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_app/core/l10n/app_localizations.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../bloc/doctor_list_bloc.dart';
import '../bloc/doctor_list_event.dart';
import '../bloc/doctor_list_state.dart';
import '../models/doctor_model.dart';

import '../../../shared/widgets/app_top_actions.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<DoctorListBloc>().add(const FetchDoctorsRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        scrolledUnderElevation: 0,
        actions: const [
          AppTopActions(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: AppTextField(
                labelText: l10n.doctorsTitle,
                hintText: 'Search by name or specialization...',
                controller: _searchController,
                prefixIcon: Icon(Icons.search_rounded, color: colors.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: colors.textSecondary),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
              ),
            ),

            // Doctor List
            Expanded(
              child: BlocBuilder<DoctorListBloc, DoctorListState>(
                builder: (context, state) {
                  if (state is DoctorListLoading) {
                    return const Center(child: AppLoadingIndicator());
                  } else if (state is DoctorListFailure) {
                    return AppErrorWidget(
                      errorMessage: state.errorMessage,
                      onRetry: () => context
                          .read<DoctorListBloc>()
                          .add(const FetchDoctorsRequested()),
                    );
                  } else if (state is DoctorListSuccess) {
                    final filteredDoctors = state.doctors.where((doctor) {
                      final nameMatch =
                          doctor.name.toLowerCase().contains(_searchQuery);
                      final specMatch = doctor.specialization
                          .toLowerCase()
                          .contains(_searchQuery);
                      return nameMatch || specMatch;
                    }).toList();

                    if (filteredDoctors.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.noDataFound,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<DoctorListBloc>()
                            .add(const FetchDoctorsRequested());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingS,
                        ),
                        itemCount: filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = filteredDoctors[index];
                          return _buildDoctorCard(context, doctor)
                              .animate()
                              .fadeIn(
                                delay: (index * 80).ms,
                                duration: 350.ms,
                              )
                              .slideY(begin: 0.1, duration: 350.ms);
                        },
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doctor) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        onTap: () => context.push('/patient/doctors/${doctor.id}'),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                image: doctor.profilePictureUrl != null && doctor.profilePictureUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(doctor.profilePictureUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (doctor.profilePictureUrl == null || doctor.profilePictureUrl!.isEmpty)
                  ? Icon(
                      Icons.person_rounded,
                      color: colors.primary,
                      size: 32,
                    )
                  : null,
            ),
            const SizedBox(width: AppDimensions.paddingM),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      doctor.specialization,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (doctor.bio != null && doctor.bio!.isNotEmpty) ...[
                    Text(
                      doctor.bio!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(Icons.phone_enabled_outlined,
                          size: 14, color: colors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        doctor.phone ?? 'No phone provided',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            // Arrow indicator
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: colors.border,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
