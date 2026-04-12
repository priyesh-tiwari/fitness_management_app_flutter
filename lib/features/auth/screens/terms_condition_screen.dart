import 'package:fitness_management_app/home/user_home_page/user_home_screen.dart';
import 'package:fitness_management_app/config/constants.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.064),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isLandscape ? 16 : 24),

                Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontSize: isTablet ? 32 : (isLandscape ? 22 : 28),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: isLandscape ? 3 : 4),

                Text(
                  'Last Updated: February 2026',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : (isLandscape ? 10 : 12),
                    color: AppTheme.textMuted,
                  ),
                ),
                SizedBox(height: isLandscape ? 12 : 18),

                Expanded(
                  flex: 5,
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 24 : 18),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTermsSection(isTablet, isLandscape,
                              title: '1. Acceptance of Terms',
                              content: 'By creating an account on FitTrack, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the app. These terms apply to all users including members and trainers.',
                            ),
                            _buildTermsSection(isTablet, isLandscape,
                              title: '2. User Accounts',
                              content: 'You are responsible for maintaining the confidentiality of your account credentials. You must provide accurate information during registration. FitTrack reserves the right to suspend or terminate accounts that violate these terms.',
                            ),
                            _buildTermsSection(isTablet, isLandscape,
                              title: '3. Trainer Programs',
                              content: 'Trainers may create and list fitness programs including yoga, gym, cardio, and other classes. Trainers are solely responsible for the content, safety, and quality of their programs. FitTrack acts only as a platform and is not liable for any injury or harm resulting from participation in any program.',
                            ),
                            _buildTermsSection(isTablet, isLandscape,
                              title: '4. Subscriptions & Payments',
                              content: 'Users may subscribe to trainer programs by making payments through Stripe. All payments are processed securely. Subscription fees are non-refundable unless the trainer cancels the program. FitTrack is not responsible for any payment disputes between users and trainers.',
                            ),
                            _buildTermsSection(isTablet, isLandscape,
                              title: '5. QR Code & Attendance',
                              content: 'Upon subscribing to a program, users receive a unique QR code that serves as their daily entry pass for each class session. This QR code can only be scanned by the trainer of that program. Sharing, transferring, or misusing your QR code is strictly prohibited and may result in account suspension.',
                            ),
                            _buildTermsSection(isTablet, isLandscape,
                              title: '6. Activity Tracking',
                              content: 'FitTrack allows users to log daily activities including water intake, exercise duration, meditation, and calories burned. This data is used only to provide personal health insights. FitTrack does not provide medical advice. Always consult a healthcare professional before starting any fitness program.',
                            ),
                            _buildTermsSection(isTablet, isLandscape,
                              title: '7. Privacy & Data',
                              content: 'We collect and store personal data necessary to provide our services including your name, email, activity logs, attendance records, and payment history. We do not sell your data to third parties. By using FitTrack, you consent to our data practices.',
                            ),
                            _buildTermsSection(isTablet, isLandscape,
                              title: '8. Prohibited Conduct',
                              content: 'Users must not misuse the platform including creating fake accounts, manipulating attendance records, reverse engineering the app, or engaging in fraudulent payment activity. Violations will result in immediate account termination.',
                            ),
                            _buildTermsSection(isTablet, isLandscape,
                              title: '9. Limitation of Liability',
                              content: 'FitTrack is provided on an "as is" basis. We do not guarantee uninterrupted access to the app. We are not liable for any damages arising from your use of the platform including fitness-related injuries or payment issues.',
                            ),
                            _buildTermsSection(isTablet, isLandscape,
                              title: '10. Changes to Terms',
                              content: 'FitTrack reserves the right to update these Terms at any time. Continued use of the app after changes are posted constitutes your acceptance of the revised terms. We will notify you of significant changes via email or in-app notification.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isLandscape ? 12 : 20),

                SizedBox(
                  width: double.infinity,
                  height: isLandscape ? 48 : 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserHomeScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Accept & Continue',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isLandscape ? 8 : 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsSection(bool isTablet, bool isLandscape, {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 15 : (isLandscape ? 11 : 13),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: isTablet ? 15 : (isLandscape ? 11 : 13),
            color: AppTheme.textPrimary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}