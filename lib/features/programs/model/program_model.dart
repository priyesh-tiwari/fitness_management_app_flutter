class Program {
  final String id;
  final String name;
  final String? description;
  final Trainer trainer;
  final Schedule? schedule;
  final String programType;
  final double price;
  final int duration;
  final Capacity? capacity;
  final String? location;
  final String? difficulty;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Program({
    required this.id,
    required this.name,
    this.description,
    required this.trainer,
    this.schedule,
    required this.programType,
    required this.price,
    this.duration = 30,
    this.capacity,
    this.location,
    this.difficulty,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
  return Program(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    trainer: json['trainer'] is String
        ? Trainer(id: json['trainer'], name: '', email: '')  // If just ID
        : Trainer.fromJson(json['trainer'] ?? {}),  // If populated object
    schedule: json['schedule'] != null ? Schedule.fromJson(json['schedule']) : null,
    programType: json['programType'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    duration: json['duration'] ?? 30,
    capacity: json['capacity'] != null ? Capacity.fromJson(json['capacity']) : null,
    location: json['location'],
    difficulty: json['difficulty'],
    status: json['status'] ?? 'active',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
  );
}

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'trainer': trainer.toJson(),
      'schedule': schedule?.toJson(),
      'programType': programType,
      'price': price,
      'duration': duration,
      'capacity': capacity?.toJson(),
      'location': location,
      'difficulty': difficulty,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Trainer {
  final String id;
  final String name;
  final String email;
  final String? profileImage;

  Trainer({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
    };
  }
}

class Schedule {
  final List<String> days;
  final TimeSlot? time;

  Schedule({
    required this.days,
    this.time,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      days: List<String>.from(json['days'] ?? []),
      time: json['time'] != null ? TimeSlot.fromJson(json['time']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'time': time?.toJson(),
    };
  }
}

class TimeSlot {
  final String start;
  final String end;

  TimeSlot({
    required this.start,
    required this.end,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }
}

class Capacity {
  final int? maxParticipants;
  final int currentActive;

  Capacity({
    this.maxParticipants,
    this.currentActive = 0,
  });

  factory Capacity.fromJson(Map<String, dynamic> json) {
    return Capacity(
      maxParticipants: json['maxParticipants'],
      currentActive: json['currentActive'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxParticipants': maxParticipants,
      'currentActive': currentActive,
    };
  }
}

class ProgramsResponse {
  final bool success;
  final List<Program> programs;
  final Pagination? pagination;

  ProgramsResponse({
    required this.success,
    required this.programs,
    this.pagination,
  });

  factory ProgramsResponse.fromJson(Map<String, dynamic> json) {
    return ProgramsResponse(
      success: json['success'] ?? false,
      programs: (json['data'] as List?)
          ?.map((program) => Program.fromJson(program))
          .toList() ?? [],
      pagination: json['pagination'] != null 
          ? Pagination.fromJson(json['pagination']) 
          : null,
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalProgram;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalProgram,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalProgram: json['totalProgram'] ?? 0,
      limit: json['limit'] ?? 10,
    );
  }
}