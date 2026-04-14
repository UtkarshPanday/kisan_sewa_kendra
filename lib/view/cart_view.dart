import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kisan_sewa_kendra/shopify/shopify.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../components/network_image.dart';
import '../controller/constants.dart';
import '../controller/routers.dart';
import '../controller/cart_controller.dart';
import '../controller/auth_controller.dart';
import 'checkout/address_view.dart';
import 'checkout/coupons_view.dart';
import 'checkout/order_success_view.dart';
import 'home_view.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  Map<String, dynamic>? _selectedAddress;
  Map<String, dynamic>? _appliedDiscount;
  bool _isProcessingOrder = false;
  late Razorpay _razorpay;
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
    _loadDefaultAddress();
    _initRazorpay();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadDefaultAddress() async {
    final addresses = await AuthController.getStoredAddresses();
    if (addresses.isNotEmpty && mounted) {
      setState(() {
        _selectedAddress = addresses.first;
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _init() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final items = await CartController.getCart();
    if (mounted) {
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQty(String id, int delta) async {
    int index = _cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      int newQty = _cartItems[index].qty + delta;
      if (newQty <= 0) {
        await CartController.updateQty(id, 0);
      } else {
        await CartController.updateQty(id, newQty);
      }
      await _init();
    }
  }

  double _getTotalValue() {
    double total = 0;
    for (var item in _cartItems) {
      double price =
          double.tryParse(item.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      total += price * item.qty;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffF9FBF9),
        body: Stack(
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cartItems.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16,
                            MediaQuery.of(context).padding.top + 90, 16, 150),
                        child: Column(
                          children: [
                            _buildCartList(),
                            _buildCouponSection(),
                            _buildBillSummary(),
                            _buildAddressSection(),
                            _buildSafetyBadge(),
                          ],
                        ),
                      ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildAdvancedHeader(),
            ),
          ],
        ),
        bottomNavigationBar: _isLoading || _cartItems.isEmpty
            ? null
            : _buildIntegratedCheckoutBar(),
      ),
    );
  }

  Widget _buildAdvancedHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 10, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Constants.baseColor.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 22,
                    color: Constants.baseColor,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "My Cart",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.eco_rounded,
                          size: 12, color: Constants.baseColor),
                      const SizedBox(width: 4),
                      Text(
                        "Pure Organic Agriculture",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Constants.baseColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 80, color: Colors.grey[200]),
            const SizedBox(height: 24),
            Text("Your Bag is Empty",
                style: GoogleFonts.outfit(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text("Add some organic goodness to your bag!",
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.inter(fontSize: 14, color: Colors.grey[500])),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.baseColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text("SHOP NOW",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _cartItems.length,
      itemBuilder: (context, index) => _buildCartItem(_cartItems[index]),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: KskNetworkImage(item.image, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${Constants.inr}${item.price}",
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    _buildQtySelector(item),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildQtySelector(CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Constants.baseColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          _qtyBtn(Icons.remove, () => _updateQty(item.id, -1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text("${item.qty}",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Constants.baseColor)),
          ),
          _qtyBtn(Icons.add, () => _updateQty(item.id, 1)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: Constants.baseColor),
      ),
    );
  }

  void _selectCoupon() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CouponsView()),
    );
    if (result != null) setState(() => _appliedDiscount = result);
  }

  Widget _buildCouponSection() {
    return InkWell(
      onTap: _selectCoupon,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Icon(Icons.confirmation_number_rounded,
                color: Constants.baseColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _appliedDiscount == null
                    ? "Apply Coupon"
                    : "Coupon Applied: ${_appliedDiscount!['code']}",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            if (_appliedDiscount != null)
              IconButton(
                  onPressed: () => setState(() => _appliedDiscount = null),
                  icon: const Icon(Icons.close, size: 16))
            else
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummary() {
    double subtotal = _getTotalValue();
    double discount = _appliedDiscount != null
        ? (double.tryParse(_appliedDiscount!['value']?.toString() ?? '0') ?? 0)
        : 0;
    if (_appliedDiscount != null &&
        _appliedDiscount!['value_type'] == 'percentage') {
      discount = (subtotal * discount) / 100;
    }
    double total = subtotal - discount;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          _summaryRow("Item Total", subtotal),
          if (_appliedDiscount != null)
            _summaryRow("Coupon Discount", -discount, isGreen: true),
          _summaryRow("Delivery Fee", 0, isFree: true),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Grand Total",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800, fontSize: 15)),
              Text("${Constants.inr}${total.toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double val,
      {bool isFree = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
          Text(
              isFree
                  ? "FREE"
                  : "${val < 0 ? '-' : ''}${Constants.inr}${val.abs().toStringAsFixed(2)}",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color:
                      isGreen || isFree ? Constants.baseColor : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: Constants.baseColor, size: 18),
              const SizedBox(width: 8),
              Text("Deliver to",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800, fontSize: 13)),
              const Spacer(),
              TextButton(
                  onPressed: _selectAddress,
                  child: Text("CHANGE",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: Constants.baseColor))),
            ],
          ),
          if (_selectedAddress != null) ...[
            Row(
              children: [
                Text(_selectedAddress!['name'] ?? '',
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(width: 8),
                Text("•  ${_selectedAddress!['phone'] ?? ''}",
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.grey[600])),
              ],
            ),
            Text(
              "${_selectedAddress!['address1']}, ${_selectedAddress!['address2']}, ${_selectedAddress!['city']}, ${_selectedAddress!['state']} - ${_selectedAddress!['pincode']}",
              style: GoogleFonts.inter(
                  fontSize: 12, color: Colors.grey[500], height: 1.4),
            ),
          ] else
            Text("No address selected",
                style:
                    GoogleFonts.inter(fontSize: 12, color: Colors.redAccent)),
        ],
      ),
    );
  }

  void _selectAddress() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddressView()));
    if (result != null) setState(() => _selectedAddress = result);
  }

  Widget _buildSafetyBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_rounded, color: Colors.grey[300], size: 14),
          const SizedBox(width: 8),
          Text("SECURE PAYMENTS • 100% ORGANIC",
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[400],
                  letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildIntegratedCheckoutBar() {
    double subtotal = _getTotalValue();
    double discount = _appliedDiscount != null
        ? (double.tryParse(_appliedDiscount!['value']?.toString() ?? '0') ?? 0)
        : 0;
    if (_appliedDiscount != null &&
        _appliedDiscount!['value_type'] == 'percentage') {
      discount = (subtotal * discount) / 100;
    }
    double finalTotal = subtotal - discount;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${Constants.inr}${finalTotal.toStringAsFixed(0)}",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900, fontSize: 20)),
              Text("GRAND TOTAL",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      color: Constants.baseColor)),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: InkWell(
              onTap: _isProcessingOrder
                  ? null
                  : (_selectedAddress == null
                      ? _selectAddress
                      : _showPaymentSelector),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Constants.baseColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: Constants.baseColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Center(
                  child: _isProcessingOrder
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          _selectedAddress == null
                              ? "SELECT ADDRESS"
                              : "PLACE ORDER",
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Payment Method",
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 24),
            _paymentOption(
                Icons.flash_on,
                "Pay Online",
                "Instant Discount of ₹${Constants.payOnlineDiscountAmount.toInt()}",
                Constants.baseColor, () {
              Navigator.pop(context);
              _payOnline();
            }),
            const SizedBox(height: 12),
            _paymentOption(Icons.handshake, "Cash on Delivery",
                "Pay when you receive items", Colors.grey[700]!, () {
              Navigator.pop(context);
              _createShopifyOrder(isCod: true);
            }),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(IconData icon, String title, String sub, Color color,
      VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(sub,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[400])),
                ])),
          ],
        ),
      ),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _createShopifyOrder(paymentId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessingOrder = false);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Failed: ${response.message}")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  void _payOnline() async {
    double subtotal = _getTotalValue();
    double discount = _appliedDiscount != null
        ? (double.tryParse(_appliedDiscount!['value']?.toString() ?? '0') ?? 0)
        : 0;
    double finalTotal = subtotal - discount - Constants.payOnlineDiscountAmount;

    String? userPhone = await AuthController.getSavedPhone();

    var options = {
      'key': Constants.razorpayKey,
      'amount': (finalTotal * 100).toInt(),
      'name': Constants.title,
      'description': 'Payment for Order',
      'prefill': {
        'contact': userPhone ?? '',
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _createShopifyOrder(
      {String? paymentId, bool isCod = false}) async {
    setState(() => _isProcessingOrder = true);

    // Calculate final total for the success screen
    double subtotal = _getTotalValue();
    double discount = _appliedDiscount != null
        ? (double.tryParse(_appliedDiscount!['value']?.toString() ?? '0') ?? 0)
        : 0;
    if (_appliedDiscount != null &&
        _appliedDiscount!['value_type'] == 'percentage') {
      discount = (subtotal * discount) / 100;
    }
    double finalTotal = subtotal - discount;

    // Simulate order processing
    await Future.delayed(const Duration(seconds: 2));

    // Final cleanup
    await CartController.clearCart();
    if (mounted) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => OrderSuccessView(
                    orderNumber:
                        "KSK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                    totalAmount: finalTotal,
                    paymentId:
                        paymentId ?? (isCod ? "Cash on Delivery" : "Online"),
                  )));
    }
  }
}
