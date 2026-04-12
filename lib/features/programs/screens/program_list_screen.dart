import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/programs/provider/program_provider.dart';
import 'package:fitness_management_app/home/user_home_page/widgets/program_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const _kProgramTypes = ['All', 'yoga', 'gym', 'cardio', 'strength', 'zumba'];
const _kDifficulties = ['All', 'beginner', 'intermediate', 'advanced'];

class ProgramListScreen extends ConsumerStatefulWidget {
  const ProgramListScreen({super.key});

  @override
  ConsumerState<ProgramListScreen> createState() => _ProgramListScreenState();
}

class _ProgramListScreenState extends ConsumerState<ProgramListScreen> {
  final _searchController = TextEditingController();
  String? _selectedType;
  String? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(programProvider.notifier).getAllPrograms());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    query.isEmpty
        ? ref.read(programProvider.notifier).getAllPrograms()
        : ref.read(programProvider.notifier).searchPrograms(query);
  }

  void _applyFilters() {
    ref.read(programProvider.notifier).filterPrograms(
      programType: _selectedType,
      difficulty: _selectedDifficulty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final programState = ref.watch(programProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Fitness Programs',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 20.sp, fontWeight: FontWeight.w700, letterSpacing: -0.3),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showFilterSheet(context),
            child: Container(
              margin: EdgeInsets.only(right: 16.w),
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(10.r)),
              child: Icon(Icons.tune_rounded, color: AppTheme.textPrimary, size: 20.w),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────
          Container(
            color: AppTheme.surface,
            padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 14.h),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search programs…',
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 15.sp),
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 22.w),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 18.w),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
            ),
          ),

          // ── Type Filter Chips ───────────────────────────────
          Container(
            height: 48.h,
            color: AppTheme.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _kProgramTypes.length,
              itemBuilder: (context, index) {
                final type = _kProgramTypes[index];
                final isSelected = (_selectedType == null && type == 'All') || _selectedType == type;
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedType = type == 'All' ? null : type);
                      _applyFilters();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.background,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        type == 'All' ? 'All' : type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 8.h),

          // ── Program List ────────────────────────────────────
          Expanded(
            child: programState.isLoading && programState.programs.isEmpty
                ? Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5.w))
                : programState.programs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.fitness_center_rounded, size: 60.w, color: AppTheme.border),
                            SizedBox(height: 12.h),
                            Text('No programs found', style: TextStyle(fontSize: 16.sp, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4.h),
                            Text('Try adjusting your filters', style: TextStyle(fontSize: 13.sp, color: AppTheme.textMuted)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        onRefresh: () => ref.read(programProvider.notifier).refreshPrograms(),
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          itemCount: programState.programs.length,
                          itemBuilder: (context, index) => ProgramCard(program: programState.programs[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                SizedBox(height: 20.h),
                Text('Filter Programs',
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.3)),
                SizedBox(height: 24.h),
                Text('DIFFICULTY LEVEL',
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 0.8)),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _kDifficulties.map((difficulty) {
                    final isSelected = (_selectedDifficulty == null && difficulty == 'All') || _selectedDifficulty == difficulty;
                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          setState(() => _selectedDifficulty = difficulty == 'All' ? null : difficulty);
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : AppTheme.background,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          difficulty == 'All' ? 'All' : difficulty.toUpperCase(),
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppTheme.textMuted),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: Text('Apply Filters', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}