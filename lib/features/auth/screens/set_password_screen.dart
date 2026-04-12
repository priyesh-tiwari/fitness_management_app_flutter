import 'package:fitness_management_app/features/auth/providers/auth_provider.dart';
import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fitness_management_app/features/auth/screens/name_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  final String email;
  const SetPasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final _passwordController = TextEditingController();

  Future<void> _createPassword() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .createPassword(widget.email, password);

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NameScreen(),
        ),
      );
    } else {
      final error = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;
    
    final authState = ref.watch(authProvider);
    
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
                
                Container(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create a password',
                        style: TextStyle(
                          fontSize: isTablet ? 28 : (isLandscape ? 20 : 24),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: isLandscape ? 6 : 8),
                      
                      Text(
                        'For security, your password must be 6 characters or more.',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : (isLandscape ? 12 : 14),
                          color: AppTheme.textMuted,
                        ),
                      ),
                      SizedBox(height: isLandscape ? 16 : 24),
                      
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: isTablet ? 16 : 14,
                          ),
                          filled: false,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: AppTheme.border,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: AppTheme.primary,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: isLandscape ? 12 : 16,
                          ),
                        ),
                      ),
                      SizedBox(height: isLandscape ? 12 : 16),
                      
                      SizedBox(
                        width: double.infinity,
                        height: isLandscape ? 48 : 50,
                        child: ElevatedButton(
                          onPressed: authState.isLoading ? null : _createPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: authState.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : Text(
                                  'Next',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Spacer(flex: isLandscape ? 1 : 2),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
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
                          fontWeight: FontWeight.w500,
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
    _passwordController.dispose();
    super.dispose();
  }
}