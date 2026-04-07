import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../../controller/auth_controller.dart';
import '../../controller/cart_controller.dart';
import '../../controller/constants.dart';
import 'order_success_view.dart';

class RazorpayCheckout extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalValue;
  final Map<String, dynamic> shippingAddress;
  final String customerName;
  final String customerPhone;
  final String? discountCode;
  final double? discountAmount;

  const RazorpayCheckout({
    super.key,
    required this.cartItems,
    required this.totalValue,
    required this.shippingAddress,
    required this.customerName,
    required this.customerPhone,
    this.discountCode,
    this.discountAmount,
  });

  @override
  State<RazorpayCheckout> createState() => _RazorpayCheckoutState();
}

class _RazorpayCheckoutState extends State<RazorpayCheckout> {
  late Razorpay _razorpay;
  bool _isProcessing = false;

  // ─── RAZORPAY LIVE KEY ID ─────────────────────────────────────────────────
  static const String _razorpayKey = 'rzp_live_SaC6KIBTKpkvFd';
  // NOTE: Secret key (qnoSPGpfZT7YRw6HHg1Jqvo6) must NEVER be in app code.
  //       Use it only on your secure backend for signature verification.
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    // Auto-open Razorpay sheet after frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) => _openRazorpay());
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openRazorpay() {
    final int amountPaisa = (widget.totalValue * 100).toInt();
    final options = {
      'key': _razorpayKey,
      'amount': amountPaisa,
      'name': Constants.title,
      'description': '${widget.cartItems.length} item(s)',
      'prefill': {
        'contact': '+91${widget.customerPhone}',
        'name': widget.customerName,
      },
      'theme': {'color': '#26842C'},
      'send_sms_hash': true,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      if (mounted) {
        _showError('Could not open payment sheet. Please try again.');
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (mounted) setState(() => _isProcessing = true);
    debugPrint('Payment Success: ${response.paymentId}');

    // Create Shopify order with paid status
    final orderResult = await _createShopifyOrder(
      razorpayPaymentId: response.paymentId ?? 'unknown',
    );

    // Clear the cart now that payment is confirmed
    await CartController.clearCart();

    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessView(
            orderNumber: orderResult['order_number']?.toString() ?? '#' + DateTime.now().millisecondsSinceEpoch.toString().substring(7),
            totalAmount: widget.totalValue,
            paymentId: response.paymentId ?? '',
          ),
        ),
        (route) => route.isFirst,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    if (mounted) {
      _showError(response.message ?? 'Payment failed. Please try again.');
      // Go back to address view
      Navigator.pop(context);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${response.walletName} selected. Complete payment in the wallet app.'),
          backgroundColor: Constants.baseColor,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _createShopifyOrder({required String razorpayPaymentId}) async {
    try {
      const String baseUrl = "https://3b7f20-3.myshopify.com/admin/api/2024-10";
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-Shopify-Access-Token': Constants.shopifyAccessToken,
      };

      // Build line items from cart
      final lineItems = widget.cartItems.map((item) => {
        "variant_id": item['variant_id'] ?? item['id'],
        "quantity": item['quantity'] ?? item['qty'] ?? 1,
        "price": item['price']?.toString() ?? '0',
      }).toList();

      // Get saved Shopify customer ID
      final customerId = await AuthController.getShopifyCustomerId();

      final orderPayload = {
        "order": {
          "line_items": lineItems,
          "financial_status": "paid",
          "fulfillment_status": null,
          "shipping_address": widget.shippingAddress,
          "billing_address": widget.shippingAddress,
          "discount_codes": [
            {
              "code": Constants.payOnlineDiscountCode,
              "amount": Constants.payOnlineDiscountAmount.toStringAsFixed(2),
              "type": "fixed_amount"
            },
            if (widget.discountCode != null && widget.discountAmount != null)
              {
                "code": widget.discountCode!,
                "amount": widget.discountAmount!.toStringAsFixed(2),
                "type": "fixed_amount"
              }
          ],
          "transactions": [
            {
              "kind": "sale",
              "status": "success",
              "amount": widget.totalValue.toStringAsFixed(2),
              "gateway": "razorpay",
              "source_name": razorpayPaymentId,
            }
          ],
          if (customerId != null) "customer": {"id": int.tryParse(customerId)},
          "note": "Paid via Razorpay - TxID: $razorpayPaymentId",
          "tags": "mobile-app,razorpay",
          "send_receipt": true,
        }
      };

      final res = await http.post(
        Uri.parse('$baseUrl/orders.json'),
        headers: headers,
        body: jsonEncode(orderPayload),
      );

      debugPrint('Shopify Order Response: ${res.statusCode} - ${res.body}');

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data['order'] ?? {};
      }
    } catch (e) {
      debugPrint('createShopifyOrder error: $e');
    }
    return {};
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isProcessing
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Constants.baseColor, strokeWidth: 3),
                  const SizedBox(height: 20),
                  const Text('Confirming your order...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Please do not press back', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Constants.baseColor, strokeWidth: 3),
                  const SizedBox(height: 20),
                  const Text('Opening payment...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}
