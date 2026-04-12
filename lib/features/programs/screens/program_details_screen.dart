import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/config/utils.dart';
import 'package:fitness_management_app/features/programs/provider/program_provider.dart';
import 'package:fitness_management_app/features/subscriptions/provider/subscription_provider.dart';
import 'package:fitness_management_app/features/subscriptions/screens/stripe_checkout_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProgramDetailScreen extends ConsumerStatefulWidget {
  final String programId;

  const ProgramDetailScreen({super.key, required this.programId});

  @override
  ConsumerState<ProgramDetailScreen> createState() => _ProgramDetailScreenState();
}

class _ProgramDetailScreenState extends ConsumerState<ProgramDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(programProvider.notifier).getProgramById(widget.programId);
    });
  }

  Future<void> _subscribe() async {
    print('Subscribe button pressed');

    final result = await ref
        .read(subscriptionProvider.notifier)
        .initiateSubscription(widget.programId);

    print('UI received result: $result');

    if (!mounted) return;

    if (result != null) {
      if (result['type'] == 'checkout') {
        final sessionId   = result['sessionId'] as String?;
        final checkoutUrl = result['url'] as String?;

        if (sessionId != null && checkoutUrl != null) {
          print('Opening WebView with URL: $checkoutUrl');

          final paymentSuccess = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StripeCheckoutWebView(
                checkoutUrl: checkoutUrl,
                sessionId: sessionId,
              ),
            ),
          );

          if (paymentSuccess == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subscription activated!'), backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid payment data received'), backgroundColor: Colors.red),
          );
        }
      } else if (result['type'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Subscribed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      final error = ref.read(subscriptionProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to subscribe'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final programState      = ref.watch(programProvider);
    final subscriptionState = ref.watch(subscriptionProvider);
    final program           = programState.selectedProgram;

    if (programState.isLoading || program == null) {
      return Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          backgroundColor: AppTheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20.w),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5.w)),
      );
    }

    final typeColor = AppTheme.programTypeColor(program.programType);
    final hasTrainerImage = program.trainer.profileImage != null && program.trainer.profileImage!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          program.name,
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Hero: type + price ──────────────────────────────
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                border: Border(bottom: BorderSide(color: AppTheme.border)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      program.programType.toUpperCase(),
                      style: TextStyle(color: typeColor, fontWeight: FontWeight.w700, fontSize: 12.sp, letterSpacing: 0.8),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text('₹', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ),
                      Text(
                        program.price.toStringAsFixed(0),
                        style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -2, height: 1),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${program.duration} days program',
                    style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // ── About ───────────────────────────────────────────
            if (program.description != null) ...[
              _buildSection(
                title: 'About this program',
                child: Text(program.description!, style: TextStyle(fontSize: 15.sp, color: AppTheme.textMuted, height: 1.65)),
              ),
              Divider(height: 1, color: AppTheme.border),
            ],

            // ── Trainer ─────────────────────────────────────────
            _buildSection(
              title: 'Your trainer',
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14.r)),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28.w,
                      backgroundColor: AppTheme.border,
                      backgroundImage: hasTrainerImage
                          ? NetworkImage(getImageUrl(program.trainer.profileImage))
                          : null,
                      child: !hasTrainerImage
                          ? Icon(Icons.person_rounded, size: 28.w, color: AppTheme.textMuted)
                          : null,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(program.trainer.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp, color: AppTheme.textPrimary)),
                          SizedBox(height: 4.h),
                          Text(program.trainer.email, style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: AppTheme.border),

            // ── Schedule ────────────────────────────────────────
            if (program.schedule != null) ...[
              _buildSection(
                title: 'Schedule',
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14.r)),
                  child: Column(
                    children: [
                      _buildScheduleRow(icon: Icons.calendar_today_rounded, label: program.schedule!.days.join(', ')),
                      if (program.schedule!.time != null) ...[
                        SizedBox(height: 12.h),
                        _buildScheduleRow(
                          icon: Icons.access_time_rounded,
                          label: '${program.schedule!.time!.start} – ${program.schedule!.time!.end}',
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: AppTheme.border),
            ],

            // ── Program details ─────────────────────────────────
            _buildSection(
              title: 'Program details',
              child: Column(
                children: [
                  if (program.difficulty != null)
                    _buildDetailItem(Icons.trending_up_rounded, 'Difficulty', program.difficulty!),
                  if (program.location != null)
                    _buildDetailItem(Icons.location_on_rounded, 'Location', program.location!),
                  if (program.capacity != null)
                    _buildDetailItem(
                      Icons.people_outline_rounded,
                      'Enrollment',
                      '${program.capacity!.currentActive} of ${program.capacity!.maxParticipants ?? '∞'} spots filled',
                    ),
                  _buildDetailItem(Icons.calendar_month_rounded, 'Duration', '${program.duration} days'),
                ],
              ),
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: subscriptionState.isLoading ? null : _subscribe,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
              disabledBackgroundColor: AppTheme.primary.withOpacity(0.4),
            ),
            child: subscriptionState.isLoading
                ? SizedBox(
                    height: 20.h,
                    width: 20.w,
                    child: CircularProgressIndicator(strokeWidth: 2.w, color: Colors.white),
                  )
                : Text('Subscribe Now', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.2)),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _buildScheduleRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(9.w),
          decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(8.r)),
          child: Icon(icon, size: 18.w, color: AppTheme.primary),
        ),
        SizedBox(width: 12.w),
        Expanded(child: Text(label, style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary, fontWeight: FontWeight.w500))),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(9.w),
            decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, size: 18.w, color: AppTheme.textMuted),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 1.h),
                Text(label, style: TextStyle(fontSize: 12.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                SizedBox(height: 3.h),
                Text(value, style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}