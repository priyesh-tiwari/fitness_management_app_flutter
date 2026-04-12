import 'package:fitness_management_app/features/subscriptions/models/subscription_model.dart';
import 'package:fitness_management_app/features/subscriptions/repository/subscription_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionState {
  final bool isLoading;
  final List<Subscription> subscriptions;
  final String? error;
  final String? checkoutUrl;
  final String? qrCodeImage;

  SubscriptionState({
    this.isLoading = false,
    this.subscriptions = const [],
    this.error,
    this.checkoutUrl,
    this.qrCodeImage,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    List<Subscription>? subscriptions,
    String? error,
    String? checkoutUrl,
    String? qrCodeImage,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      subscriptions: subscriptions ?? this.subscriptions,
      error: error,
      checkoutUrl: checkoutUrl,
      qrCodeImage: qrCodeImage,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository _repository = SubscriptionRepository();

  SubscriptionNotifier() : super(SubscriptionState());

  Future<Map<String, dynamic>?> initiateSubscription(String programId) async {
  state = state.copyWith(isLoading: true, error: null);

  final result = await _repository.initiateSubscription(programId);
  
  print('Provider received result: $result'); // Debug log

  if (result != null && result['success'] == true) {
    state = state.copyWith(isLoading: false);

    // If checkout URL exists, return it
    if (result['data']?['url'] != null) {
      final checkoutUrl = result['data']['url'];
      print('Checkout URL found: $checkoutUrl'); // Debug log
      
      final returnData = {
        'type': 'checkout',
        'url': checkoutUrl,
        'sessionId': result['data']['sessionId'],
      };
      print('Returning data: $returnData'); // Debug log
      return returnData;
    }

    // If subscription created (free program)
    if (result['data']?['subscription'] != null) {
      await getMySubscriptions(); // Refresh list
      return {
        'type': 'success',
        'message': result['message'],
      };
    }
    
    return result;
  } else {
    state = state.copyWith(
      isLoading: false,
      error: result?['message'] ?? 'Failed to initiate subscription',
    );
    return null;
  }
}

  Future<void> getMySubscriptions({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);

    final subscriptions = await _repository.getMySubscriptions(status: status);

    state = state.copyWith(
      isLoading: false,
      subscriptions: subscriptions,
    );
  }

  // Get QR code
  Future<String?> getSubscriptionQR(String subscriptionId) async {
    final qrData = await _repository.getSubscriptionQR(subscriptionId);

    if (qrData != null) {
      state = state.copyWith(qrCodeImage: qrData);
      return qrData;
    }
    
    return null;
  }

  // Cancel subscription
  Future<bool> cancelSubscription(String subscriptionId, String? reason) async {
    state = state.copyWith(isLoading: true, error: null);

    final success = await _repository.cancelSubscription(subscriptionId, reason);

    if (success) {
      await getMySubscriptions(); // Refresh list
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to cancel subscription',
      );
      return false;
    }
  }

  // Renew subscription
  Future<Map<String, dynamic>?> renewSubscription(String subscriptionId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.renewSubscription(subscriptionId);

    if (result != null) {
      state = state.copyWith(isLoading: false);
      return result;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to renew subscription',
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyPayment(String sessionId) async {
  try {
    final result = await _repository.verifyPayment(sessionId);
    
    if (result != null) {
      // Refresh subscriptions list
      await getMySubscriptions();
    }
    
    return result;
  } catch (e) {
    state = state.copyWith(error: e.toString());
    return null;
  }
}

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});
