import 'package:flutter/material.dart';
import '../../controller/constants.dart';
import '../../shopify/shopify.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';

class CouponsView extends StatefulWidget {
  const CouponsView({super.key});

  @override
  State<CouponsView> createState() => _CouponsViewState();
}

class _CouponsViewState extends State<CouponsView> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableCoupons = [];
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  Future<void> _fetchCoupons() async {
    setState(() => _isFetching = true);
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
      setState(() => _isLoading = false);
      if (result != null) {
        Navigator.pop(context, result);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.invalidCoupon), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.applyCoupon, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Constants.baseColor)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _applyCode(_codeController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.baseColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(AppLocalizations.of(context)!.apply, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                            child: Icon(Icons.confirmation_number_outlined, color: Constants.baseColor),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coupon['code'],
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  coupon['description'],
                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _applyCode(coupon['code']),
                            child: Text(AppLocalizations.of(context)!.apply, style: TextStyle(color: Constants.baseColor, fontWeight: FontWeight.bold)),
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
