import 'package:fitness_management_app/features/auth/screens/email_signup_screen.dart';
import 'package:fitness_management_app/features/auth/screens/login_screen.dart';
import 'package:fitness_management_app/config/constants.dart';
import 'package:flutter/material.dart';

class PhoneSignupScreen extends StatefulWidget {
  const PhoneSignupScreen({Key? key}) : super(key: key);

  @override
  State<PhoneSignupScreen> createState() => _PhoneSignupScreenState();
}

class _PhoneSignupScreenState extends State<PhoneSignupScreen> {
  final _phoneController = TextEditingController();

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
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.064,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(flex: isLandscape ? 1 : 3),
                
                Text(
                  'Enter mobile number',
                  style: TextStyle(
                    fontSize: isTablet ? 40 : (isLandscape ? 24 : 32),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: isLandscape ? 8 : 12),

                Text(
                  'You may receive SMS notifications from us for security and login purposes',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : (isLandscape ? 12 : 14),
                    color: AppTheme.textMuted,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isLandscape ? 16 : 24),

                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Mobile number',
                    hintStyle: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: isTablet ? 16 : 14,
                    ),
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(27),
                      borderSide: BorderSide(
                        color: AppTheme.border,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(27),
                      borderSide: BorderSide(
                        color: AppTheme.border,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(27),
                      borderSide: BorderSide(
                        color: AppTheme.primary,
                        width: 1,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: isLandscape ? 12 : 16,
                    ),
                  ),
                ),
                SizedBox(height: isLandscape ? 12 : 20),

                SizedBox(
                  width: double.infinity,
                  height: isLandscape ? 48 : 54,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('NOT IMPLEMENTED THIS FUNCTIONALITY!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Next',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isLandscape ? 10 : 16),

                SizedBox(
                  width: double.infinity,
                  height: isLandscape ? 48 : 54,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmailSignupScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      side: BorderSide(
                        color: AppTheme.border,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Sign up with Email',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: isTablet ? 17 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                Spacer(flex: isLandscape ? 1 : 2),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?  ',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: isTablet ? 15 : (isLandscape ? 11 : 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => LoginScreen()),
  (route) => false,
);},
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 15 : (isLandscape ? 11 : 13),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isLandscape ? 12 : 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}