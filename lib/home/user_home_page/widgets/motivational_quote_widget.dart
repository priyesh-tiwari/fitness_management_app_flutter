import 'dart:math';
import 'package:fitness_management_app/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MotivationalQuote extends StatefulWidget {
  const MotivationalQuote({super.key});

  @override
  State<MotivationalQuote> createState() => _MotivationalQuoteState();
}

class _MotivationalQuoteState extends State<MotivationalQuote> {
  final List<Map<String, String>> _quotes = [
    {
      'quote': 'The only bad workout is the one that didn\'t happen.',
      'author': 'Unknown'
    },
    {
      'quote': 'Your body can stand almost anything. It\'s your mind you have to convince.',
      'author': 'Unknown'
    },
    {
      'quote': 'Success starts with self-discipline.',
      'author': 'Unknown'
    },
    {
      'quote': 'Push yourself, because no one else is going to do it for you.',
      'author': 'Unknown'
    },
    {
      'quote': 'The pain you feel today will be the strength you feel tomorrow.',
      'author': 'Unknown'
    },
    {
      'quote': 'Don\'t limit your challenges. Challenge your limits.',
      'author': 'Unknown'
    },
  ];

  late Map<String, String> _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
  }

  void _refreshQuote() {
    setState(() {
      _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.format_quote,
                color: Colors.white54,
                size: 28.w,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: IconButton(
                  onPressed: _refreshQuote,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                  padding: EdgeInsets.all(8.w),
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            _currentQuote['quote']!,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontStyle: FontStyle.italic,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '— ${_currentQuote['author']}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}