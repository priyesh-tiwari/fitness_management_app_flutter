import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final images = [
    'assets/landing_fitness_01.png',
    'assets/landing_fitness_02.png',
    'assets/landing_fitness_03.png',
    'assets/landing_fitness_05.png',
  ];

  final titles = [
    'Track Your Daily Fitness',
    'Personalized Programs & Plans',
    'AI-Powered Fitness Insights',
    'Trainer Management Dashboard',
  ];

  final descriptions = [
    'Monitor calories burned, workout time, water intake, and daily goals in one simple dashboard.',
    'Access guided workout programs, choose subscription plans, and follow routines designed for your fitness goals.',
    'Get smart recommendations, progress reports, and personalized guidance powered by AI.',
    'Create programs, track attendance, monitor member progress, and manage clients from one dashboard.',
  ];

  late PageController _controller;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final path in images) {
      precacheImage(AssetImage(path), context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppTheme.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;

          return Stack(
            children: [
              // PageView with images and text
              PageView.builder(
                controller: _controller,
                itemCount: images.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemBuilder: (_, index) {
                  return Container(
                    color: AppTheme.background,
                    child: isLandscape
                        // ── Landscape: image left, text right ──
                        ? Row(
                            children: [
                              SizedBox(width: 24.w),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: topPadding + 60.h,
                                    bottom: bottomPadding + 80.h,
                                  ),
                                  child: Image.asset(
                                    images[index],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(width: 24.w),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: topPadding + 60.h,
                                    bottom: bottomPadding + 80.h,
                                    right: 24.w,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        titles[index],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22.sp,
                                          color: AppTheme.textPrimary,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        descriptions[index],
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppTheme.textMuted,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        // ── Portrait: stacked layout ──
                        : Column(
                            children: [
                              SizedBox(height: topPadding + 80.h),

                              // Title
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: Text(
                                  titles[index],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28.sp,
                                    color: AppTheme.textPrimary,
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: 12.h),

                              // Description
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 35.w),
                                child: Text(
                                  descriptions[index],
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppTheme.textMuted,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              SizedBox(height: 30.h),

                              // Image
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                                  child: Image.asset(
                                    images[index],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              SizedBox(height: bottomPadding + 110.h),
                            ],
                          ),
                  );
                },
              ),

              // Top overlay - Progress bar, back and skip buttons
              Positioned(
                top: topPadding + 8.h,
                left: 20.w,
                right: 20.w,
                child: Column(
                  children: [
                    // Progress Indicator Bar
                    Row(
                      children: List.generate(
                        images.length,
                        (index) => Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 2.w),
                            height: 3.h,
                            decoration: BoxDecoration(
                              color: currentPage >= index
                                  ? AppTheme.primary
                                  : AppTheme.border,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Navigation Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        currentPage > 0
                            ? IconButton(
                                onPressed: () {
                                  _controller.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: AppTheme.textPrimary,
                                  size: 24.sp,
                                ),
                              )
                            : SizedBox(width: 48.w),
                        const Spacer(),
                        // Skip Button
                        if (currentPage < images.length - 1)
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: AppTheme.surface,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 8.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        else
                          SizedBox(width: 48.w),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom overlay - Next/Get Started button
              Positioned(
                bottom: bottomPadding + 30.h,
                left: 20.w,
                right: 20.w,
                child: SizedBox(
                  width: double.infinity,
                  height: isLandscape ? 48.h : 54.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (currentPage < images.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    child: Text(
                      currentPage == images.length - 1 ? "Get Started" : "Next",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}