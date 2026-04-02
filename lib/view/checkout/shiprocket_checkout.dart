import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/meta_events.dart';
import '../../utils/firebase_events.dart';

class ShiprocketCheckout extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double? totalValue;

  const ShiprocketCheckout(
      {super.key, required this.cartItems, this.totalValue});

  @override
  State<ShiprocketCheckout> createState() => _ShiprocketCheckoutState();
}

class _ShiprocketCheckoutState extends State<ShiprocketCheckout>
    with WidgetsBindingObserver {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isSuccessLogged = false;
  bool _isRedirecting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initWebView();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRedirecting) {
      if (mounted) {
        debugPrint("Returning from payment intent. Popping checkout screen.");
        Navigator.pop(context);
      }
    }
  }

  void _showInstallMessage(String url) {
    String appName = "this UPI app";
    if (url.contains("paytm")) appName = "Paytm";
    if (url.contains("phonepe")) appName = "PhonePe";
    if (url.contains("tez") || url.contains("gpay")) appName = "Google Pay";

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please first download $appName to continue."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _initWebView() {
    final cartJson = jsonEncode(widget.cartItems);

    final html = '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <script src="https://fastrr-boost-ui.pickrr.com/assets/js/channels/mobileApp.js"></script>
    </head>
    <body style="margin:0;padding:0;display:flex;justify-content:center;align-items:center;height:100vh;font-family:sans-serif;">
    
    <div id="loader">Redirecting to checkout...</div>

    <script>
      function startCheckout() {
        try {
          if (typeof window.getOneClickCheckoutUrl === "function") {
            const items = $cartJson;

            const checkoutUrl = window.getOneClickCheckoutUrl({
              items: items,
              domain: "krishibhandar.com"
            });

            if (checkoutUrl) {
              window.location.href = checkoutUrl;
            } else {
              document.getElementById('loader').innerHTML = "<h3>Checkout URL generation failed</h3>";
            }
          } else {
            setTimeout(startCheckout, 500);
          }
        } catch (e) {
          document.getElementById('loader').innerHTML = "<h3>Error: " + e.message + "</h3>";
        }
      }

      window.onload = function() {
        startCheckout();
      }
    </script>

    </body>
    </html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            debugPrint("👉 Shiprocket Navigation Request: $url");

            if (!_isSuccessLogged &&
                (url.contains("/orders/") ||
                    url.contains("order-success") ||
                    url.contains("thank-you"))) {
              _isSuccessLogged = true;
              double val = widget.totalValue ?? 0.0;
              String txId = Uri.tryParse(url)?.pathSegments.last ??
                  DateTime.now().millisecondsSinceEpoch.toString();
              MetaEvents.purchase(totalValue: val);
              FirebaseEvents.trackPurchase(
                totalAmount: val,
                transactionId: txId,
                productList: widget.cartItems,
              );

              if (mounted) Navigator.pop(context);
              return NavigationDecision.prevent;
            }

            // Handle custom schemes for UPI/External Apps
            if (!url.toLowerCase().startsWith("http")) {
              try {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  if (mounted) {
                    setState(() {
                      _isRedirecting = true;
                      _isLoading = false;
                    });
                  }
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  _showInstallMessage(url);
                }
              } catch (e) {
                debugPrint("Error launching external app: $e");
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) async {
            debugPrint(
                "Web Resource Error: ${error.errorCode}, ${error.description}, ${error.url}");

            final url = error.url ?? "";
            if (!url.toLowerCase().startsWith("http") && url.isNotEmpty) {
              try {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
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

                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  _showInstallMessage(url);
                  // Reload the previous page to clear the error since we can't launch the app
                  _controller.goBack();
                }
              } catch (e) {
                debugPrint("Failed to launch scheme from error handler: $e");
              }
            }
          },
          onUrlChange: (UrlChange change) {
            debugPrint("URL Changed to: ${change.url}");
            if (change.url != null &&
                (change.url!.contains("cancel") ||
                    change.url!.contains("checkout/cart"))) {
              if (mounted) Navigator.pop(context);
            }
          },
        ),
      )
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Secure Checkout"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
