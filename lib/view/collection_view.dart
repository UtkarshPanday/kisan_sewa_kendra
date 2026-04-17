import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan_sewa_kendra/components/products_grid.dart';
import 'package:kisan_sewa_kendra/controller/constants.dart';
import 'package:kisan_sewa_kendra/shopify/shopify.dart';

import '../components/cart_icon.dart';
import '../controller/pref.dart';
import '../view/cart_view.dart';
import '../controller/routers.dart';
import 'dart:async';

class CollectionView extends StatefulWidget {
  final String collectionId;
  final String? title;
  const CollectionView({super.key, required this.collectionId, this.title});

  @override
  State<CollectionView> createState() => _CollectionViewState();
}

class _CollectionViewState extends State<CollectionView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _title = '';

  final GlobalKey<ProductsGridState> _gridKey = GlobalKey<ProductsGridState>();

  int _cartItemCount = 0;
  double _cartTotal = 0;
  Timer? _cartTimer;

  @override
  void initState() {
    super.initState();
    _title = widget.title ?? '';
    _startCartTimer();
    Future.delayed(Duration.zero, _init);
  }

  void _startCartTimer() {
    _updateCartSummary();
    _cartTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateCartSummary();
    });
  }

  @override
  void dispose() {
    _cartTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateCartSummary() async {
    String? cart = await Pref.getPref(PrefKey.cart);
    if (cart != null) {
      List<dynamic> cartList = jsonDecode(cart);
      double total = 0;
      int count = 0;
      for (var item in cartList) {
        double price = double.tryParse(
                item['price'].toString().replaceAll(RegExp(r'[^\d.]'), '')) ??
            0;
        int qty = int.tryParse(item['qty'].toString()) ?? 0;
        total += (price * qty);
        count += qty;
      }
      if (mounted && (_cartItemCount != count || _cartTotal != total)) {
        setState(() {
          _cartItemCount = count;
          _cartTotal = total;
        });
      }
    } else {
      if (mounted && _cartItemCount != 0) {
        setState(() {
          _cartItemCount = 0;
          _cartTotal = 0;
        });
      }
    }
  }

  _init() async {
    if (!mounted) return;
    var col = await ShopifyAPI.getCollection(id: widget.collectionId);
    if (mounted && widget.title == null) {
      setState(() {
        _title = "${col['title'] ?? ''}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final topPad = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Shapes
            Positioned(
              top: -50,
              right: -30,
              child: _buildShape(200, 0.04),
            ),
            Positioned(
              top: 220,
              left: -40,
              child: _buildShape(120, 0.03),
            ),

            // Products Grid — takes the main space
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: topPad + 66),
                child: ProductsGrid(
                  key: _gridKey,
                  isFilter: false,
                  id: widget.collectionId,
                  shrinkWrap: false,
                ),
              ),
            ),

            // Frosted Glass Header (floating on top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildFrostedHeader(topPad),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShape(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Constants.baseColor.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  /// Frosted glass header with back button and sort

  Widget _buildFrostedHeader(double topPad) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPad + 8, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(
              bottom: BorderSide(color: Colors.grey.withOpacity(0.05)),
            ),
          ),
          child: Row(
            children: [
              _circleIconBtn(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _title.isNotEmpty ? _title : "Collection",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Constants.baseColor,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "KrishiKranti Organics • Pure Selection",
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
              const KskCartIcon(showBackground: true),
              const SizedBox(width: 8),
              // Sort button
              _buildSortButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      offset: const Offset(0, 44),
      onSelected: (value) {
        HapticFeedback.lightImpact();
        _gridKey.currentState?.sortProducts(value);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: "a-z",
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha_rounded,
                  size: 18, color: Constants.baseColor),
              const SizedBox(width: 10),
              Text("A → Z",
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        PopupMenuItem(
          value: "z-a",
          child: Row(
            children: [
              Icon(Icons.sort_by_alpha_rounded,
                  size: 18, color: Constants.baseColor),
              const SizedBox(width: 10),
              Text("Z → A",
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        PopupMenuItem(
          value: "default",
          child: Row(
            children: [
              Icon(Icons.restart_alt_rounded,
                  size: 18, color: Colors.grey[500]),
              const SizedBox(width: 10),
              Text("Default",
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Constants.baseColor.withOpacity(0.06),
          shape: BoxShape.circle,
        ),
        child:
            Icon(Icons.swap_vert_rounded, size: 20, color: Constants.baseColor),
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
}
