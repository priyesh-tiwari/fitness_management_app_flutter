import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_management_app/features/subscriptions/provider/subscription_provider.dart';

class StripeCheckoutWebView extends ConsumerStatefulWidget {
  final String checkoutUrl;
  final String sessionId;

  const StripeCheckoutWebView({
    super.key,
    required this.checkoutUrl,
    required this.sessionId,
  });

  @override
  ConsumerState<StripeCheckoutWebView> createState() => _StripeCheckoutWebViewState();
}

class _StripeCheckoutWebViewState extends ConsumerState<StripeCheckoutWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _checkUrl(url);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _checkUrl(String url) async {
    print('WebView URL: $url');

    // Check if payment was successful
    if (url.contains('success') && !_isVerifying) {
      setState(() => _isVerifying = true);
      
      // Verify payment with backend
      final result = await ref
          .read(subscriptionProvider.notifier)
          .verifyPayment(widget.sessionId);

      if (!mounted) return;

      if (result != null && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription activated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['message'] ?? 'Payment verification failed'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context, false);
      }
    } else if (url.contains('cancel')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading || _isVerifying)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}