import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/constants.dart';
import '../controller/pref.dart';
import '../controller/routers.dart';
import '../view/cart_view.dart';
import 'network_image.dart';

class CartSummaryBar extends StatefulWidget {
  const CartSummaryBar({super.key});

  @override
  State<CartSummaryBar> createState() => _CartSummaryBarState();
}

class _CartSummaryBarState extends State<CartSummaryBar> {
  int _cartItemCount = 0;
  double _cartTotal = 0;
  List<String> _cartImages = [];
  Timer? _cartTimer;

  @override
  void initState() {
    super.initState();
    _startCartTimer();
  }

  @override
  void dispose() {
    _cartTimer?.cancel();
    super.dispose();
  }

  void _startCartTimer() {
    _updateCartSummary();
    _cartTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateCartSummary();
    });
  }

  Future<void> _updateCartSummary() async {
    String? cart = await Pref.getPref(PrefKey.cart);
    if (cart != null) {
      List<dynamic> cartList = jsonDecode(cart);
      double total = 0;
      int count = 0;
      List<String> images = [];
      for (var item in cartList) {
        double price = double.tryParse(
                item['price'].toString().replaceAll(RegExp(r'[^\d.]'), '')) ??
            0;
        int qty = int.tryParse(item['qty'].toString()) ?? 0;
        total += (price * qty);
        count += qty;
        if (item['image'] != null && item['image'].toString().isNotEmpty) {
          String imageUrl = item['image'].toString();
          if (imageUrl.startsWith("//")) {
            imageUrl = "https:$imageUrl";
          }
          if (!images.contains(imageUrl)) {
            images.add(imageUrl);
          }
        }
      }

      final limitedImages =
          images.length > 3 ? images.sublist(images.length - 3) : images;

      if (mounted &&
          (_cartItemCount != count ||
              _cartTotal != total ||
              _cartImages.toString() != limitedImages.toString())) {
        setState(() {
          _cartItemCount = count;
          _cartTotal = total;
          _cartImages = limitedImages;
        });
      }
    } else {
      if (mounted && _cartItemCount != 0) {
        setState(() {
          _cartItemCount = 0;
          _cartTotal = 0;
          _cartImages = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cartItemCount == 0) return const SizedBox.shrink();

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          Routers.goTO(context, toBody: const CartView());
        },
        child: Container(
          height: 51,
          padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Constants.baseColor.withOpacity(1.0),
                Constants.baseColor,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.2,
            ),
            boxShadow: const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_cartImages.isNotEmpty) ...[
                SizedBox(
                  width: (34.0 + (math.min(_cartImages.length, 3) - 1) * 20.0),
                  height: 34,
                  child: Stack(
                    children: List.generate(
                      math.min(_cartImages.length, 3),
                      (index) => Positioned(
                        left: index * 20.0,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Constants.baseColor, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(1, 1),
                              )
                            ],
                          ),
                          child: ClipOval(
                            child: KskNetworkImage(
                              _cartImages[index],
                              width: 34,
                              height: 34,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "VIEW CART",
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.5),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      "$_cartItemCount item${_cartItemCount > 1 ? 's' : ''} added",
                      key: ValueKey<int>(_cartItemCount),
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 82, 81, 81).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
