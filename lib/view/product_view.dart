import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:kisan_sewa_kendra/components/products_grid.dart';
import 'package:kisan_sewa_kendra/view/checkout/shiprocket_checkout.dart';

import '../components/ksk_appbar.dart';
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

  // Review states
  double _userRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      price: widget.product.variants.first.price,
    );

    // Firebase Event: view_item
    FirebaseEvents.viewItem(
      widget.product.id,
      widget.product.variants.first.price,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
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

  Widget _discount({
    required String? comparePrice,
    required String sellingPrice,
  }) {
    if (comparePrice == null || comparePrice.isEmpty) return const SizedBox.shrink();

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
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(6),
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

  Widget _buildRatingStars(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < fullStars
                ? Icons.star_rounded
                : (i == fullStars && hasHalfStar ? Icons.star_half_rounded : Icons.star_outline_rounded),
            color: Colors.amber,
            size: 16,
          ),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 14,
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
    final variant = widget.product.variants[_varientIndex];
    double fakeRating = 4.0 + (widget.product.id.hashCode % 11) / 10.0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: KskAppbar(
        title: widget.product.title,
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
                  controller: _controller,
                  options: CarouselOptions(
                    aspectRatio: 1.1,
                    viewportFraction: 1,
                    autoPlay: _enableAutoPlay,
                    onPageChanged: (index, _) {
                      setState(() => _carouselIndex = index);
                    },
                  ),
                  items: widget.product.images.map((img) {
                    return KskNetworkImage(img, fit: BoxFit.contain);
                  }).toList(),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.product.images.asMap().entries.map((entry) {
                      return Container(
                        width: _carouselIndex == entry.key ? 22 : 7.0,
                        height: 7.0,
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Constants.baseColor.withOpacity(_carouselIndex == entry.key ? 1.0 : 0.2),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // --- Product Header ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Constants.baseColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "KrishiKranti Organics".toUpperCase(),
                          style: TextStyle(color: Constants.baseColor, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w900),
                        ),
                      ),
                      _buildRatingStars(fakeRating),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${Constants.inr}${variant.price}",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Constants.baseColor),
                          ),
                          if (variant.compareAtPrice != null)
                            Text(
                              "${Constants.inr}${variant.compareAtPrice}",
                              style: TextStyle(fontSize: 16, color: Colors.grey[400], decoration: TextDecoration.lineThrough),
                            ),
                        ],
                      ),
                      const Spacer(),
                      _discount(comparePrice: variant.compareAtPrice, sellingPrice: variant.price),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            // --- Select Variant Section (Grid Style) ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Variant", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.product.variants.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, 
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2.1, 
                      ),
                      itemBuilder: (context, i) {
                        final v = widget.product.variants[i];
                        final isSelected = _varientIndex == i;
                        final isOutOfStock = v.inventoryQuantity <= 0;

                        return WidgetButton(
                          onTap: isOutOfStock ? null : () => setState(() => _varientIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? Constants.baseColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Constants.baseColor : Colors.grey[300]!,
                                width: 1.5,
                              ),
                              boxShadow: isSelected ? [BoxShadow(color: Constants.baseColor.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 3))] : [],
                            ),
                            child: Opacity(
                              opacity: isOutOfStock ? 0.5 : 1.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    v.title,
                                    maxLines: 1, 
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis, 
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13, 
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${Constants.inr}${v.price}",
                                    style: TextStyle(
                                      color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                                      fontSize: 13, 
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isOutOfStock)
                                    const Text(
                                      "OUT OF STOCK",
                                      style: TextStyle(color: Colors.red, fontSize: 8, fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            // --- Tabs Header ---
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Constants.baseColor,
                unselectedLabelColor: Colors.grey[400],
                indicatorColor: Constants.baseColor,
                indicatorWeight: 4,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.5),
                tabs: const [
                  Tab(text: "OVERVIEW"),
                  Tab(text: "DESCRIPTION"),
                ],
              ),
            ),

            // --- Tab Content ---
            _tabController.index == 0 
                ? _buildOverviewContent() 
                : _buildDescriptionContent(),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            // --- How to Use ---
            _buildHowToUseSection(),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

            // --- Write a Review ---
            _buildWriteReviewSection(),

            // --- Similar Products ---
            if (_recommend.isNotEmpty) ...[
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Similar Products", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
                    Text("View All", style: TextStyle(color: Constants.baseColor, fontWeight: FontWeight.bold, fontSize: 14)),
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
            const SizedBox(height: 140),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    // Meta Event: Add to Cart
                    MetaEvents.addToCart(
                      id: widget.product.id,
                      name: widget.product.title,
                      price: variant.price,
                    );

                    // Firebase Event: add_to_cart
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
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Product added to cart!", style: TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Constants.baseColor,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7941D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Add to Cart", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final variantId = int.tryParse(variant.id.split('/').last) ?? 0;
                    final productId = int.tryParse(widget.product.id.split('/').last) ?? 0;
                    
                    double price = double.tryParse(variant.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

                    // Meta Event: Initiate Checkout
                    MetaEvents.initiateCheckout(
                      totalValue: price,
                      contentIds: widget.product.id,
                    );

                    // Firebase Event: begin_checkout
                    FirebaseEvents.beginCheckout(price);

                    final cartData = [{
                      "id": variantId,
                      "quantity": 1,
                      "variant_id": variantId,
                      "product_id": productId,
                      "title": widget.product.title,
                      "price": price,
                      "image": widget.product.image
                    }];

                    Routers.goTO(context, toBody: ShiprocketCheckout(cartItems: cartData, totalValue: price));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.baseColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Buy Now", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
    if (widget.product.title.contains('(') && widget.product.title.contains(')')) {
      techContent = widget.product.title.substring(widget.product.title.lastIndexOf('(') + 1, widget.product.title.lastIndexOf(')'));
    }
    
    if (techContent.isNotEmpty) {
      details["Technical Content"] = techContent;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: details.entries.where((e) => e.value.isNotEmpty).toList().asMap().entries.map((entry) {
          final isEven = entry.key % 2 == 0;
          return Container(
            color: isEven ? Colors.grey[50] : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 130,
                  child: Text(entry.value.key, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 14)),
                ),
                Expanded(
                  child: Text(entry.value.value, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 14, height: 1.4)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDescriptionContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About Product", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black)),
          const SizedBox(height: 15),
          
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: _isExpanded ? const BoxConstraints() : const BoxConstraints(maxHeight: 160),
              child: ClipRect(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: HtmlWidget(
                        widget.product.body,
                        textStyle: const TextStyle(fontSize: 14, color: Color(0xFF666666), height: 1.7),
                      ),
                    ),
                    if (!_isExpanded)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0),
                                Colors.white.withOpacity(0.8),
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
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Constants.baseColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded ? "VIEW LESS" : "VIEW MORE",
                      style: TextStyle(color: Constants.baseColor, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
                decoration: BoxDecoration(color: Constants.baseColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.help_outline_rounded, color: Constants.baseColor, size: 18),
              ),
              const SizedBox(width: 10),
              const Text("How to Use", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black)),
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
                _usageItem(Icons.water_drop_outlined, "Dosage", "Mix 2-3 ml per liter of water."),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFEBEBEB))),
                _usageItem(Icons.schedule_rounded, "Apply Time", "Best applied during early morning or evening."),
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: Color(0xFFEBEBEB))),
                _usageItem(Icons.auto_awesome_outlined, "Method", "Foliar spray for maximum effectiveness."),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)]),
          child: Icon(icon, color: Constants.baseColor, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.3)),
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
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.black),
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
                    index < _userRating ? Icons.star_rounded : Icons.star_outline_rounded,
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
                borderSide: BorderSide(color: Constants.baseColor.withOpacity(0.5)),
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
                
                // Show success feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Review submitted successfully!"),
                    backgroundColor: Constants.baseColor,
                  ),
                );
                
                // Clear fields
                setState(() {
                  _userRating = 0;
                  _reviewController.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.baseColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                "SUBMIT REVIEW",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
