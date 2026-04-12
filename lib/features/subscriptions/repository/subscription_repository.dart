import 'package:fitness_management_app/features/subscriptions/models/subscription_model.dart';
import 'package:fitness_management_app/features/subscriptions/services/subscription_services.dart';

class SubscriptionRepository {
  final SubscriptionService _service = SubscriptionService();

  Future<Map<String, dynamic>?> initiateSubscription(String programId) async {
    final response = await _service.initiateSubscription(programId);
    
    if (response['success'] == true) {
      return response;
    }
    
    return null;
  }

  Future<List<Subscription>> getMySubscriptions({String? status}) async {
    final response = await _service.getMySubscriptions(status: status);
    
    if (response['success'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((sub) => Subscription.fromJson(sub))
          .toList();
    }
    
    return [];
  }

  Future<String?> getSubscriptionQR(String subscriptionId) async {
    final response = await _service.getSubscriptionQR(subscriptionId);
    
    if (response['success'] == true && response['data']?['qrCodeImage'] != null) {
      return response['data']['qrCodeImage'];
    }
    
    return null;
  }

  Future<bool> cancelSubscription(String subscriptionId, String? reason) async {
    final response = await _service.cancelSubscription(subscriptionId, reason);
    return response['success'] == true;
  }

  Future<Map<String, dynamic>?> renewSubscription(String subscriptionId) async {
    final response = await _service.renewSubscription(subscriptionId);
    
    if (response['success'] == true) {
      return response;
    }
    
    return null;
  }

  // NEW METHOD
  Future<Map<String, dynamic>?> verifyPayment(String sessionId) async {
    final response = await _service.verifyPayment(sessionId);
    
    if (response['success'] == true) {
      return response;
    }
    
    return null;
  }
}