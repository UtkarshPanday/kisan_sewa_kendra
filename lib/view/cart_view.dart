import 'package:flutter/material.dart';

import '../components/ksk_appbar.dart';
import '../components/network_image.dart';
import '../controller/constants.dart';
import '../controller/routers.dart';
import 'checkout/address_view.dart';
import 'home_view.dart';
import '../controller/cart_controller.dart';
import '../utils/meta_events.dart';
import '../utils/firebase_events.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  List<CartItem> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
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
      await CartController.updateQty(id, newQty);
      await _init();
    }
  }

  double _getTotalValue() {
    double total = 0;
    for (var item in _cartItems) {
      double price = double.tryParse(
          item.price.replaceAll(RegExp(r'[^\d.]'), '')) ??
          0;
      total += price * item.qty;
    }
    return total;
  }

  String _getTotalAmt() {
    return "${Constants.inr}${_getTotalValue().toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const KskAppbar(title: "My Cart"),
      body: RefreshIndicator(
        onRefresh: _init,
        color: Constants.baseColor,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _cartItems.isEmpty
            ? _buildEmptyState()
            : _buildCartList(),
      ),
      bottomNavigationBar:
      _isLoading || _cartItems.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.remove_shopping_cart_outlined,
                  size: 100,
                  color: Constants.baseColor.withOpacity(0.2)),
              const SizedBox(height: 20),
              const Text("Your Cart is Empty",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey)),
              const SizedBox(height: 25),
              SizedBox(
                width: 200,
                height: 45,
                child: FilledButton(
                  onPressed: () =>
                      Routers.goNoBack(context, toBody: const MyHomePage()),
                  style: FilledButton.styleFrom(
                      backgroundColor: Constants.baseColor),
                  child: const Text("CONTINUE SHOPPING"),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartList() {
    return ListView.separated(
      padding: const EdgeInsets.all(15),
      itemCount: _cartItems.length,
      separatorBuilder: (context, index) =>
      const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: KskNetworkImage(item.image,
                      height: 80,
                      width: 80,
                      fit: BoxFit.contain),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      Text("Variant: ${item.variantTitle}",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text("${Constants.inr}${item.price}",
                          style: TextStyle(
                              color: Constants.baseColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () =>
                              _updateQty(item.id, 1),
                          icon: const Icon(Icons.add,
                              size: 18),
                          padding: EdgeInsets.zero,
                          constraints:
                          const BoxConstraints()),
                      Text("${item.qty}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      IconButton(
                          onPressed: () =>
                              _updateQty(item.id, -1),
                          icon: const Icon(Icons.remove,
                              size: 18),
                          padding: EdgeInsets.zero,
                          constraints:
                          const BoxConstraints()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15)),
              Text(_getTotalAmt(),
                  style: TextStyle(
                      color: Constants.baseColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22)),
            ],
          ),
          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton(
                onPressed: () {
                double totalVal = _getTotalValue();

                String ids = _cartItems.map((e) => e.id.split('/').last).join(',');

                // Meta Event: Initiate Checkout
                MetaEvents.initiateCheckout(totalValue: totalVal, contentIds: ids);

                // Firebase Event: begin_checkout
                FirebaseEvents.beginCheckout(totalVal);

                final cartData = _cartItems.map((e) {
                  final variantId = int.tryParse(e.id.split('/').last) ?? 0;
                  final productId = int.tryParse(e.productId?.split('/').last ?? '') ?? 0;
                  return {
                    "id": variantId,
                    "quantity": e.qty,
                    "variant_id": variantId,
                    "product_id": productId,
                    "title": e.title,
                    "price": double.tryParse(e.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0,
                    "image": e.image
                  };
                }).toList();

                Routers.goTO(context, toBody: AddressView(cartItems: cartData, totalValue: totalVal));
              },
              style: FilledButton.styleFrom(
                backgroundColor: Constants.baseColor,
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15)),
              ),
              child: const Text(
                "PROCEED TO SECURE CHECKOUT",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
