import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shopify/shopify.dart';

class CheckoutWebView extends StatefulWidget {
  final String checkoutUrl;

  const CheckoutWebView({super.key, required this.checkoutUrl});

  @override
  _CheckoutWebViewState createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isRedirecting = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            debugPrint("Navigation Request Attempt: $url");

            if (url.contains("thank_you") || url.contains("order-success")) {
              await Shopify.getCheckoutStatus(context);
              if (mounted) Navigator.pop(context);
              return NavigationDecision.prevent;
            }

            // Handle custom schemes for UPI/External Apps (Paytm, PhonePe, GPay, Intent etc.)
            if (!url.toLowerCase().startsWith("http")) {
              if (mounted) {
                setState(() {
                  _isRedirecting = true;
                  _isLoading = false;
                });
              }
              debugPrint("Intercepted non-http navigation: $url");
              try {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  debugPrint("Could not launch external app for: $url");
                }
              } catch (e) {
                debugPrint("Error launching external app: $e");
              }
              // Forcefully prevent any non-web URL from loading in the WebView
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("Web Resource Error: ${error.errorCode}, ${error.description}, ${error.url}");
            
            final url = error.url ?? "";
            if (!url.toLowerCase().startsWith("http") && url.isNotEmpty) {
              if (mounted) {
                setState(() {
                  _isRedirecting = true;
                  _isLoading = false;
                });
              }
              // Hide the error screen by loading a clean blank page/loader
              _controller.loadHtmlString("""
                <!DOCTYPE html><html><body style='display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;'>
                  <h3 style='color:#26842c'>Redirecting to payment app...</h3>
                </body></html>
              """);
            }
          },
          onUrlChange: (UrlChange change) {
            debugPrint("URL Changed to: ${change.url}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading && !_isRedirecting)
            const Center(
              child: CircularProgressIndicator(color: Color(0xff26842c)),
            ),
        ],
      ),
    );
  }
}
