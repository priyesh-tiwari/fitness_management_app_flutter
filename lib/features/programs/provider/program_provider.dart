import 'package:fitness_management_app/features/programs/model/program_model.dart';
import 'package:fitness_management_app/features/programs/repository/program_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Program State
class ProgramState {
  final bool isLoading;
  final List<Program> programs;
  final Program? selectedProgram;
  final String? error;
  final Pagination? pagination;
  final Map<String, String> filters;
  final Map<String, dynamic>? programSubscribers;

  ProgramState({
    this.isLoading = false,
    this.programs = const [],
    this.selectedProgram,
    this.error,
    this.pagination,
    this.filters = const {},
    this.programSubscribers,
  });

  ProgramState copyWith({
    bool? isLoading,
    List<Program>? programs,
    Program? selectedProgram,
    String? error,
    Pagination? pagination,
    Map<String, String>? filters,
    Map<String, dynamic>? programSubscribers,
  }) {
    return ProgramState(
      isLoading: isLoading ?? this.isLoading,
      programs: programs ?? this.programs,
      selectedProgram: selectedProgram ?? this.selectedProgram,
      error: error,
      pagination: pagination ?? this.pagination,
      filters: filters ?? this.filters,
      programSubscribers: programSubscribers ?? this.programSubscribers,
    );
  }
}

// Program Notifier
class ProgramNotifier extends StateNotifier<ProgramState> {
  final ProgramRepository _repository = ProgramRepository();

  ProgramNotifier() : super(ProgramState()) {
    getAllPrograms();
  }

  Future<void> getAllPrograms({
    int page = 1,
    int limit = 10,
    String? programType,
    String? difficulty,
    String? trainer,
    int? minPrice,
    int? maxPrice,
    String? search,
    String? sortBy,
    String? order,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _repository.getAllPrograms(
      page: page,
      limit: limit,
      programType: programType,
      difficulty: difficulty,
      trainer: trainer,
      minPrice: minPrice,
      maxPrice: maxPrice,
      search: search,
      sortBy: sortBy,
      order: order,
    );

    if (response != null) {
      state = state.copyWith(
        isLoading: false,
        programs: response.programs,
        pagination: response.pagination,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load programs',
      );
    }
  }

  // Load more programs (for pagination)
  Future<void> loadMorePrograms() async {
    if (state.pagination == null) return;

    final currentPage = state.pagination!.currentPage;
    final totalPages = state.pagination!.totalPages;

    if (currentPage >= totalPages) return;

    final nextPage = currentPage + 1;

    final response = await _repository.getAllPrograms(
      page: nextPage,
      limit: state.pagination!.limit,
    );

    if (response != null) {
      state = state.copyWith(
        programs: [...state.programs, ...response.programs],
        pagination: response.pagination,
      );
    }
  }

  // Get program by ID
  Future<void> getProgramById(String programId) async {
    state = state.copyWith(isLoading: true, error: null);

    final program = await _repository.getProgramById(programId);
    if (program != null) {
      state = state.copyWith(isLoading: false, selectedProgram: program);
    } else {
      state = state.copyWith(isLoading: false, error: 'Program not found');
    }
  }

  // Get programs by trainer
  Future<void> getProgramsByTrainer(String trainerId) async {
    state = state.copyWith(isLoading: true, error: null);

    final programs = await _repository.getProgramsByTrainer(trainerId);

    state = state.copyWith(
      isLoading: false,
      programs: programs,
    );
  }

  // Create program (Trainer only)
  Future<bool> createProgram({
    required String name,
    String? description,
    required String programType,
    required double price,
    List<String>? days,
    String? startTime,
    String? endTime,
    int? maxParticipants,
    String? location,
    String? difficulty,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final program = await _repository.createProgram(
      name: name,
      description: description,
      programType: programType,
      price: price,
      days: days,
      startTime: startTime,
      endTime: endTime,
      maxParticipants: maxParticipants,
      location: location,
      difficulty: difficulty,
    );

    if (program != null) {
      state = state.copyWith(
        isLoading: false,
        programs: [program, ...state.programs],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create program',
      );
      return false;
    }
  }

  // Update program
  Future<bool> updateProgram(
    String programId,
    Map<String, dynamic> updates,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    final updatedProgram = await _repository.updateProgram(programId, updates);

    if (updatedProgram != null) {
      final updatedList = state.programs.map((program) {
        return program.id == programId ? updatedProgram : program;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        programs: updatedList,
        selectedProgram: updatedProgram,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update program',
      );
      return false;
    }
  }

  // Delete program
  Future<bool> deleteProgram(String programId) async {
    state = state.copyWith(isLoading: true, error: null);

    final success = await _repository.deleteProgram(programId);

    if (success) {
      final updatedList = state.programs
          .where((program) => program.id != programId)
          .toList();

      state = state.copyWith(
        isLoading: false,
        programs: updatedList,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete program',
      );
      return false;
    }
  }

  // Get program subscribers
  Future<void> getProgramSubscribers(String programId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _repository.getProgramSubscribers(programId);

      if (data != null) {
        state = state.copyWith(
          isLoading: false,
          programSubscribers: data,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'No subscribers found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Search programs
  Future<void> searchPrograms(String query) async {
    await getAllPrograms(search: query);
  }

  // Filter programs
  Future<void> filterPrograms({
    String? programType,
    String? difficulty,
    int? minPrice,
    int? maxPrice,
  }) async {
    await getAllPrograms(
      programType: programType,
      difficulty: difficulty,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  // Sort programs
  Future<void> sortPrograms(String sortBy, String order) async {
    await getAllPrograms(sortBy: sortBy, order: order);
  }

  // Clear selected program
  void clearSelectedProgram() {
    state = state.copyWith(selectedProgram: null);
  }

  // Refresh programs
  Future<void> refreshPrograms() async {
    await getAllPrograms();
  }
}

// Provider
final programProvider =
    StateNotifierProvider<ProgramNotifier, ProgramState>((ref) {
  return ProgramNotifier();
});