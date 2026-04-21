import 'package:flutter/material.dart';
import 'package:kisan_sewa_kendra/controller/auth_controller.dart';
import '../../controller/constants.dart';
import '../../shopify/shopify.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
import '../product_view.dart';
import '../../model/product_model.dart';
import '../../controller/cart_controller.dart';
import '../../components/network_image.dart';

class CouponsView extends StatefulWidget {
  final double subtotal;
  final int totalItems;
  const CouponsView(
      {super.key, required this.subtotal, required this.totalItems});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableCoupons = [];
  List<dynamic> _customerOrders = [];
  bool _isFetching = true;

  bool _isCouponApplicable(Map<String, dynamic> coupon,
      {bool showMsg = false}) {
    double minAmount =
        double.tryParse(coupon['minAmount']?.toString() ?? '0') ?? 0;
    int minQty = int.tryParse(coupon['minQty']?.toString() ?? '0') ?? 0;

    if (minAmount > 0 && widget.subtotal < minAmount) {
      if (showMsg)
        _showError("Minimum order of ${Constants.inr}$minAmount required");
      return false;
    }
    if (minQty > 0 && widget.totalItems < minQty) {
      if (showMsg) _showError("Minimum $minQty items required");
      return false;
    }

    // Active Date Check
    if (coupon['startsAt'] != null) {
      DateTime startsAt = DateTime.parse(coupon['startsAt'].toString());
      if (startsAt.isAfter(DateTime.now())) {
        if (showMsg) _showError("This coupon is not yet active");
        return false;
      }
    }

    // New Customer Check
    final selection = coupon['customerSelection'];
    if (selection != null && selection['allCustomers'] == false) {
      // Since segments query was breaking visibility, we use keywords as a fallback
      // plus the fact that it's restricted (allCustomers = false)
      final title = (coupon['title'] ?? '').toString().toLowerCase();
      final summary = (coupon['summary'] ?? '').toString().toLowerCase();
      bool isNewCustomerTargeted =
          title.contains('new') || summary.contains('new');

      if (isNewCustomerTargeted && _customerOrders.isNotEmpty) {
        if (showMsg) _showError("This coupon is only for new customers");
        return false;
      }
    }

    // One use per customer check
    if (coupon['appliesOncePerCustomer'] == true &&
        _customerOrders.isNotEmpty) {
      String code = coupon['code'].toString().toUpperCase();
      bool alreadyUsed = false;

      for (var order in _customerOrders) {
        final usedCodes = order['discount_codes'] as List? ?? [];
        if (usedCodes.contains(code)) {
          alreadyUsed = true;
          break;
        }
      }

      if (alreadyUsed) {
        if (showMsg) _showError("You have already used this coupon");
        return false;
      }
    }

    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.orange),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    setState(() => _isFetching = true);

    // Fetch customer orders to check "new customer" or "one use" status
    try {
      final customerId = await AuthController.getShopifyCustomerId();
      if (customerId != null) {
        _customerOrders = await ShopifyAPI.getCustomerOrders(customerId);
      }
    } catch (e) {
      debugPrint("Error fetching customer orders for coupon validation: $e");
    }

    final results = await ShopifyAdmin.getAvailableDiscounts();
    if (mounted) {
      setState(() {
        _availableCoupons = results;
        _isFetching = false;
      });
    }
  }

  Future<void> _applyCode(String code) async {
    if (code.isEmpty) return;
    setState(() => _isLoading = true);

    final result = await ShopifyAdmin.validateDiscountCode(code: code);

    if (mounted) {
      if (result != null) {
        if (!_isCouponApplicable(result, showMsg: true)) {
          setState(() => _isLoading = false);
          return;
        }

        // If it's a BXGY coupon, automatically add entitled products to cart
        if (result['type'] == 'special' && result['entitledProducts'] != null) {
          final entitled = result['entitledProducts'] as List;
          for (var p in entitled) {
            if (p['variantId'] != null && p['variantId'].isNotEmpty) {
              await CartController.addToCart(
                variantId: p['variantId'],
                productId: p['id'],
                qty: 1,
                title: p['title'],
                price: p['price'],
                image: p['image'],
                variantTitle: p['variantTitle'],
              );
            }
          }
        }
        setState(() => _isLoading = false);
        Navigator.pop(context, result);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.invalidCoupon),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.applyCoupon,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Manual Entry
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterCouponCode,
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Constants.baseColor)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _applyCode(_codeController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.baseColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text(AppLocalizations.of(context)!.apply,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Available Coupons List
          Expanded(
            child: _isFetching
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _availableCoupons.length,
                    itemBuilder: (context, index) {
                      final coupon = _availableCoupons[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Constants.baseColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.confirmation_number_outlined,
                                  color: Constants.baseColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coupon['code'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                        letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    coupon['description'],
                                    style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12),
                                  ),
                                  if ((coupon['minAmount'] ?? 0) > 0 ||
                                      (coupon['minQty'] ?? 0) > 0) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      (coupon['minAmount'] ?? 0) > 0
                                          ? "Min. Order: ${Constants.inr}${coupon['minAmount']}"
                                          : "Min. Items: ${coupon['minQty']}",
                                      style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Opacity(
                              opacity: _isCouponApplicable(coupon) ? 1.0 : 0.5,
                              child: TextButton(
                                onPressed: _isCouponApplicable(coupon)
                                    ? () => _applyCode(coupon['code'])
                                    : () => _isCouponApplicable(coupon,
                                        showMsg: true),
                                child: Text(AppLocalizations.of(context)!.apply,
                                    style: TextStyle(
                                        color: _isCouponApplicable(coupon)
                                            ? Constants.baseColor
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
