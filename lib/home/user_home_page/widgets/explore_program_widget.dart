import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/programs/provider/program_provider.dart';
import 'package:fitness_management_app/features/programs/screens/program_list_screen.dart';
import 'package:fitness_management_app/home/user_home_page/widgets/program_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExploreProgramsWidget extends ConsumerWidget {
  const ExploreProgramsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programState = ref.watch(programProvider);
    final programs     = programState.programs.take(2).toList();

    if (programState.isLoading) {
      return Container(
        height: 160.h,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
        ),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.w),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary.withOpacity(0.5), AppTheme.primary.withOpacity(0.0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17.r),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      padding: EdgeInsets.all(1.2.w),
      child: Container(
        height: 260.h,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // ── Cards (scroll disabled) ───────────────────────
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 80.h),
              child: Column(
                children: programs.map((program) => ProgramCard(program: program)).toList(),
              ),
            ),

            // ── Fade + explore button pinned to bottom ────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.surface.withOpacity(0.0), AppTheme.surface],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProgramListScreen()),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: AppTheme.surface,
                      padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 12.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.explore_outlined, color: AppTheme.primary, size: 15.w),
                            SizedBox(width: 6.w),
                            Text(
                              'Explore all programs',
                              style: TextStyle(fontSize: 13.sp, color: AppTheme.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}