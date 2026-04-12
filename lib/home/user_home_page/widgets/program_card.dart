import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/config/utils.dart';
import 'package:fitness_management_app/features/programs/model/program_model.dart';
import 'package:fitness_management_app/features/programs/screens/program_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProgramCard extends StatelessWidget {
  final Program program;

  const ProgramCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final typeColor = AppTheme.programTypeColor(program.programType);
    final hasTrainerImage = program.trainer.profileImage != null && program.trainer.profileImage!.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProgramDetailScreen(programId: program.id)),
        ),
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                    decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
                    child: Text(
                      program.programType.toUpperCase(),
                      style: TextStyle(color: typeColor, fontSize: 11.sp, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                    ),
                  ),
                  // ── Clean price chip ──────────────────────────
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '₹${program.price.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: -0.3),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                program.name,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.3, height: 1.2),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (program.description != null) ...[
                SizedBox(height: 6.h),
                Text(program.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp, height: 1.45)),
              ],
              SizedBox(height: 14.h),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18.w,
                    backgroundColor: AppTheme.background,
                    backgroundImage: hasTrainerImage
                        ? NetworkImage(getImageUrl(program.trainer.profileImage))
                        : null,
                    child: !hasTrainerImage
                        ? Icon(Icons.person_rounded, size: 18.w, color: AppTheme.textMuted)
                        : null,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(program.trainer.name,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: AppTheme.textPrimary),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('Trainer', style: TextStyle(color: AppTheme.textMuted, fontSize: 12.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  if (program.difficulty != null) _buildInfoTag(Icons.trending_up_rounded, program.difficulty!),
                  if (program.schedule?.days.isNotEmpty ?? false)
                    _buildInfoTag(Icons.calendar_today_rounded, '${program.schedule!.days.length}x / week'),
                  if (program.location != null) _buildInfoTag(Icons.location_on_rounded, program.location!),
                ],
              ),
              if (program.capacity != null) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(8.r)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.people_outline_rounded, size: 15.w, color: AppTheme.primary),
                      SizedBox(width: 6.w),
                      Text(
                        '${program.capacity!.currentActive}/${program.capacity!.maxParticipants ?? '∞'} enrolled',
                        style: TextStyle(color: AppTheme.primary, fontSize: 12.sp, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.w, color: AppTheme.textMuted),
          SizedBox(width: 5.w),
          Text(label, style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}