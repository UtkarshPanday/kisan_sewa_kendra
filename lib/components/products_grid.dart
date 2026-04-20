import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan_sewa_kendra/components/widget_button.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
import 'package:kisan_sewa_kendra/view/cart_view.dart';

import '../controller/constants.dart';
import '../controller/routers.dart';
import '../model/product_model.dart';
import '../shopify/shopify.dart';
import '../view/product_view.dart';
import '../controller/cart_controller.dart';
import '../utils/firebase_events.dart';
import '../utils/meta_events.dart';
import 'network_image.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import '../controller/pref.dart';
import 'cart_summary_bar.dart';

class ProductsGrid extends StatefulWidget {
  final String id;
  final int? limit;
  final bool isFilter;
  final bool shrinkWrap;
  final List<String>? excludeIds; // To prevent duplicates
  final Widget? header; // Optional scrollable header widget

  const ProductsGrid({
    super.key,
    required this.id,
    this.limit,
    this.isFilter = false,
    this.shrinkWrap = true,
    this.excludeIds,
    this.header,
  });

  @override
  State<ProductsGrid> createState() => ProductsGridState();
}

class ProductsGridState extends State<ProductsGrid>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _init);
    Constants.languageController.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    Constants.languageController.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _init();
    }
  }

  List<ProductModel> _products = [], _fullProducts = [];
  bool _isLoading = true;

  /// Public method to sort products from outside (e.g. CollectionView header)
  void sortProducts(String sortType) {
    setState(() {
      if (sortType == "a-z") {
        _products.sort((a, b) => a.title.compareTo(b.title));
      } else if (sortType == "z-a") {
        _products.sort((a, b) => b.title.compareTo(a.title));
      } else {
        _products = List.from(_fullProducts);
      }
    });
  }

  Future<void> _init() async {
    if (!mounted) return;
    if (widget.id.isEmpty || widget.id == "0") {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await Shopify.getProductsFromCollections(
        context,
        id: widget.id,
        limit: widget.limit != null
            ? (widget.limit! + (widget.excludeIds?.length ?? 0))
            : null,
      );

      if (mounted) {
        setState(() {
          List<ProductModel> list =
              (result['product'] as List<dynamic>?)?.cast<ProductModel>() ??
                  <ProductModel>[];

          // Filter out excluded IDs
          if (widget.excludeIds != null) {
            list =
                list.where((p) => !widget.excludeIds!.contains(p.id)).toList();
          }

          // Apply limit after exclusion
          if (widget.limit != null && list.length > widget.limit!) {
            list = list.sublist(0, widget.limit);
          }

          _products = list;
          _fullProducts = List.from(_products);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("ProductsGrid Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final width = MediaQuery.of(context).size.width;

    // Industry Standard: Dynamic Aspect Ratio
    // Industry Standard: Dynamic Aspect Ratio for feature-rich cards
    // We use a taller ratio (0.56) to fit ratings, titles, and steppers comfortably
    double aspectRatio =
        0.63; // Slightly more height to fix 0.2px Hindi overflow
    if (width < 360) {
      aspectRatio = 0.60;
    } else if (width > 420) {
      aspectRatio = 0.68;
    }

    // Main Grid/List content
    Widget content;
    if (_isLoading) {
      content = GridView.builder(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.shrinkWrap
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
        ),
        itemCount: widget.limit ?? 4,
        itemBuilder: (context, index) => _buildShimmerCard(),
      );
    } else if (_products.isEmpty) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noProductsFound,
              style: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      content = GridView.builder(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.shrinkWrap
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: aspectRatio,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) => ProductCard(product: _products[index]),
      );
    }

    // Wrap with header/filter if needed
    if (widget.header != null || widget.isFilter) {
      if (!widget.shrinkWrap && widget.header != null) {
        // Scrollable header with grid
        content = CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: widget.header!),
            if (widget.isFilter) SliverToBoxAdapter(child: _buildSortHeader()),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              sliver: _isLoading
                  ? SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: aspectRatio,
                      ),
                      delegate: SliverChildBuilderDelegate(
                          (_, __) => _buildShimmerCard(),
                          childCount: widget.limit ?? 4),
                    )
                  : (_products.isEmpty
                      ? SliverToBoxAdapter(
                          child: SizedBox(height: 200, child: content))
                      : SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: aspectRatio,
                          ),
                          delegate: SliverChildBuilderDelegate(
                              (_, index) =>
                                  ProductCard(product: _products[index]),
                              childCount: _products.length),
                        )),
            ),
          ],
        );
      } else {
        // Vertical column layout
        content = Column(
          mainAxisSize: widget.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (widget.header != null) widget.header!,
            if (widget.isFilter) _buildSortHeader(),
            widget.shrinkWrap ? content : Expanded(child: content),
          ],
        );
      }
    }

    // Final layout with cart summary if not shrinking
    if (widget.shrinkWrap) return content;

    return Stack(
      children: [
        Positioned.fill(child: content),
        const Positioned(
          bottom: 25,
          left: 0,
          right: 0,
          child: Center(
            child: CartSummaryBar(),
          ),
        ),
      ],
    );
  }

  Widget _buildSortHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(AppLocalizations.of(context)!.sortBy,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54)),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            elevation: 8,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            icon: Icon(Icons.swap_vert_rounded,
                color: Constants.baseColor, size: 22),
            onSelected: (value) {
              setState(() {
                if (value == "a-z") {
                  _products.sort((a, b) => a.title.compareTo(b.title));
                } else if (value == "z-a") {
                  _products.sort((a, b) => b.title.compareTo(a.title));
                } else {
                  _products = List.from(_fullProducts);
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: "a-z",
                  child: Text(AppLocalizations.of(context)!.aToZ)),
              PopupMenuItem(
                  value: "z-a",
                  child: Text(AppLocalizations.of(context)!.zToA)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              child: Constants.shimmer(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Constants.shimmer(height: 12, width: 40), // For rating pill
                  const SizedBox(height: 8),
                  Constants.shimmer(
                      height: 14, width: double.infinity), // Title line 1
                  const SizedBox(height: 4),
                  Constants.shimmer(height: 14, width: 100), // Title line 2
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Constants.shimmer(height: 10, width: 40),
                          const SizedBox(height: 4),
                          Constants.shimmer(height: 18, width: 60),
                        ],
                      ),
                      Constants.shimmer(height: 32, width: 60), // Add button
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _qty = 0;
  Timer? _timer;
  VariantModel? _activeVariant;

  @override
  void initState() {
    super.initState();
    _activeVariant = _minPriceVariant();
    _updateQty();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _updateQty();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updateQty() async {
    String? cart = await Pref.getPref(PrefKey.cart);
    if (cart != null) {
      List<dynamic> cartList = jsonDecode(cart);

      int totalQty = 0;
      VariantModel? firstFoundVariant;

      for (var v in widget.product.variants) {
        int index = cartList
            .indexWhere((item) => item['id'].toString() == v.id.toString());
        if (index >= 0) {
          int q = int.tryParse(cartList[index]['qty'].toString()) ?? 0;
          totalQty += q;
          firstFoundVariant ??= v;
        }
      }

      if (mounted) {
        setState(() {
          _qty = totalQty;
          if (firstFoundVariant != null) {
            _activeVariant = firstFoundVariant;
          }
        });
      }
    } else {
      if (mounted && _qty != 0) setState(() => _qty = 0);
    }
  }

  VariantModel? _minPriceVariant() {
    if (widget.product.variants.isEmpty) return null;
    final available =
        widget.product.variants.where((v) => v.inventoryQuantity > 0).toList();
    if (available.isEmpty) return widget.product.variants.first;
    available.sort((a, b) {
      final aPrice =
          double.tryParse(a.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      final bPrice =
          double.tryParse(b.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
      return aPrice.compareTo(bPrice);
    });
    return available.first;
  }

  int _getPackCount(String title) {
    // Searches for patterns like x2, x 2, (500gx2), Pack of 2
    final regex = RegExp(r'[xX]\s*(\d+)|Pack\s*of\s*(\d+)|(\d+)\s*[xX]');
    final match = regex.firstMatch(title);
    if (match != null) {
      for (int i = 1; i <= match.groupCount; i++) {
        if (match.group(i) != null) {
          return int.tryParse(match.group(i)!) ?? 1;
        }
      }
    }
    return 1;
  }

  Widget _buildRatingPill(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.star_rounded, color: Color(0xFF2E7D32), size: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final variant = _activeVariant ?? _minPriceVariant();
    if (variant == null) return const SizedBox.shrink();

    double fakeRating = 4.0 + (widget.product.id.hashCode % 11) / 10.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 65,
            child: WidgetButton(
              onTap: () => Routers.goTO(context,
                  toBody: ProductView(product: widget.product)),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(10),
                    child: KskNetworkImage(
                      widget.product.image ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                  _buildDiscountBadge(variant),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 35,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingPill(fakeRating),
                  const SizedBox(height: 1),
                  GestureDetector(
                    onTap: () => Routers.goTO(context,
                        toBody: ProductView(product: widget.product)),
                    child: Text(
                      widget.product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Routers.goTO(context,
                              toBody: ProductView(product: widget.product)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (variant.compareAtPrice != null &&
                                  variant.compareAtPrice!.isNotEmpty)
                                Text(
                                  "${Constants.inr}${variant.compareAtPrice}",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                "${Constants.inr}${variant.price}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Constants.baseColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _qty > 0
                          ? (widget.product.variants.length > 1
                              ? GestureDetector(
                                  onTap: () => _showVariantBottomSheet(context),
                                  child: _buildStepper(variant),
                                )
                              : _buildStepper(variant))
                          : GestureDetector(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                if (widget.product.variants.length > 1) {
                                  _showVariantBottomSheet(context);
                                } else {
                                  _addToCart(variant);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Constants.baseColor, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        AppLocalizations.of(context)!.add,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: Constants.baseColor),
                                      ),
                                    ),
                                    if (widget.product.variants.length > 1)
                                      Text(
                                        AppLocalizations.of(context)!.options,
                                        style: TextStyle(
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                            color: Constants.baseColor
                                                .withOpacity(0.6)),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVariantBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        List<dynamic> localCart = [];
        return StatefulBuilder(
          builder: (context, setSheetState) {
            // Helper to get qty from local sheet state
            int getVQty(String vId) {
              int idx =
                  localCart.indexWhere((item) => item['id'].toString() == vId);
              return idx >= 0
                  ? (int.tryParse(localCart[idx]['qty'].toString()) ?? 0)
                  : 0;
            }

            return FutureBuilder<String?>(
              future: Pref.getPref(PrefKey.cart),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.data != null) {
                    localCart = jsonDecode(snapshot.data!);
                  } else {
                    localCart = [];
                  }
                }

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.selectOption,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded, size: 20),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: widget.product.variants.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final v = widget.product.variants[index];
                            int vQty = getVQty(v.id);

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 4),
                              decoration: BoxDecoration(
                                color: vQty > 0
                                    ? Constants.baseColor.withOpacity(0.05)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: 45,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.grey[100]!),
                                          color: Colors.white,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: KskNetworkImage(
                                            widget.product.image ?? '',
                                            fit: BoxFit.contain),
                                      ),
                                      if (_getPackCount(v.title) > 1)
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Constants.baseColor,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1),
                                            ),
                                            child: Text(
                                              "x${_getPackCount(v.title)}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 7,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          v.title,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: vQty > 0
                                                  ? FontWeight.w900
                                                  : FontWeight.w700),
                                        ),
                                        Text(
                                          "${Constants.inr}${v.price}",
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: vQty > 0
                                                  ? Constants.baseColor
                                                  : Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  vQty > 0
                                      ? _buildMiniStepper(
                                          v, vQty, setSheetState)
                                      : GestureDetector(
                                          onTap: () async {
                                            HapticFeedback.lightImpact();
                                            await _addToCart(v);
                                            setSheetState(() {});
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 18, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Constants.baseColor,
                                                  width: 1.5),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!.add,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: Constants.baseColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _addToCart(VariantModel variant) async {
    MetaEvents.addToCart(
      id: widget.product.id,
      name: widget.product.title,
      price: variant.price,
    );
    FirebaseEvents.addToCart(widget.product.id, variant.price);

    await CartController.addToCart(
      variantId: variant.id,
      productId: widget.product.id,
      qty: 1,
      title: widget.product.title,
      price: variant.price,
      image: widget.product.image,
      variantTitle: variant.title,
    );
    if (mounted) {
      setState(() {
        _activeVariant = variant;
      });
    }
    _updateQty();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Added to cart",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Constants.baseColor,
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildMiniStepper(
      VariantModel variant, int qty, StateSetter setSheetState) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Constants.baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _cartStyleBtn(
              qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
              () async {
            HapticFeedback.mediumImpact();
            await CartController.updateQty(variant.id, qty - 1);
            setSheetState(() {});
            _updateQty();
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              "$qty",
              style: GoogleFonts.outfit(
                  color: Constants.baseColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 14),
            ),
          ),
          _cartStyleBtn(Icons.add_rounded, () async {
            HapticFeedback.lightImpact();
            await CartController.updateQty(variant.id, qty + 1);
            setSheetState(() {});
            _updateQty();
          }),
        ],
      ),
    );
  }

  Widget _buildStepper(VariantModel variant) {
    // If multiple variants exist, the entire stepper acts as a button
    if (widget.product.variants.length > 1) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _showVariantBottomSheet(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          decoration: BoxDecoration(
            color: Constants.baseColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cartStyleBtn(Icons.remove_rounded, null),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "$_qty",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Constants.baseColor,
                  ),
                ),
              ),
              _cartStyleBtn(Icons.add_rounded, null),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: Constants.baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _cartStyleBtn(
              _qty == 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
              () async {
            HapticFeedback.mediumImpact();
            await CartController.updateQty(variant.id, _qty - 1);
            _updateQty();
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "$_qty",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: Constants.baseColor,
              ),
            ),
          ),
          _cartStyleBtn(Icons.add_rounded, () async {
            HapticFeedback.lightImpact();
            await CartController.updateQty(variant.id, _qty + 1);
            _updateQty();
          }),
        ],
      ),
    );
  }

  Widget _cartStyleBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
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

  Widget _buildDiscountBadge(VariantModel variant) {
    if (variant.compareAtPrice == null || variant.compareAtPrice!.isEmpty)
      return const SizedBox.shrink();
    try {
      double mrp = double.parse(variant.compareAtPrice!
          .replaceAll(Constants.inr, '')
          .replaceAll(',', ''));
      double sp = double.parse(
          variant.price.replaceAll(Constants.inr, '').replaceAll(',', ''));
      double per = (100 * (mrp - sp)) / mrp;
      if (per > 1) {
        return Positioned(
          top: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
                topRight: Radius.zero,
                bottomLeft: Radius.zero,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Text(
              AppLocalizations.of(context)!.off(per.toInt().toString()),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800),
            ),
          ),
        );
      }
    } catch (_) {}
    return const SizedBox.shrink();
  }
}
