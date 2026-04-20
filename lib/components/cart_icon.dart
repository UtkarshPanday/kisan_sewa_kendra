import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/constants.dart';
import '../controller/pref.dart';
import '../view/cart_view.dart';
import '../controller/routers.dart';

class KskCartIcon extends StatefulWidget {
  final Color? color;
  final bool showBackground;

  const KskCartIcon({
    super.key,
    this.color,
    this.showBackground = false,
  });

  @override
  State<KskCartIcon> createState() => _KskCartIconState();
}

class _KskCartIconState extends State<KskCartIcon> {
  int _cartCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCartCount() async {
    _updateCartCount();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateCartCount();
    });
  }

  Future<void> _updateCartCount() async {
    String? cart = await Pref.getPref(PrefKey.cart);
    int count = 0;
    if (cart != null) {
      List<dynamic> cartList = jsonDecode(cart);
      count = cartList.length;
    }
    if (mounted && _cartCount != count) {
      setState(() {
        _cartCount = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = badges.Badge(
      showBadge: _cartCount > 0,
      badgeContent: Text(
        "$_cartCount",
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      badgeStyle: badges.BadgeStyle(
        badgeColor: const Color(0xFFE53935), // Urgent Red for visibility
        padding: const EdgeInsets.all(5),
        elevation: 2,
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      position: badges.BadgePosition.topEnd(top: -8, end: -8),
      child: Icon(
        Icons.shopping_cart_outlined,
        color: widget.color ??
            (widget.showBackground ? Colors.black87 : Constants.baseColor),
        size: 26,
      ),
    );

    if (widget.showBackground) {
      return GestureDetector(
        onTap: () => Routers.goTO(context, toBody: const CartView()),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey[100]!, width: 1),
          ),
          child: Center(child: icon),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Routers.goTO(context, toBody: const CartView()),
      child: icon,
    );
  }
}
