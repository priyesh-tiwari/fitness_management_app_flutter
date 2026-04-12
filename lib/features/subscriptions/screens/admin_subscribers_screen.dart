import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/config/utils.dart';
import 'package:fitness_management_app/features/programs/provider/program_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Design Tokens ─────────────────────────────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
// AdminSubscribersScreen
// ─────────────────────────────────────────────────────────────────────────────
class AdminSubscribersScreen extends ConsumerStatefulWidget {
  const AdminSubscribersScreen({super.key});

  @override
  ConsumerState<AdminSubscribersScreen> createState() => _AdminSubscribersScreenState();
}

class _AdminSubscribersScreenState extends ConsumerState<AdminSubscribersScreen> {
  final Map<String, List<dynamic>> programSubscribers = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    programSubscribers.clear();

    await ref.read(programProvider.notifier).getAllPrograms();
    final programs = ref.read(programProvider).programs;

    for (final program in programs) {
      await ref.read(programProvider.notifier).getProgramSubscribers(program.id);
      final data = ref.read(programProvider).programSubscribers;
      programSubscribers[program.id] = (data?['subscribers'] ?? []) as List<dynamic>;
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final programs = ref.watch(programProvider).programs;

    return Scaffold(
      backgroundColor: AppTheme.kBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.kSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.kTextPrimary, size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Program Subscribers',
          style: TextStyle(color: AppTheme.kTextPrimary, fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        actions: [
          if (!isLoading)
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: AppTheme.kTextPrimary, size: 22.w),
              onPressed: _loadData,
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.kPrimary, strokeWidth: 2.5.w))
          : programs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 60.w, color: AppTheme.kBorder),
                      SizedBox(height: 12.h),
                      Text('No programs found', style: TextStyle(fontSize: 16.sp, color: AppTheme.kTextMuted)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppTheme.kPrimary,
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: programs.length,
                    itemBuilder: (context, index) {
                      final program     = programs[index];
                      final subscribers = programSubscribers[program.id] ?? [];
                      return _buildProgramTile(program, subscribers);
                    },
                  ),
                ),
    );
  }

  Widget _buildProgramTile(dynamic program, List<dynamic> subscribers) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.kSurface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          childrenPadding: EdgeInsets.only(bottom: 8.h),
          leading: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(color: AppTheme.kAccentLight, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              '${subscribers.length}',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppTheme.kPrimary),
            ),
          ),
          title: Text(
            program.name,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp, color: AppTheme.kTextPrimary),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Text(
              '${program.programType} • ${subscribers.length} subscribers',
              style: TextStyle(fontSize: 13.sp, color: AppTheme.kTextMuted),
            ),
          ),
          children: subscribers.isEmpty
              ? [
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Text('No subscribers yet', style: TextStyle(color: AppTheme.kTextMuted, fontSize: 14.sp)),
                  ),
                ]
              : subscribers.map<Widget>((subscriber) {
                  final user         = subscriber['user'];
                  final profileImage = user['profileImage'];
                  final hasImage     = profileImage != null && profileImage.toString().isNotEmpty;

                  // ── Compute expiry status from raw map ──────────────
                  final expiryDate   = DateTime.tryParse(subscriber['expiryDate'] ?? '');
                  final subStatus    = subscriber['status'] ?? 'active';
                  final isCancelled  = subStatus == 'cancelled';
                  final isExpired    = expiryDate == null || expiryDate.isBefore(DateTime.now());
                  final badgeLabel   = isCancelled ? 'CANCELLED' : isExpired ? 'EXPIRED' : 'ACTIVE';
                  final badgeColor   = (isCancelled || isExpired)
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF2E7D32);

                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.kAccentLight,
                      backgroundImage: hasImage
                          ? NetworkImage(getImageUrl(profileImage))
                          : null,
                      child: !hasImage
                          ? Text(
                              (user['name']?[0] ?? 'U').toUpperCase(),
                              style: TextStyle(color: AppTheme.kPrimary, fontWeight: FontWeight.w700, fontSize: 14.sp),
                            )
                          : null,
                    ),
                    title: Text(
                      user['name'] ?? 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.kTextPrimary, fontSize: 14.sp),
                    ),
                    subtitle: Text(
                      user['email'] ?? '',
                      style: TextStyle(fontSize: 12.sp, color: AppTheme.kTextMuted),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Status badge ──────────────────────────────
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        // ── Visits badge ──────────────────────────────
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.kAccentLight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '${subscriber['attendanceCount'] ?? 0} visits',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp, color: AppTheme.kPrimary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
        ),
      ),
    );
  }
}