import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kisan_sewa_kendra/components/products_grid.dart';
import 'package:kisan_sewa_kendra/view/cart_view.dart';

import 'dart:async';
import 'dart:convert';
import 'package:badges/badges.dart' as badges;
import '../controller/pref.dart';

import 'package:flutter/services.dart';
import '../components/network_image.dart';
import '../components/widget_button.dart';
import '../controller/constants.dart';
import '../controller/routers.dart';
import '../model/product_model.dart';
import '../shopify/shopify.dart';
import '../controller/cart_controller.dart';
import '../utils/meta_events.dart';
import '../utils/firebase_events.dart';

class ProductView extends StatefulWidget {
  final ProductModel product;

  const ProductView({
    super.key,
    required this.product,
  });

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final CarouselSliderController _controller = CarouselSliderController();
  int _carouselIndex = 0, _varientIndex = 0;
  List<ProductModel> _recommend = [];
  bool _enableAutoPlay = false;
  late TabController _tabController;
  bool _isExpanded = false;
  int _cartCount = 0;
  List<dynamic> _cartItems = [];
  Timer? _timer;

  // Review states
  double _userRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final List<Map<String, dynamic>> _reviews = [
    {
      "name": "Rahul Sharma",
      "rating": 5.0,
      "comment":
          "Very effective product. I saw results in just 1 week. Highly recommended!",
      "date": "2 days ago"
    },
    {
      "name": "Amit Patel",
      "rating": 4.0,
      "comment":
          "Good quality and original product. Packaging was also very good.",
      "date": "5 days ago"
    }
  ];

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    Future.delayed(Duration.zero, _init);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _enableAutoPlay = true;
        });
      }
    });

    // FB Event: View Content
    MetaEvents.viewContent(
      id: widget.product.id,
      name: widget.product.title,
      price: widget.product.variants.isNotEmpty
          ? widget.product.variants.first.price
          : '0',
    );

    // Firebase Event: view_item
    FirebaseEvents.viewItem(
      widget.product.id,
      widget.product.variants.isNotEmpty
          ? widget.product.variants.first.price
          : '0',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchCartCount() async {
    _updateCartCount();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateCartCount();
    });
  }

  Future<void> _updateCartCount() async {
    String? cart = await Pref.getPref(PrefKey.cart);
    int count = 0;
    List<dynamic> parsedList = [];
    if (cart != null) {
      parsedList = jsonDecode(cart);
      count = parsedList.length;
    }
    if (mounted) {
      setState(() {
        _cartCount = count;
        _cartItems = parsedList;
      });
    }
  }

  int _getCartQuantity() {
    if (widget.product.variants.isEmpty) return 0;
    final variant = widget.product.variants[_varientIndex];
    for (var item in _cartItems) {
      if (item['id'].toString() == variant.id.toString()) {
        return int.tryParse(item['qty'].toString()) ?? 0;
      }
    }
    return 0;
  }

  Future<void> _init() async {
    _recommend = await Shopify.getProductsRecommend(
      context,
      id: widget.product.id.toString(),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildQuantitySelector(int currentQty) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F6),
        border: Border.all(color: Constants.baseColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              final variant = widget.product.variants[_varientIndex];
              await CartController.updateQty(variant.id, currentQty - 1);
              _updateCartCount();
            },
            icon: Icon(currentQty == 1 ? Icons.delete_outline : Icons.remove,
                color: Constants.baseColor),
          ),
          Text(
            "$currentQty",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          IconButton(
            onPressed: () async {
              final variant = widget.product.variants[_varientIndex];
              await CartController.updateQty(variant.id, currentQty + 1);
              _updateCartCount();
            },
            icon: Icon(Icons.add, color: Constants.baseColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String line1, String line2) {
    return Column(
      children: [
        Icon(icon, color: Colors.green[700], size: 20),
        const SizedBox(height: 4),
        Text(line1,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.black87)),
        Text(line2,
            style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _discount({
    required String? comparePrice,
    required String sellingPrice,
  }) {
    if (comparePrice == null || comparePrice.isEmpty)
      return const SizedBox.shrink();

    try {
      double mrp = double.parse(
              comparePrice.replaceAll(Constants.inr, '').replaceAll(',', '')),
          sp = double.parse(
              sellingPrice.replaceAll(Constants.inr, '').replaceAll(',', ''));

      double per = (100 * (mrp - sp)) / mrp;

      if (per > 0) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: Text(
            "${per.toInt()}% OFF",
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        );
      }
    } catch (e) {
      return const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  Widget _buildRatingStars(double rating, {double size = 16}) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < fullStars
                ? Icons.star_rounded
                : (i == fullStars && hasHalfStar
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded),
            color: Colors.amber,
            size: size,
          ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.87,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.product.variants.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.product.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body:
            const Center(child: Text("Product details currently unavailable")),
      );
    }

    final variant = widget.product.variants[_varientIndex];
    double fakeRating = 4.0 + (widget.product.id.hashCode % 11) / 10.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          ),
          leading: Container(
            margin: const EdgeInsets.only(left: 14, top: 6, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 14, top: 6, bottom: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: IconButton(
                icon: badges.Badge(
                  badgeContent: Text('$_cartCount',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold)),
                  position: badges.BadgePosition.topEnd(top: -4, end: -4),
                  showBadge: _cartCount > 0,
                  badgeStyle: const badges.BadgeStyle(
                      badgeColor: Colors.green, padding: EdgeInsets.all(4)),
                  child: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.black87, size: 20),
                ),
                onPressed: () =>
                    Routers.goTO(context, toBody: const CartView()),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Gallery ---
            Stack(
              children: [
                CarouselSlider(
                  carouselController: _controller,
                  options: CarouselOptions(
                    aspectRatio: 1.25,
                    viewportFraction: 1,
                    autoPlay: widget.product.images.length > 1
                        ? _enableAutoPlay
                        : false,
                    enableInfiniteScroll: widget.product.images.length > 1,
                    onPageChanged: (index, _) {
                      setState(() => _carouselIndex = index);
                    },
                  ),
                  items: widget.product.images.map((img) {
                    return KskNetworkImage(img, fit: BoxFit.contain);
                  }).toList(),
                ),
                if (widget.product.images.length > 1)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          widget.product.images.asMap().entries.map((entry) {
                        return Container(
                          width: _carouselIndex == entry.key ? 22 : 7.0,
                          height: 7.0,
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Constants.baseColor.withOpacity(
                                _carouselIndex == entry.key ? 1.0 : 0.2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),

            // --- Product Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "Brand: KrishiKranti Organics",
                      style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8F6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.flash_on_rounded,
                                color: Colors.green, size: 12),
                            const SizedBox(width: 4),
                            const Text(
                              "Fast Delivery",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      _buildRatingStars(fakeRating),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${Constants.inr}${variant.price}",
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black),
                      ),
                      if (variant.compareAtPrice != null) ...[
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            "${Constants.inr}${variant.compareAtPrice}",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                                decoration: TextDecoration.lineThrough),
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      _discount(
                          comparePrice: variant.compareAtPrice,
                          sellingPrice: variant.price),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("Inclusive of all taxes",
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTrustBadge(
                            Icons.verified_user_outlined, "100%", "Original"),
                        Container(
                            width: 1, height: 30, color: Colors.grey[300]),
                        _buildTrustBadge(Icons.assignment_return_outlined,
                            "Easy", "Returns"),
                        Container(
                            width: 1, height: 30, color: Colors.grey[300]),
                        _buildTrustBadge(
                            Icons.local_shipping_outlined, "Fast", "Dispatch"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(height: 6, color: const Color(0xFFF4F6F8)),

            // --- Select Variant Section (Pills Style) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Variant",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Colors.black87)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        List.generate(widget.product.variants.length, (i) {
                      final v = widget.product.variants[i];
                      final isSelected = _varientIndex == i;
                      final isOutOfStock = v.inventoryQuantity <= 0;

                      return GestureDetector(
                        onTap: isOutOfStock
                            ? null
                            : () => setState(() => _varientIndex = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF1F8F6)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.green : Colors.grey[300]!,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Opacity(
                            opacity: isOutOfStock ? 0.3 : 1.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  v.title,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.green[800]
                                        : Colors.black87,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${Constants.inr}${v.price}",
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.green[800]
                                        : Colors.grey[700],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            Container(height: 6, color: const Color(0xFFF4F6F8)),

            // --- Tabs Header ---
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Colors.black87,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 0.5),
                tabs: const [
                  Tab(text: "OVERVIEW"),
                  Tab(text: "DETAILS"),
                ],
              ),
            ),

            // --- Tab Content ---
            Container(
              color: Colors.white,
              child: _tabController.index == 0
                  ? _buildOverviewContent()
                  : _buildDescriptionContent(),
            ),

            Container(height: 6, color: const Color(0xFFF4F6F8)),

            // --- How to Use ---
            Container(color: Colors.white, child: _buildHowToUseSection()),

            Container(height: 6, color: const Color(0xFFF4F6F8)),

            // --- Customer Reviews ---
            Container(color: Colors.white, child: _buildReviewsListSection()),

            // --- Write a Review ---
            Container(color: Colors.white, child: _buildWriteReviewSection()),

            Container(height: 6, color: const Color(0xFFF4F6F8)),

            // --- Similar Products ---
            if (_recommend.isNotEmpty) ...[
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Similar Products",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: Colors.black)),
                    Text("View All",
                        style: TextStyle(
                            color: Constants.baseColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                  ],
                ),
              ),
              SizedBox(
                height: 290,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20, bottom: 20),
                  itemCount: _recommend.length,
                  itemBuilder: (context, index) => Container(
                    width: 185,
                    margin: const EdgeInsets.only(right: 15),
                    child: ProductCard(product: _recommend[index]),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 180), // Increased bottom spacing
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: _getCartQuantity() > 0
                    ? _buildQuantitySelector(_getCartQuantity())
                    : ElevatedButton(
                        onPressed: () async {
                          // Meta Event: Add to Cart
                          MetaEvents.addToCart(
                            id: widget.product.id,
                            name: widget.product.title,
                            price: variant.price,
                          );

                          // Firebase Event: add_to_cart
                          FirebaseEvents.addToCart(
                              widget.product.id, variant.price);

                          await CartController.addToCart(
                            variantId: variant.id,
                            productId: widget.product.id,
                            qty: 1,
                            title: widget.product.title,
                            price: variant.price,
                            image: widget.product.image,
                            variantTitle: variant.title,
                          );
                          if (!context.mounted) return;
                          _updateCartCount();
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("Product added to cart!",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              backgroundColor: Constants.baseColor,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(milliseconds: 1000),
                              margin: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7941D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.zero, // Prevent text overflow
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text("Add to Cart",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 16)),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final variantId =
                        int.tryParse(variant.id.split('/').last) ?? 0;
                    final productId =
                        int.tryParse(widget.product.id.split('/').last) ?? 0;

                    double price = double.tryParse(
                            variant.price.replaceAll(RegExp(r'[^\d.]'), '')) ??
                        0.0;

                    // Meta Event: Initiate Checkout
                    MetaEvents.initiateCheckout(
                      totalValue: price,
                      contentIds: widget.product.id,
                    );

                    // Firebase Event: begin_checkout
                    FirebaseEvents.beginCheckout(price);

                    final cartData = [
                      {
                        "id": variantId,
                        "quantity": 1,
                        "variant_id": variantId,
                        "product_id": productId,
                        "title": widget.product.title,
                        "price": price,
                        "image": widget.product.image
                      }
                    ];

                    await CartController.addToCart(
                      variantId: variant.id,
                      productId: widget.product.id,
                      qty: 1,
                      title: widget.product.title,
                      price: variant.price,
                      image: widget.product.image,
                      variantTitle: variant.title,
                    );
                    if (!context.mounted) return;
                    Routers.goTO(context, toBody: const CartView());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.baseColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero, // Prevent text overflow
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("Buy Now",
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewContent() {
    final Map<String, String> details = {
      "Product Name": widget.product.title,
      "Brand": "KrishiKranti Organics",
      "Category": widget.product.productType,
    };

    String techContent = "";
    if (widget.product.title.contains('(') &&
        widget.product.title.contains(')')) {
      techContent = widget.product.title.substring(
          widget.product.title.lastIndexOf('(') + 1,
          widget.product.title.lastIndexOf(')'));
    }

    if (techContent.isNotEmpty) {
      details["Technical Content"] = techContent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: details.entries
            .where((e) => e.value.isNotEmpty)
            .toList()
            .asMap()
            .entries
            .map((entry) {
          final isEven = entry.key % 2 == 0;
          return Container(
            color: isEven ? Colors.grey[50] : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(entry.value.key,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ),
                Expanded(
                  child: Text(entry.value.value,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.4)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescriptionContent() {
    if (widget.product.body.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
            child: Text("No description available.",
                style: TextStyle(color: Colors.grey))),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About Product",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: Colors.black)),
          const SizedBox(height: 15),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: _isExpanded
                  ? const BoxConstraints()
                  : const BoxConstraints(
                      maxHeight: 250), // Increased default height
              child: ClipRect(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: HtmlWidget(
                        widget.product.body,
                        textStyle: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            height: 1.7),
                      ),
                    ),
                    if (!_isExpanded)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0),
                                Colors.white.withOpacity(0.9),
                                Colors.white,
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: WidgetButton(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Constants.baseColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded ? "VIEW LESS" : "VIEW MORE",
                      style: TextStyle(
                          color: Constants.baseColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Constants.baseColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToUseSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Constants.baseColor.withOpacity(0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.help_outline_rounded,
                    color: Constants.baseColor, size: 18),
              ),
              const SizedBox(width: 10),
              const Text("How to Use",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      color: Colors.black)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0F0F0)),
            ),
            child: Column(
              children: [
                _usageItem(Icons.water_drop_outlined, "Dosage",
                    "Mix 2-3 ml per liter of water."),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEBEBEB))),
                _usageItem(Icons.schedule_rounded, "Apply Time",
                    "Best applied during early morning or evening."),
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFEBEBEB))),
                _usageItem(Icons.auto_awesome_outlined, "Method",
                    "Foliar spray for maximum effectiveness."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _usageItem(IconData icon, String title, String desc) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)
              ]),
          child: Icon(icon, color: Constants.baseColor, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.black87)),
              const SizedBox(height: 4),
              Text(desc,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey[600], height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWriteReviewSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Write a Review",
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            "Share your experience with this product",
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Star Rating Input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => setState(() => _userRating = index + 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    index < _userRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 40,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Review Text Field
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Describe your experience...",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF0F0F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: Constants.baseColor.withOpacity(0.5)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_userRating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a rating")),
                  );
                  return;
                }

                if (_reviewController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please write a review message")),
                  );
                  return;
                }

                // Add review to local list
                setState(() {
                  _reviews.insert(0, {
                    "name": "You",
                    "rating": _userRating,
                    "comment": _reviewController.text.trim(),
                    "date": "Just now"
                  });
                  _userRating = 0;
                  _reviewController.clear();
                  FocusScope.of(context).unfocus();
                });

                // Show success feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Review submitted successfully!"),
                    backgroundColor: Constants.baseColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.baseColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                "SUBMIT REVIEW",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsListSection() {
    if (_reviews.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            "Customer Reviews",
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _reviews.length,
          itemBuilder: (context, index) {
            final review = _reviews[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF0F0F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        review['date'],
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildRatingStars(review['rating'], size: 14),
                  const SizedBox(height: 8),
                  Text(
                    review['comment'],
                    style: const TextStyle(
                        color: Colors.black87, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
