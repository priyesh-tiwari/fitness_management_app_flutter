import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/attendance/services/attendance_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;
  String? lastScannedCode;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _handleQRCode(String qrCode) async {
    if (isProcessing || qrCode == lastScannedCode) return;
    setState(() {
      isProcessing = true;
      lastScannedCode = qrCode;
    });
    await cameraController.stop();

    try {
      final result = await _attendanceService.markAttendance(qrCode);
      if (!mounted) return;
      if (result['success'] == true) {
        _showResultDialog(
          success: true,
          title: 'Attendance Marked!',
          message: result['message'] ?? 'Attendance marked successfully',
          data: result['data'],
        );
      } else {
        _showResultDialog(
          success: false,
          title: 'Failed',
          message: result['message'] ?? 'Failed to mark attendance',
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showResultDialog(
        success: false,
        title: 'Error',
        message: 'An error occurred: $e',
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showResultDialog({
    required bool success,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) {
    final color = success ? const Color(0xFF2E7D32) : AppTheme.danger;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Row(
          children: [
            Icon(
              success
                  ? Icons.check_circle_rounded
                  : Icons.error_outline_rounded,
              color: color,
              size: 24.w,
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 17.sp,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted),
            ),
            if (data != null) ...[
              SizedBox(height: 16.h),
              Divider(color: AppTheme.border),
              SizedBox(height: 8.h),
              if (data['student'] != null) ...[
                _buildInfoRow('Student', data['student']['name']),
                _buildInfoRow('Email', data['student']['email']),
              ],
              if (data['program'] != null)
                _buildInfoRow('Program', data['program']),
              if (data['totalAttendance'] != null)
                _buildInfoRow('Total', '${data['totalAttendance']}'),
              if (data['date'] != null)
                _buildInfoRow('Date', _formatDate(data['date'])),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => lastScannedCode = null);
              cameraController.start();
            },
            child: Text(
              'Scan Next',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPrimary,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Scan QR Code',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              cameraController.torchEnabled == true
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: Icon(Icons.cameraswitch_rounded, color: AppTheme.textPrimary),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                if (barcode.rawValue != null) {
                  _handleQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          CustomPaint(painter: ScannerOverlay(), child: Container()),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Align QR code within the frame to scan',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 15.sp),
              ),
            ),
          ),
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primary,
                        strokeWidth: 2.5.w,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Marking Attendance...',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)))
        ..fillType = PathFillType.evenOdd,
      Paint()
        ..color = Colors.black54
        ..style = PaintingStyle.fill,
    );

    final borderPaint = Paint()
      ..color = const Color(0xFF2E7D32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    const cl = 30.0;

    for (final corner in [
      [Offset(left, top + cl), Offset(left, top), Offset(left + cl, top)],
      [
        Offset(left + scanAreaSize - cl, top),
        Offset(left + scanAreaSize, top),
        Offset(left + scanAreaSize, top + cl),
      ],
      [
        Offset(left, top + scanAreaSize - cl),
        Offset(left, top + scanAreaSize),
        Offset(left + cl, top + scanAreaSize),
      ],
      [
        Offset(left + scanAreaSize - cl, top + scanAreaSize),
        Offset(left + scanAreaSize, top + scanAreaSize),
        Offset(left + scanAreaSize, top + scanAreaSize - cl),
      ],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(corner[0].dx, corner[0].dy)
          ..lineTo(corner[1].dx, corner[1].dy)
          ..lineTo(corner[2].dx, corner[2].dy),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter _) => false;
}
