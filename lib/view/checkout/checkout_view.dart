import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../controller/auth_controller.dart';
import '../../controller/cart_controller.dart';
import '../../controller/constants.dart';
import 'razorpay_checkout.dart';
import 'order_success_view.dart';
import 'coupons_view.dart';

class CheckoutView extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalValue;
  final Map<String, String> selectedAddress;

  const CheckoutView({
    super.key,
    required this.cartItems,
    required this.totalValue,
    required this.selectedAddress,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late List<Map<String, dynamic>> _checkoutCartItems;
  bool _isProcessingCod = false;
  final TextEditingController _couponController = TextEditingController();
  Map<String, dynamic>? _appliedDiscount;

  @override
  void initState() {
    super.initState();
    _checkoutCartItems = List<Map<String, dynamic>>.from(
        widget.cartItems.map((item) => Map<String, dynamic>.from(item)));
  }

  double get _itemsTotal {
    double total = 0;
    for (var item in _checkoutCartItems) {
      final price = double.tryParse(
              item['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ??
                  '0') ??
          0;
      final qty = (item['qty'] ?? item['quantity'] ?? 1) as int;
      total += price * qty;
    }
    return total;
  }

  double get _discountValue {
    if (_appliedDiscount == null) return 0.0;
    if (_appliedDiscount!['type'] == 'percentage') {
      return _itemsTotal * (_appliedDiscount!['value'] / 100);
    }
    return _appliedDiscount!['value'].toDouble();
  }

  double get _finalTotal => _itemsTotal - _discountValue;

  void _updateQuantity(int index, int delta) {
    setState(() {
      int currentQty = (_checkoutCartItems[index]['qty'] ??
          _checkoutCartItems[index]['quantity'] ??
          1) as int;
      int newQty = currentQty + delta;

      final variantId = (_checkoutCartItems[index]['variant_id'] ??
              _checkoutCartItems[index]['id'])
          .toString();

      if (newQty > 0) {
        _checkoutCartItems[index]['qty'] = newQty;
        _checkoutCartItems[index]['quantity'] = newQty;
        CartController.updateQty(variantId, newQty);
      } else {
        _checkoutCartItems.removeAt(index);
        CartController.removeFromCart(variantId);
        if (_checkoutCartItems.isEmpty) {
          Navigator.pop(context);
        }
      }
    });
  }

  void _removeCoupon() {
    setState(() {
      _appliedDiscount = null;
      _couponController.clear();
    });
  }

  void _navigateToRazorpay() {
    final addressData = widget.selectedAddress;
    final shopifyAddress = {
      'name': addressData['name'],
      'phone': addressData['phone'] ?? '',
      'address1': addressData['address1'],
      'address2': addressData['address2'],
      'city': addressData['city'],
      'province': addressData['state'],
      'zip': addressData['pincode'],
      'country': 'India',
      'country_code': 'IN',
    };

    double razorpayTotal = _finalTotal - Constants.payOnlineDiscountAmount;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RazorpayCheckout(
          cartItems: _checkoutCartItems,
          totalValue: razorpayTotal,
          shippingAddress: shopifyAddress,
          customerName: addressData['name'] ?? '',
          customerPhone: addressData['phone'] ?? '',
          discountCode: _appliedDiscount?['code'],
          discountAmount: _discountValue,
        ),
      ),
    );
  }

  Future<void> _placeCodOrder() async {
    setState(() => _isProcessingCod = true);
    try {
      final addressData = widget.selectedAddress;
      final address = {
        'name': addressData['name'],
        'phone': addressData['phone'] ?? '',
        'address1': addressData['address1'],
        'address2': addressData['address2'],
        'city': addressData['city'],
        'province': addressData['state'],
        'zip': addressData['pincode'],
        'country': 'India',
        'country_code': 'IN',
      };

      const String baseUrl = "https://3b7f20-3.myshopify.com/admin/api/2024-10";
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'X-Shopify-Access-Token': Constants.shopifyAccessToken,
      };

      final lineItems = _checkoutCartItems
          .map((item) => {
                "variant_id": item['variant_id'] ?? item['id'],
                "quantity": item['quantity'] ?? item['qty'] ?? 1,
                "price": item['price']?.toString() ?? '0',
              })
          .toList();

      final customerId = await AuthController.getShopifyCustomerId();

      final orderPayload = {
        "order": {
          "line_items": lineItems,
          "financial_status": "pending",
          "fulfillment_status": null,
          "shipping_address": address,
          "billing_address": address,
          "gateway": "Cash on Delivery (COD)",
          if (customerId != null) "customer": {"id": int.tryParse(customerId)},
          "note": "Cash on Delivery",
          "tags": "mobile-app, cod",
          "send_receipt": true,
          if (_appliedDiscount != null)
            "discount_codes": [
              {
                "code": _appliedDiscount!['code'],
                "amount": _discountValue.toStringAsFixed(2),
                "type": _appliedDiscount!['type'],
              }
            ],
        }
      };

      final res = await http.post(
        Uri.parse('$baseUrl/orders.json'),
        headers: headers,
        body: jsonEncode(orderPayload),
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        await CartController.clearCart();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderSuccessView(
                orderNumber: data['order']['order_number']?.toString() ??
                    '#' +
                        DateTime.now()
                            .millisecondsSinceEpoch
                            .toString()
                            .substring(7),
                totalAmount: _finalTotal,
                paymentId: 'COD',
              ),
            ),
            (route) => route.isFirst,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: const Text('Failed to place order. Please try again.'),
                backgroundColor: Colors.red.shade700),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error placing order: $e'),
              backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingCod = false);
    }
  }

  Widget _buildOrderItem(Map<String, dynamic> item, int index) {
    final qty = (item['qty'] ?? item['quantity'] ?? 1) as int;
    final price = double.tryParse(
            item['price']?.toString().replaceAll(RegExp(r'[^\d.]'), '') ??
                '0') ??
        0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100),
              image:
                  item['image'] != null && item['image'].toString().isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(item['image']),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: item['image'] == null || item['image'].toString().isEmpty
                ? Icon(Icons.inventory_2_outlined,
                    color: Colors.grey.shade300, size: 28)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? 'Product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Color(0xFF1a1a1a)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹${price.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Constants.baseColor,
                          fontSize: 13),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          _buildQtyBtn(
                              qty == 1
                                  ? Icons.delete_outline_rounded
                                  : Icons.remove,
                              () => _updateQuantity(index, -1),
                              color: qty == 1 ? Colors.red : null),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('$qty',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 13)),
                          ),
                          _buildQtyBtn(
                              Icons.add, () => _updateQuantity(index, 1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 14, color: color ?? Colors.grey.shade700),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value,
      {bool isBold = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.black : Colors.grey.shade600,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isGreen ? Colors.green.shade700 : Colors.black,
              fontWeight: isBold
                  ? FontWeight.w900
                  : (isGreen ? FontWeight.w700 : FontWeight.w600),
              fontSize: isBold ? 17 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final addr = widget.selectedAddress;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Checkout Details',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded,
              color: Colors.grey.shade700, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Items (Compact & At top)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ORDER ITEMS',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5)),
                  const Divider(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _checkoutCartItems.length,
                    itemBuilder: (context, index) =>
                        _buildOrderItem(_checkoutCartItems[index], index),
                  ),
                ],
              ),
            ),

            // Compact Coupon Selection Tile
            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CouponsView()),
                );

                if (result != null && mounted) {
                  setState(() {
                    _appliedDiscount = result;
                    _couponController.text = result['code'] ?? '';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Coupon "${result['code']}" applied!'),
                        backgroundColor: Colors.green),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.confirmation_number_outlined,
                        color: Constants.baseColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _appliedDiscount == null
                                ? 'APPLY COUPON'
                                : 'COUPON APPLIED',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 0.5),
                          ),
                          if (_appliedDiscount != null)
                            Text(
                              '${_appliedDiscount!['code']} - Saved ₹${_discountValue.toStringAsFixed(2)}',
                              style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            )
                          else
                            Text(
                              'Enter code or select from offers',
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 11),
                            ),
                        ],
                      ),
                    ),
                    if (_appliedDiscount != null)
                      IconButton(
                        onPressed: _removeCoupon,
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    else
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),

            // Delivery Address Preview
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          color: Constants.baseColor, size: 18),
                      const SizedBox(width: 8),
                      const Text('Delivery Address',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 14)),
                      const Spacer(),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Text('CHANGE',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Constants.baseColor,
                                fontSize: 12)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    addr['name'] ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${addr['address1']}, ${addr['address2'] ?? ""}, ${addr['city']}, ${addr['state']} - ${addr['pincode']}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12, height: 1.3),
                  ),
                ],
              ),
            ),

            // Price Details (Compact)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PRICE DETAILS',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.5)),
                  const Divider(height: 20),
                  _buildPriceRow(
                      'Item Total', '₹${_itemsTotal.toStringAsFixed(2)}'),
                  _buildPriceRow('Shipping', 'FREE', isGreen: true),
                  if (_appliedDiscount != null)
                    _buildPriceRow(
                        'Discount', '- ₹${_discountValue.toStringAsFixed(2)}',
                        isGreen: true),
                  const Divider(height: 12),
                  _buildPriceRow(
                      'Total Amount', '₹${_finalTotal.toStringAsFixed(2)}',
                      isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Compact Payment Column
            Column(
              children: [
                // Pay Online (Primary)
                _buildAnimatedButton(
                  onTap: _isProcessingCod ? null : _navigateToRazorpay,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Constants.baseColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Constants.baseColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('PAY ONLINE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 0.5)),
                            Text(
                                '₹${Constants.payOnlineDiscountAmount.toInt()} Instant Discount',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.8))),
                          ],
                        ),
                        const Spacer(),
                        Text(
                            '₹${(_finalTotal - Constants.payOnlineDiscountAmount).toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // COD (Secondary)
                _buildAnimatedButton(
                  onTap: _isProcessingCod ? null : _placeCodOrder,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: _isProcessingCod
                        ? const Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.grey)))
                        : Row(
                            children: [
                              Text('CASH ON DELIVERY',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: Colors.grey.shade700)),
                              const Spacer(),
                              Text('₹${_finalTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87)),
                            ],
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
      {required Widget child, required VoidCallback? onTap}) {
    return _BouncingButton(onTap: onTap, child: child);
  }
}

class _BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _BouncingButton({required this.child, this.onTap});

  @override
  _BouncingButtonState createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<_BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late double _scale;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _controller.forward() : null,
      onTapUp: (_) => widget.onTap != null ? _controller.reverse() : null,
      onTapCancel: () => widget.onTap != null ? _controller.reverse() : null,
      onTap: widget.onTap,
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
