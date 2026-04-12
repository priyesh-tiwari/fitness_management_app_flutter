import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/subscriptions/provider/subscription_provider.dart';
import 'package:fitness_management_app/features/subscriptions/screens/subscription_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Design Tokens ─────────────────────────────────────────────────────────────

const _kTypeColors = <String, Color>{
  'yoga'    : Color(0xFF7B2D8B),
  'gym'     : Color(0xFFB71C1C),
  'cardio'  : Color(0xFFE65100),
  'strength': Color(0xFF1565C0),
  'zumba'   : Color(0xFFAD1457),
};

// ─────────────────────────────────────────────────────────────────────────────
// MySubscriptionsScreen
// ─────────────────────────────────────────────────────────────────────────────
class MySubscriptionsScreen extends ConsumerStatefulWidget {
  const MySubscriptionsScreen({super.key});

  @override
  ConsumerState<MySubscriptionsScreen> createState() => _MySubscriptionsScreenState();
}

class _MySubscriptionsScreenState extends ConsumerState<MySubscriptionsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(subscriptionProvider.notifier).getMySubscriptions());
  }

  // ── Handlers ────────────────────────────────────────────────

  void _applyFilter(String filter) {
    // just update local filter, no backend call needed
    setState(() => _selectedFilter = filter);
  }

  void _openDetail(dynamic subscription) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SubscriptionDetailScreen(subscription: subscription)),
    );
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionProvider);
    final subscriptions     = subscriptionState.subscriptions;

    // ── Client-side filter ───────────────────────────────────
    final filtered = _selectedFilter == 'all'
        ? subscriptions
        : subscriptions.where((s) {
            if (_selectedFilter == 'active')    return s.isActive;
            if (_selectedFilter == 'cancelled') return s.status == 'cancelled';
            if (_selectedFilter == 'expired')   return !s.isActive && s.status != 'cancelled';
            return true;
          }).toList();

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
          'My Subscriptions',
          style: TextStyle(color: AppTheme.kTextPrimary, fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
      ),
      body: Column(
        children: [
          // ── Filter chips ────────────────────────────────────
          Container(
            color: AppTheme.kSurface,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Active', 'active'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Expired', 'expired'),
                  SizedBox(width: 8.w),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),

          SizedBox(height: 8.h),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: subscriptionState.isLoading
                ? Center(child: CircularProgressIndicator(color: AppTheme.kPrimary, strokeWidth: 2.5.w))
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.card_membership_outlined, size: 60.w, color: AppTheme.kBorder),
                            SizedBox(height: 12.h),
                            Text(
                              'No subscriptions found',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: AppTheme.kTextMuted),
                            ),
                            SizedBox(height: 8.h),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Browse Programs',
                                style: TextStyle(color: AppTheme.kPrimary, fontWeight: FontWeight.w600, fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.kPrimary,
                        onRefresh: () async =>
                            ref.read(subscriptionProvider.notifier).getMySubscriptions(),
                        child: ListView.builder(
                          padding: EdgeInsets.all(16.w),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              _buildSubscriptionCard(filtered[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // ── Filter Chip ──────────────────────────────────────────────────────────────

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => _applyFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.kPrimary : AppTheme.kBackground,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.kTextMuted,
          ),
        ),
      ),
    );
  }

  // ── Subscription Card ────────────────────────────────────────────────────────

  Widget _buildSubscriptionCard(dynamic subscription) {
    final program  = subscription.program;
    final isActive = subscription.isActive;
    final daysLeft = subscription.expiryDate.difference(DateTime.now()).inDays;
    final urgentColor = const Color(0xFFD32F2F);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.kSurface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: InkWell(
        onTap: () => _openDetail(subscription),
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      program?.name ?? 'Program',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.kTextPrimary),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _buildStatusBadge(subscription.status, isActive),
                ],
              ),

              SizedBox(height: 10.h),

              // Program type badge
              if (program != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: (_kTypeColors[program.programType.toLowerCase()] ?? AppTheme.kTextMuted).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    program.programType.toUpperCase(),
                    style: TextStyle(
                      color: _kTypeColors[program.programType.toLowerCase()] ?? AppTheme.kTextMuted,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // Date range
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14.w, color: AppTheme.kTextMuted),
                  SizedBox(width: 6.w),
                  Text(
                    '${_formatDate(subscription.startDate)} – ${_formatDate(subscription.expiryDate)}',
                    style: TextStyle(fontSize: 13.sp, color: AppTheme.kTextMuted),
                  ),
                ],
              ),

              // Days remaining
              if (isActive) ...[
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14.w,
                      color: daysLeft < 7 ? urgentColor : AppTheme.kPrimary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      daysLeft > 0 ? '$daysLeft days remaining' : 'Expires today',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: daysLeft < 7 ? urgentColor : AppTheme.kPrimary,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12.h),
              Divider(height: 1, color: AppTheme.kBorder),
              SizedBox(height: 10.h),

              // Visits + QR button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 15.w, color: AppTheme.kTextMuted),
                      SizedBox(width: 6.w),
                      Text(
                        '${subscription.attendanceCount} visits',
                        style: TextStyle(fontSize: 13.sp, color: AppTheme.kTextMuted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (isActive)
                    GestureDetector(
                      onTap: () => _openDetail(subscription),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppTheme.kAccentLight,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.qr_code_rounded, size: 14.w, color: AppTheme.kPrimary),
                            SizedBox(width: 5.w),
                            Text(
                              'View QR',
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppTheme.kPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Status Badge ─────────────────────────────────────────────────────────────

  Widget _buildStatusBadge(String status, bool isActive) {
    final Color color;
    final String label;

    if (isActive) {
      color = const Color(0xFF2E7D32);
      label = 'ACTIVE';
    } else if (status == 'cancelled') {
      color = const Color(0xFFD32F2F);
      label = 'CANCELLED';
    } else {
      color = const Color(0xFFD32F2F);
      label = 'EXPIRED';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}