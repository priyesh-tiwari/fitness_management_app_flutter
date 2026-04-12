import 'package:fitness_management_app/config/constants.dart';
import 'package:fitness_management_app/features/programs/provider/program_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// CreateProgramScreen

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  ConsumerState<CreateProgramScreen> createState() => _CreateProgramScreenState();
}

class _CreateProgramScreenState extends ConsumerState<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController            = TextEditingController();
  final _descriptionController     = TextEditingController();
  final _priceController           = TextEditingController();
  final _locationController        = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  // Dropdown values
  String? _selectedProgramType;
  String? _selectedDifficulty;

  // Schedule
  List<String> _selectedDays = [];
  TimeOfDay?   _startTime;
  TimeOfDay?   _endTime;

  final _programTypes = ['yoga', 'gym', 'cardio', 'strength', 'zumba'];
  final _difficulties = ['beginner', 'intermediate', 'advanced'];
  final _weekDays     = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  // ── Handlers ────────────────────────────────────────────────

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => isStartTime ? _startTime = picked : _endTime = picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour   = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _createProgram() async {
    print('Create program run succesfully!');
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProgramType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a program type')),
      );
      return;
    }

    final success = await ref.read(programProvider.notifier).createProgram(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      programType:     _selectedProgramType!,
      price:           double.parse(_priceController.text.trim()),
      days:            _selectedDays.isNotEmpty ? _selectedDays : null,
      startTime:       _startTime != null ? _formatTimeOfDay(_startTime!) : null,
      endTime:         _endTime   != null ? _formatTimeOfDay(_endTime!)   : null,
      maxParticipants: _maxParticipantsController.text.trim().isNotEmpty
          ? int.parse(_maxParticipantsController.text.trim())
          : null,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      difficulty: _selectedDifficulty,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Program created successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create program'), backgroundColor: Colors.red),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final programState = ref.watch(programProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: AppTheme.textPrimary, size: 22.w),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Program',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: programState.isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2.5.w))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Basic Information ───────────────────────
                    _buildSectionHeader('Basic Information'),
                    SizedBox(height: 16.h),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Program Name',
                      hint: 'e.g., Morning Yoga',
                      icon: Icons.fitness_center_rounded,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Program name is required' : null,
                    ),

                    SizedBox(height: 14.h),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
                      decoration: _inputDecoration(
                        label: 'Description',
                        hint: 'Describe your program',
                        icon: Icons.notes_rounded,
                      ).copyWith(
                        contentPadding: EdgeInsets.all(16.w),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    DropdownButtonFormField<String>(
                      value: _selectedProgramType,
                      decoration: _inputDecoration(
                        label: 'Program Type',
                        hint: '',
                        icon: Icons.category_rounded,
                      ),
                      items: _programTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type[0].toUpperCase() + type.substring(1),
                          style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
                        ),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedProgramType = value),
                    ),

                    SizedBox(height: 14.h),

                    DropdownButtonFormField<String>(
                      value: _selectedDifficulty,
                      decoration: _inputDecoration(
                        label: 'Difficulty Level',
                        hint: '',
                        icon: Icons.trending_up_rounded,
                      ),
                      items: _difficulties.map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(
                          d[0].toUpperCase() + d.substring(1),
                          style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
                        ),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedDifficulty = value),
                    ),

                    SizedBox(height: 32.h),

                    // ── Pricing & Capacity ──────────────────────
                    _buildSectionHeader('Pricing & Capacity'),
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'Price (₹)',
                            hint: '1000',
                            icon: Icons.currency_rupee_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) return 'Required';
                              if (double.tryParse(value) == null) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _maxParticipantsController,
                            label: 'Max Participants',
                            hint: '20',
                            icon: Icons.people_outline_rounded,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // ── Schedule ────────────────────────────────
                    _buildSectionHeader('Schedule'),
                    SizedBox(height: 16.h),

                    // Day chips
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Training Days',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                              color: AppTheme.textMuted,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: _weekDays.map((day) {
                              final isSelected = _selectedDays.contains(day);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelected
                                        ? _selectedDays.remove(day)
                                        : _selectedDays.add(day);
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.primary : AppTheme.background,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    day.substring(0, 3),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Time pickers
                    Row(
                      children: [
                        Expanded(child: _buildTimePicker(context, isStart: true)),
                        SizedBox(width: 12.w),
                        Expanded(child: _buildTimePicker(context, isStart: false)),
                      ],
                    ),

                    SizedBox(height: 32.h),

                    // ── Location ────────────────────────────────
                    _buildSectionHeader('Location'),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Training Location',
                      hint: 'e.g., Main Hall, Studio A',
                      icon: Icons.location_on_rounded,
                    ),

                    SizedBox(height: 32.h),

                    // ── Submit ──────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        onPressed: _createProgram,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Create Program',
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Reusable Widgets ─────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, {required bool isStart}) {
    final time  = isStart ? _startTime : _endTime;
    final label = isStart ? 'Start Time' : 'End Time';

    return InkWell(
      onTap: () => _selectTime(context, isStart),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(7.w),
              decoration: BoxDecoration(
                color: time != null ? AppTheme.accentLight : AppTheme.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.access_time_rounded,
                size: 16.w,
                color: time != null ? AppTheme.primary : AppTheme.textMuted,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11.sp, color: AppTheme.textMuted)),
                  SizedBox(height: 2.h),
                  Text(
                    time != null ? time.format(context) : 'Select',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: time != null ? AppTheme.textPrimary : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: AppTheme.textMuted.withOpacity(0.6), fontSize: 14.sp),
      labelStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14.sp),
      floatingLabelStyle: TextStyle(color: AppTheme.primary, fontSize: 13.sp),
      filled: true,
      fillColor: AppTheme.surface,
      prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppTheme.primary, width: 1.5.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.5.w),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary),
      decoration: _inputDecoration(label: label, hint: hint, icon: icon),
      validator: validator,
    );
  }
}