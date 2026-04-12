import 'package:fitness_management_app/features/programs/model/program_model.dart';
import 'package:fitness_management_app/features/programs/services/program_service.dart';

class ProgramRepository {
  final ProgramService _service = ProgramService();

  // Get all programs with filters and pagination
  Future<ProgramsResponse?> getAllPrograms({
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
    final res = await _service.getAllPrograms(
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

    if (res['success'] == true) {
      return ProgramsResponse.fromJson(res);
    }
    return null;
  }

  // Get program by ID
  Future<Program?> getProgramById(String programId) async {
    final res = await _service.getProgramById(programId);

    if (res['success'] == true && res['data'] != null) {
      return Program.fromJson(res['data']);
    }
    return null;
  }

  // Get programs by trainer
  Future<List<Program>> getProgramsByTrainer(String trainerId) async {
    final res = await _service.getProgramsByTrainer(trainerId);

    if (res['success'] == true && res['data'] != null) {
      return (res['data'] as List)
          .map((program) => Program.fromJson(program))
          .toList();
    }
    return [];
  }

  // Create program (Trainer only)
  Future<Program?> createProgram({
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
    print('Create program run succesfully!');
    final res = await _service.createProgram(
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

    if (res['success'] == true && res['data'] != null) {
      return Program.fromJson(res['data']);
    }
    return null;
  }

  // Update program
  Future<Program?> updateProgram(
    String programId,
    Map<String, dynamic> updates,
  ) async {
    final res = await _service.updateProgram(programId, updates);

    if (res['success'] == true && res['data'] != null) {
      return Program.fromJson(res['data']);
    }
    return null;
  }

  // Delete program
  Future<bool> deleteProgram(String programId) async {
    final res = await _service.deleteProgram(programId);
    return res['success'] == true;
  }

  // Get program subscribers (Trainer only)
  Future<Map<String, dynamic>?> getProgramSubscribers(String programId) async {
    final res = await _service.getProgramSubscribers(programId);

    print(res);

    if (res['success'] == true && res['data'] != null) {
      return res['data'];
    }
    return null;
  }
}
