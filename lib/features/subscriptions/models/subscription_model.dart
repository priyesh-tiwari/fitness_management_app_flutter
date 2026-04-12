
import 'package:fitness_management_app/features/programs/model/program_model.dart';

class Subscription {
  final String id;
  final String userId;
  final String programId;
  final String? qrCode;
  final DateTime startDate;
  final DateTime expiryDate;
  final String status;
  final int attendanceCount;
  final List<AttendanceRecord> attendanceHistory;
  final String paymentStatus;
  final PaymentDetails? paymentDetails;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final Program? program;
  final SubscriptionUser? user;

  Subscription({
    required this.id,
    required this.userId,
    required this.programId,
    this.qrCode,
    required this.startDate,
    required this.expiryDate,
    required this.status,
    this.attendanceCount = 0,
    this.attendanceHistory = const [],
    required this.paymentStatus,
    this.paymentDetails,
    this.cancellationReason,
    this.cancelledAt,
    required this.createdAt,
    this.program,
    this.user,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] ?? '',
      userId: json['user'] is String ? json['user'] : (json['user']?['_id'] ?? ''),
      programId: json['program'] is String ? json['program'] : (json['program']?['_id'] ?? ''),
      qrCode: json['qrCode'],
      startDate: DateTime.parse(json['startDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      status: json['status'] ?? 'active',
      attendanceCount: json['attendanceCount'] ?? 0,
      attendanceHistory: (json['attendanceHistory'] as List?)
          ?.map((record) => AttendanceRecord.fromJson(record))
          .toList() ?? [],
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentDetails: json['paymentDetails'] != null 
          ? PaymentDetails.fromJson(json['paymentDetails']) 
          : null,
      cancellationReason: json['cancellationReason'],
      cancelledAt: json['cancelledAt'] != null 
          ? DateTime.parse(json['cancelledAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      program: json['program'] is Map ? Program.fromJson(json['program']) : null,
      user: json['user'] is Map ? SubscriptionUser.fromJson(json['user']) : null,
    );
  }

  bool get isActive => status == 'active' && expiryDate.isAfter(DateTime.now());
}

class AttendanceRecord {
  final DateTime date;
  final DateTime markedAt;
  final String? dayOfWeek;

  AttendanceRecord({
    required this.date,
    required this.markedAt,
    this.dayOfWeek,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date']),
      markedAt: DateTime.parse(json['markedAt'] ?? json['date']),
      dayOfWeek: json['dayOfWeek'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'markedAt': markedAt.toIso8601String(),
      'dayOfWeek': dayOfWeek,
    };
  }
}

class PaymentDetails {
  final String? transactionId;
  final double? amount;
  final String? paymentMethod;
  final DateTime? paidAt;

  PaymentDetails({
    this.transactionId,
    this.amount,
    this.paymentMethod,
    this.paidAt,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      transactionId: json['transactionId'],
      amount: json['amount']?.toDouble(),
      paymentMethod: json['paymentMethod'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }
}

class SubscriptionUser {
  final String id;
  final String name;
  final String email;
  final String? profileImage;

  SubscriptionUser({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
  });

  factory SubscriptionUser.fromJson(Map<String, dynamic> json) {
    return SubscriptionUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'],
    );
  }
}

class SubscriptionsResponse {
  final bool success;
  final List<Subscription> subscriptions;
  final Pagination? pagination;

  SubscriptionsResponse({
    required this.success,
    required this.subscriptions,
    this.pagination,
  });

  factory SubscriptionsResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionsResponse(
      success: json['success'] ?? false,
      subscriptions: (json['data'] as List?)
          ?.map((sub) => Subscription.fromJson(sub))
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
  final int totalSubscriptions;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalSubscriptions,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalSubscriptions: json['totalSubscriptions'] ?? 0,
      limit: json['limit'] ?? 10,
    );
  }
}