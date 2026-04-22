import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
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
    if (mounted) {
      setState(() {
        if (addresses.isNotEmpty) {
          _selectedAddress = addresses.first;
        } else {
          _selectedAddress = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _init({bool skipValidation = false}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final items = await CartController.getCart();
    if (mounted) {
      setState(() {
        _cartItems = items;
        _isLoading = false;
      });

      if (!skipValidation) {
        await _checkCouponValidity();
      }
    }
  }

  Future<void> _checkCouponValidity() async {
    if (_appliedDiscount == null || _isProcessingOrder) return;

    double requirementSubtotal = 0;
    int requirementQty = 0;

    final entitledList = _appliedDiscount!['entitledProducts'] as List?;

    for (var item in _cartItems) {
      bool isEntitled = false;
      if (entitledList != null) {
        isEntitled = entitledList.any((e) =>
            e['id'].toString() == item.productId.toString() ||
            (e['variantId'] != null &&
                e['variantId'].toString() == item.id.toString()));
      }

      if (!isEntitled) {
        double price =
            double.tryParse(item.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
        requirementSubtotal += price * item.qty;
        requirementQty += item.qty;
      }
    }

    double minAmount =
        double.tryParse(_appliedDiscount!['minAmount']?.toString() ?? '0') ?? 0;
    int minQty =
        int.tryParse(_appliedDiscount!['minQty']?.toString() ?? '0') ?? 0;

    bool stillValid = true;
    if (minAmount > 0 && requirementSubtotal < minAmount) stillValid = false;
    if (minQty > 0 && requirementQty < minQty) stillValid = false;

    // For BXGY (special), if there are no "Buy" items left, it's invalid
    if (_appliedDiscount!['type'] == 'special' && requirementQty == 0) {
      stillValid = false;
    }

    if (!stillValid) {
      await _removeDiscount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Coupon removed: requirements not met"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
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

  Future<void> _removeDiscount() async {
    if (_appliedDiscount == null) return;

    if (_appliedDiscount!['type'] == 'special') {
      final entitledList = _appliedDiscount!['entitledProducts'] as List?;
      if (entitledList != null && entitledList.isNotEmpty) {
        setState(() => _isLoading = true);
        for (var item in _cartItems) {
          bool isEntitled = entitledList.any((e) =>
              e['id'].toString() == item.productId.toString() ||
              (e['variantId'] != null &&
                  e['variantId'].toString() == item.id.toString()));
          if (isEntitled) {
            await CartController.updateQty(item.id, 0);
          }
        }
      }
    }

    setState(() {
      _appliedDiscount = null;
    });
    await _init(skipValidation: true);
    HapticFeedback.lightImpact();
  }

  Future<void> _clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppLocalizations.of(context)!.clearCartConfirm,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
        ),
        content: Text(
          AppLocalizations.of(context)!.clearCartConfirmMsg,
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppLocalizations.of(context)!.clearCart.toUpperCase(),
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w900,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await CartController.clearCart();
      HapticFeedback.heavyImpact();
      _init();
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

  double _getDiscountAmount() {
    if (_appliedDiscount == null) return 0;
    double subtotal = _getTotalValue();
    double discount = 0;

    if (_appliedDiscount!['type'] == 'special') {
      // BXGY logic: make 1 unit of entitled product free
      final entitledList = _appliedDiscount!['entitledProducts'] as List?;
      if (entitledList != null && entitledList.isNotEmpty) {
        for (var item in _cartItems) {
          bool isEntitled = entitledList.any((e) =>
              e['id'].toString() == item.productId.toString() ||
              (e['variantId'] != null &&
                  e['variantId'].toString() == item.id.toString()));
          if (isEntitled) {
            double itemPrice =
                double.tryParse(item.price.replaceAll(RegExp(r'[^\d.]'), '')) ??
                    0;
            discount = itemPrice;
            break;
          }
        }
      }
    } else {
      discount =
          double.tryParse(_appliedDiscount!['value']?.toString() ?? '0') ?? 0;
      if (_appliedDiscount!['type'] == 'percentage') {
        discount = (subtotal * discount) / 100;
      }
    }
    return discount;
  }

  double _getFinalTotal() {
    return _getTotalValue() - _getDiscountAmount();
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
            // Background Layer
            Positioned.fill(
              child: Container(color: const Color(0xffF9FBF9)),
            ),

            // Background Shapes
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Constants.baseColor.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 150,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Constants.baseColor.withOpacity(0.03),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _cartItems.isEmpty
                    ? _buildEmptyState()
                    : SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16,
                            MediaQuery.of(context).padding.top + 85, 16, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                                AppLocalizations.of(context)!.farmingEssentials,
                                AppLocalizations.of(context)!
                                    .items(_cartItems.length)),
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 8),
                              child: Row(
                                children: [
                                  Icon(Icons.swipe_left_rounded,
                                      size: 16,
                                      color:
                                          Constants.baseColor.withOpacity(0.4)),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.slideToDelete,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildCartList(),
                            const SizedBox(height: 10),
                            _buildCouponSection(),
                            const SizedBox(height: 10),
                            _buildAddressSection(),
                            const SizedBox(height: 10),
                            _buildBillSummary(),
                            _buildSafetyBadge(),
                            const SizedBox(height: 80),
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

  Widget _buildSectionHeader(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E1E1E),
          ),
        ),
        Text(
          sub,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedHeader() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(
              16, MediaQuery.of(context).padding.top + 8, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.05)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _circleIconBtn(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.checkout,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Constants.baseColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          "${AppLocalizations.of(context)!.appBrandName} • Agri-Business",
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Constants.baseColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_cartItems.isNotEmpty)
                    TextButton(
                      onPressed: _clearCart,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.clearCart.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _buildProgressSteps(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleIconBtn({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1E1E1E)),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Row(
      children: [
        _stepItem(AppLocalizations.of(context)!.cart, true),
        _stepDivider(true),
        _stepItem(
            AppLocalizations.of(context)!.address, _selectedAddress != null),
        _stepDivider(_selectedAddress != null),
        _stepItem(AppLocalizations.of(context)!.payment, false),
      ],
    );
  }

  Widget _stepDivider(bool active) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: active ? Constants.baseColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  Widget _stepItem(String label, bool active) {
    return Column(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? Constants.baseColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 7,
            fontWeight: FontWeight.w900,
            color: active ? Constants.baseColor : Colors.grey[400],
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Constants.baseColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_basket_outlined,
                  size: 80, color: Constants.baseColor.withOpacity(0.2)),
            ),
            const SizedBox(height: 32),
            Text(AppLocalizations.of(context)!.basketEmpty,
                style: GoogleFonts.outfit(
                    fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.basketEmptyMsg,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    fontSize: 14, color: Colors.grey[500], height: 1.5)),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.baseColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text(AppLocalizations.of(context)!.startShopping,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1)),
              ),
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
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        bool isFreeItem = false;
        if (_appliedDiscount != null &&
            _appliedDiscount!['type'] == 'special') {
          final entitledList = _appliedDiscount!['entitledProducts'] as List?;
          if (entitledList != null && entitledList.isNotEmpty) {
            try {
              final freeItem = _cartItems.firstWhere((it) => entitledList.any(
                  (e) =>
                      e['id'].toString() == it.productId.toString() ||
                      (e['variantId'] != null &&
                          e['variantId'].toString() == it.id.toString())));
              if (freeItem.id == item.id) isFreeItem = true;
            } catch (_) {}
          }
        }

        return Dismissible(
          key: Key(item.id),
          direction:
              isFreeItem ? DismissDirection.none : DismissDirection.endToStart,
          onDismissed: isFreeItem
              ? null
              : (_) {
                  _updateQty(item.id, -item.qty);
                  HapticFeedback.mediumImpact();
                },
          background: isFreeItem
              ? null
              : Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete_sweep_rounded,
                      color: Colors.white, size: 28),
                ),
          child: _buildCartItem(item, isFreeItem),
        );
      },
    );
  }

  Widget _buildCartItem(CartItem item, bool isFreeRow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isFreeRow
                ? Constants.baseColor.withOpacity(0.2)
                : Colors.grey.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF9FBF9),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: KskNetworkImage(item.image, fit: BoxFit.cover),
                ),
              ),
              if (isFreeRow)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(8)),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.free.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: const Color(0xFF1E1E1E),
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (!isFreeRow)
                      IconButton(
                        onPressed: () => _updateQty(item.id, -item.qty),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: Colors.redAccent),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
                Text(
                  item.variantTitle == "Default Title"
                      ? AppLocalizations.of(context)!.pureOrganicQuality
                      : item.variantTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: Constants.baseColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isFreeRow)
                          Text(
                            "${Constants.inr}${item.price}",
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey[400],
                            ),
                          ),
                        Text(
                          isFreeRow
                              ? AppLocalizations.of(context)!.free
                              : "${Constants.inr}${item.price}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: isFreeRow
                                ? Colors.orange
                                : const Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                    _buildQtySelector(item, isFreeRow),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtySelector(CartItem item, bool isFreeRow) {
    if (isFreeRow) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Constants.baseColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          "Qty: ${item.qty}",
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Constants.baseColor,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: Constants.baseColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove_rounded, () => _updateQty(item.id, -1)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "${item.qty}",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: Constants.baseColor,
              ),
            ),
          ),
          _qtyBtn(Icons.add_rounded, () => _updateQty(item.id, 1)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: Constants.baseColor),
      ),
    );
  }

  void _selectCoupon() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CouponsView(
          subtotal: _getTotalValue(),
          totalItems: _cartItems.length,
        ),
      ),
    );
    if (result != null) {
      if (_appliedDiscount != null) {
        await _removeDiscount();
      }
      setState(() => _appliedDiscount = result);
      await _init(); // Refresh to show newly added free products
    }
  }

  Widget _buildCouponSection() {
    return InkWell(
      onTap: _selectCoupon,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _appliedDiscount != null
                  ? Constants.baseColor.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _appliedDiscount != null
                    ? Constants.baseColor
                    : Constants.baseColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.confirmation_num_rounded,
                color: _appliedDiscount != null
                    ? Colors.white
                    : Constants.baseColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _appliedDiscount == null
                        ? AppLocalizations.of(context)!.haveCoupon
                        : AppLocalizations.of(context)!.couponApplied,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  Text(
                    _appliedDiscount == null
                        ? AppLocalizations.of(context)!.saveMoreMsg
                        : AppLocalizations.of(context)!
                            .couponAppliedMsg(_appliedDiscount!['code']),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                      color: _appliedDiscount != null
                          ? Constants.baseColor
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            if (_appliedDiscount != null)
              GestureDetector(
                onTap: _removeDiscount,
                child: const Icon(Icons.close_rounded,
                    size: 16, color: Colors.red),
              )
            else
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey[300], size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummary() {
    double subtotal = _getTotalValue();
    double discount = _getDiscountAmount();
    double total = _getFinalTotal();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.billSummary,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(AppLocalizations.of(context)!.itemTotal, subtotal),
          if (_appliedDiscount != null)
            _summaryRow(AppLocalizations.of(context)!.couponDiscount, -discount,
                isGreen: true),
          _summaryRow(AppLocalizations.of(context)!.deliveryFee, 0,
              isFree: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.grandTotal,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              Text("${Constants.inr}${total.toStringAsFixed(2)}",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Constants.baseColor)),
            ],
          ),
          if (discount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                color: Constants.baseColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars_rounded,
                      color: Constants.baseColor, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context)!.youSaved(
                        "${Constants.inr}${discount.toStringAsFixed(0)}"),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Constants.baseColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double val,
      {bool isFree = false, bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600)),
          Text(
              isFree
                  ? "FREE"
                  : "${val < 0 ? '-' : ''}${Constants.inr}${val.abs().toStringAsFixed(2)}",
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isGreen || isFree
                      ? Constants.baseColor
                      : const Color(0xFF1E1E1E))),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Constants.baseColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded,
                    color: Constants.baseColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.deliveryAddress,
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w800, fontSize: 15)),
                    if (_selectedAddress != null)
                      Text(
                          AppLocalizations.of(context)!.deliveringTo(
                              _selectedAddress!['label'] ?? "Home"),
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                              color: Constants.baseColor)),
                  ],
                ),
              ),
              TextButton(
                  onPressed: _selectAddress,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(AppLocalizations.of(context)!.change,
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                          color: Constants.baseColor))),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedAddress != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_selectedAddress!['name'] ?? '',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(width: 4),
                      Text("•", style: TextStyle(color: Colors.grey[300])),
                      const SizedBox(width: 4),
                      Text("${_selectedAddress!['phone'] ?? ''}",
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_selectedAddress!['address1']}, ${_selectedAddress!['address2']}, ${_selectedAddress!['city']}, ${_selectedAddress!['state']} - ${_selectedAddress!['pincode']}",
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[500],
                        height: 1.4,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ] else
            _buildEmptyAddressBtn(),
        ],
      ),
    );
  }

  Widget _buildEmptyAddressBtn() {
    return InkWell(
      onTap: _selectAddress,
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: Colors.red.withOpacity(0.1), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.add_location_alt_rounded,
                color: Colors.red[300], size: 30),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.selectAddressToProceed,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.red[400])),
          ],
        ),
      ),
    );
  }

  void _selectAddress() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AddressView()));
    if (result != null) {
      setState(() => _selectedAddress = result);
    } else {
      _loadDefaultAddress();
    }
  }

  Widget _buildSafetyBadge() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_rounded,
                  color: Colors.grey[300], size: 14),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.secureTransactions,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[400],
                      letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.trustBadges,
              style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[300],
                  letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildIntegratedCheckoutBar() {
    double finalTotal = _getFinalTotal();

    return Container(
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _isProcessingOrder
                    ? null
                    : (_selectedAddress == null
                        ? _selectAddress
                        : _showPaymentSelector),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 54,
                  decoration: BoxDecoration(
                    color: _selectedAddress == null
                        ? Colors.black
                        : Constants.baseColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: (_selectedAddress == null
                                  ? Colors.black
                                  : Constants.baseColor)
                              .withOpacity(0.2),
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  _selectedAddress == null
                                      ? AppLocalizations.of(context)!
                                          .addDeliveryAddress
                                      : AppLocalizations.of(context)!
                                          .proceedToPlaceOrder,
                                  style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontSize: 15,
                                      letterSpacing: 1)),
                              const SizedBox(width: 12),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void _showPaymentSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
            20, 10, 20, MediaQuery.of(context).padding.bottom + 16),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 15, spreadRadius: 2)
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context)!.paymentOptions,
                          style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(AppLocalizations.of(context)!.choosePreferredMethod,
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _paymentOption(
                Icons.account_balance_wallet_rounded,
                AppLocalizations.of(context)!.onlinePayment,
                AppLocalizations.of(context)!.payMethodSubtitle,
                Constants.baseColor,
                discount: "3% OFF", () {
              Navigator.pop(context);
              _payOnline();
            }),
            const SizedBox(height: 8),
            _paymentOption(
                Icons.currency_rupee_rounded,
                AppLocalizations.of(context)!.cod,
                AppLocalizations.of(context)!.codSubtitle,
                const Color(0xFF4A4A4A), () {
              Navigator.pop(context);
              _createShopifyOrder(isCod: true);
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(
      IconData icon, String title, String sub, Color color, VoidCallback onTap,
      {String? discount}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 5,
                offset: const Offset(0, 2),
              )
            ]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                      if (discount != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            discount,
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(sub,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey[300], size: 20),
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
    double finalTotal = _getFinalTotal();
    // Apply 3% online discount on top of any existing discount
    finalTotal = finalTotal * 0.97;

    // Prioritize phone from selected address, fallback to login phone
    String? contactPhone = _selectedAddress?['phone']?.toString();
    if (contactPhone == null || contactPhone.isEmpty) {
      contactPhone = await AuthController.getSavedPhone();
    }

    // More robust phone cleaning for Razorpay prefill
    if (contactPhone != null && contactPhone.isNotEmpty) {
      contactPhone = contactPhone.replaceAll(RegExp(r'[^\d]'), '');

      // Remove leading '0' if present
      if (contactPhone.startsWith('0')) {
        contactPhone = contactPhone.substring(1);
      }

      // Remove '91' prefix if it's already there and the rest is 10 digits
      if (contactPhone.startsWith('91') && contactPhone.length > 10) {
        contactPhone = contactPhone.substring(2);
      }

      // Force digits-only format: 91XXXXXXXXXX (no +)
      if (contactPhone.length == 10) {
        contactPhone = "91$contactPhone";
      } else {
        contactPhone = contactPhone.replaceAll('+', '');
      }
    }

    String? contactName = _selectedAddress?['name']?.toString() ??
        await AuthController.getSavedName();
    if (contactName == null || contactName.isEmpty) contactName = "Customer";

    String? contactEmail = await AuthController.getSavedEmail();
    if (contactEmail == null || contactEmail.isEmpty) {
      // Razorpay requires an email to skip the contact screen.
      contactEmail = "customer@kisansewakendra.com";
    }

    var options = {
      'key': Constants.razorpayKey,
      'amount': (finalTotal * 100).toInt(), // amount in paise
      'name': Constants.title,
      'image':
          'https://cdn.shopify.com/s/files/1/0627/9204/0601/files/logo.png',
      'description': 'Payment for Order',
      'prefill': {
        'contact': contactPhone ?? '', // Standard key
        'phone': contactPhone ?? '', // Alias for some SDK versions
        'name': contactName,
        'email': contactEmail,
      },
      'modal': {
        'confirm_close': true,
      }
    };

    print("DEBUG: Razorpay Options --> $options");
    debugPrint("DEBUG: Razorpay Options --> $options");

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay Error: $e");
    }
  }

  Future<void> _createShopifyOrder(
      {String? paymentId, bool isCod = false}) async {
    setState(() => _isProcessingOrder = true);
    double subtotal = _getTotalValue();
    double couponDiscount = _getDiscountAmount();
    double onlineDiscount = isCod ? 0 : ((subtotal - couponDiscount) * 0.03);
    double finalTotal = subtotal - couponDiscount - onlineDiscount;
    double totalDiscount = couponDiscount + onlineDiscount;

    // We send ORIGINAL prices to Shopify so the subtotal looks correct.
    // The discount is handled at the order level via discount_codes and total_discounts.
    final List<Map<String, dynamic>> items = _cartItems.map((item) {
      double originalPrice =
          double.tryParse(item.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;

      return {
        "variant_id": item.id,
        "quantity": item.qty,
        "price": originalPrice.toStringAsFixed(2),
      };
    }).toList();

    final String? customerId = await AuthController.getShopifyCustomerId();
    if (customerId == null) {
      if (mounted) {
        setState(() => _isProcessingOrder = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error: Customer ID not found")));
      }
      return;
    }

    String? contactEmail = await AuthController.getSavedEmail();
    if (contactEmail == null || contactEmail.isEmpty) {
      contactEmail = "customer@krishibhandar.com";
    }

    final orderRes = await ShopifyAPI.createOrder(
      customerId: customerId,
      email: contactEmail,
      lineItems: items,
      shippingAddress: _selectedAddress!,
      totalAmount: finalTotal,
      discountCode: _appliedDiscount?['code']?.toString() ?? (onlineDiscount > 0 ? "ONLINE-DISCOUNT" : null),
      discountAmount: totalDiscount,
      paymentId: paymentId,
      isCod: isCod,
    );

    if (orderRes.isNotEmpty && orderRes['order'] != null) {
      String realOrderNumber = orderRes['order']['name']?.toString() ??
          "KSK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

      // Final cleanup
      await CartController.clearCart();
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => OrderSuccessView(
                      orderNumber: realOrderNumber,
                      totalAmount: finalTotal,
                      paymentId:
                          paymentId ?? (isCod ? "Cash on Delivery" : "Online"),
                    )));
      }
    } else {
      if (mounted) {
        setState(() => _isProcessingOrder = false);
        String errorMsg = "Failed to create order.";
        if (orderRes.containsKey('error')) {
          errorMsg += " ${orderRes['error']}";
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }
}
