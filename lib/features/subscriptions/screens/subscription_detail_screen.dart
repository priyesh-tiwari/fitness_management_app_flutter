import 'dart:convert';
import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/subscriptions/provider/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SubscriptionDetailScreen
// ─────────────────────────────────────────────────────────────────────────────
class SubscriptionDetailScreen extends ConsumerStatefulWidget {
  final dynamic subscription;

  const SubscriptionDetailScreen({super.key, required this.subscription});

  @override
  ConsumerState<SubscriptionDetailScreen> createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends ConsumerState<SubscriptionDetailScreen> {
  String? qrCodeImage;
  bool isLoadingQR = false;

  @override
  void initState() {
    super.initState();
    if (widget.subscription.isActive && widget.subscription.paymentStatus == 'completed') {
      _loadQRCode();
    }
  }

  // ── Handlers ────────────────────────────────────────────────

  Future<void> _loadQRCode() async {
    setState(() => isLoadingQR = true);
    final qrData = await ref
        .read(subscriptionProvider.notifier)
        .getSubscriptionQR(widget.subscription.id);
    setState(() {
      qrCodeImage  = qrData;
      isLoadingQR  = false;
    });
  }

  Future<void> _showCancelDialog() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppTheme.kSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
          title: Text(
            'Cancel Subscription',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: AppTheme.kTextPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to cancel this subscription?',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.kTextMuted),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason (optional)',
                  labelStyle: TextStyle(color: AppTheme.kTextMuted, fontSize: 14.sp),
                  filled: true,
                  fillColor: AppTheme.kBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.kBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.kBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.kPrimary, width: 1.5.w),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep', style: TextStyle(color: AppTheme.kTextMuted, fontWeight: FontWeight.w600)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
              child: const Text('Yes, Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );

    if (reason != null) {
      final success = await ref
          .read(subscriptionProvider.notifier)
          .cancelSubscription(widget.subscription.id, reason);
      if (success && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Subscription cancelled')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _renewSubscription() async {
    final result = await ref
        .read(subscriptionProvider.notifier)
        .renewSubscription(widget.subscription.id);
    if (!mounted) return;
    if (result != null && result['url'] != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Opening payment page...')));
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final subscription = widget.subscription;
    final program      = subscription.program;
    final isActive     = subscription.isActive;

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
          'Subscription Details',
          style: TextStyle(color: AppTheme.kTextPrimary, fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        actions: [
          if (isActive)
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: AppTheme.kTextPrimary, size: 22.w),
              onPressed: _loadQRCode,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── QR / Status Hero ────────────────────────────────
            if (isActive && subscription.paymentStatus == 'completed')
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
                color: AppTheme.kSurface,
                child: Column(
                  children: [
                    Text(
                      'Attendance QR Code',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppTheme.kTextPrimary),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Show this at the gym to mark attendance',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.sp, color: AppTheme.kTextMuted),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppTheme.kBackground,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppTheme.kBorder),
                      ),
                      child: isLoadingQR
                          ? SizedBox(
                              height: 220.w,
                              width: 220.w,
                              child: Center(
                                child: CircularProgressIndicator(color: AppTheme.kPrimary, strokeWidth: 2.5.w),
                              ),
                            )
                          : qrCodeImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.memory(
                                    base64Decode(qrCodeImage!.split(',').last),
                                    height: 220.w,
                                    width: 220.w,
                                  ),
                                )
                              : SizedBox(
                                  height: 220.w,
                                  width: 220.w,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.qr_code_outlined, size: 64.w, color: AppTheme.kBorder),
                                      SizedBox(height: 12.h),
                                      Text('Failed to load QR', style: TextStyle(color: AppTheme.kTextMuted, fontSize: 13.sp)),
                                    ],
                                  ),
                                ),
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                      decoration: BoxDecoration(color: AppTheme.kAccentLight, borderRadius: BorderRadius.circular(8.r)),
                      child: Text(
                        'Valid until ${_formatDate(subscription.expiryDate)}',
                        style: TextStyle(color: AppTheme.kPrimary, fontSize: 13.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(32.w),
                color: AppTheme.kSurface,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(color: AppTheme.kBackground, shape: BoxShape.circle),
                      child: Icon(Icons.info_outline_rounded, size: 40.w, color: AppTheme.kTextMuted),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      subscription.status == 'expired'
                          ? 'Subscription Expired'
                          : subscription.status == 'cancelled'
                              ? 'Subscription Cancelled'
                              : 'Payment Pending',
                      style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppTheme.kTextPrimary),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subscription.status == 'expired'
                          ? 'Renew your subscription to get access'
                          : subscription.status == 'cancelled'
                              ? 'This subscription has been cancelled'
                              : 'Complete payment to activate',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.kTextMuted, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 16.h),

            // ── Info Cards ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  // Program details
                  if (program != null)
                    _buildInfoCard(
                      title: 'Program Details',
                      children: [
                        _buildDetailRow('Name', program.name),
                        _buildDetailRow('Type', program.programType.toUpperCase()),
                        _buildDetailRow('Price', '₹${program.price.toStringAsFixed(0)}'),
                      ],
                    ),

                  SizedBox(height: 14.h),

                  // Subscription info
                  _buildInfoCard(
                    title: 'Subscription Info',
                    children: [
                      _buildDetailRow('Status', subscription.status.toUpperCase()),
                      _buildDetailRow('Start Date', _formatDate(subscription.startDate)),
                      _buildDetailRow('Expiry Date', _formatDate(subscription.expiryDate)),
                      _buildDetailRow('Total Visits', '${subscription.attendanceCount}'),
                      _buildDetailRow('Payment', subscription.paymentStatus.toUpperCase()),
                      if (subscription.paymentDetails?.paidAt != null)
                        _buildDetailRow('Paid On', _formatDate(subscription.paymentDetails.paidAt)),
                    ],
                  ),

                  // Attendance history
                  if (subscription.attendanceHistory.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    _buildInfoCard(
                      title: 'Attendance History',
                      children: subscription.attendanceHistory.map<Widget>((record) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppTheme.kAccentLight,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(7.w),
                                decoration: BoxDecoration(color: AppTheme.kSurface, shape: BoxShape.circle),
                                child: Icon(Icons.check_rounded, color: AppTheme.kPrimary, size: 14.w),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(record.date),
                                      style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.kTextPrimary, fontSize: 14.sp),
                                    ),
                                    if (record.dayOfWeek != null)
                                      Text(record.dayOfWeek!, style: TextStyle(color: AppTheme.kTextMuted, fontSize: 12.sp)),
                                  ],
                                ),
                              ),
                              Text(
                                _formatTime(record.markedAt),
                                style: TextStyle(color: AppTheme.kTextMuted, fontSize: 12.sp, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom action ───────────────────────────────────────────────────────
      bottomNavigationBar: isActive
          ? _buildBottomBar(
              child: OutlinedButton(
                onPressed: _showCancelDialog,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Text(
                  'Cancel Subscription',
                  style: TextStyle(color: const Color(0xFFD32F2F), fontWeight: FontWeight.w700, fontSize: 15.sp),
                ),
              ),
            )
          : subscription.status == 'expired'
              ? _buildBottomBar(
                  child: ElevatedButton(
                    onPressed: _renewSubscription,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: AppTheme.kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Renew Subscription',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
                    ),
                  ),
                )
              : null,
    );
  }

  // ── Reusable Widgets ─────────────────────────────────────────────────────────

  Widget _buildBottomBar({required Widget child}) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      decoration: BoxDecoration(
        color: AppTheme.kSurface,
        border: Border(top: BorderSide(color: AppTheme.kBorder)),
      ),
      child: SafeArea(child: SizedBox(width: double.infinity, child: child)),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppTheme.kSurface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppTheme.kTextPrimary, letterSpacing: -0.2),
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(label, style: TextStyle(color: AppTheme.kTextMuted, fontSize: 13.sp)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.kTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}