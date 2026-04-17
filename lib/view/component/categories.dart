import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../components/cart_icon.dart';
import '../../components/network_image.dart';
import '../../components/widget_button.dart';
import '../../controller/constants.dart';
import '../../controller/routers.dart';
import '../../model/categories_model.dart';
import '../../shopify/shopify.dart';
import '../collection_view.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _init);
  }

  List<CategoriesModel> _categories = [];
  bool _isLoading = true;

  Future<void> _init({bool isRefresh = false}) async {
    if (!mounted) return;
    // On first load show full spinner; on refresh keep list & show indicator
    if (!isRefresh) {
      setState(() => _isLoading = true);
    }

    final all = await Shopify.getCategories(context);

    // 1. Filter out meta-categories, promotional banners, and irrelevant sections
    // 2. Ensure only categories with valid images are shown
    final filtered = all.where((cat) {
      final title = cat.title.toLowerCase().trim();
      final hasImage = cat.image.isNotEmpty;

      // Extended Blacklist for non-category/promotional sections
      final isNotHomePage = title != "home page";
      final isNotHydroponics = !title.contains('hydroponics');
      final isNotSale =
          !title.contains('sale') && !title.contains('republic day');
      final isNotBanner =
          !title.contains('banner') && !title.contains('best seller');

      return hasImage &&
          isNotHomePage &&
          isNotHydroponics &&
          isNotSale &&
          isNotBanner;
    }).toList();

    if (mounted) {
      setState(() {
        _categories = filtered;
        _isLoading = false;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget innerContent;
    if (_isLoading) {
      innerContent = _buildShimmerGrid();
    } else if (_categories.isEmpty) {
      innerContent = const Center(
        child: Text("No categories found."),
      );
    } else {
      innerContent = Column(
        children: [
          // Fixed Header (Not affected by refresh pull)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Constants.baseColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Constants.baseColor.withOpacity(0.03),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Shop by Category",
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Constants.baseColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Constants.baseColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${_categories.length} CATEGORIES",
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Premium Selection",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const KskCartIcon(),
                        const SizedBox(width: 12),
                        _buildStatIndicator(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Refreshable Category List
          Expanded(
            child: RefreshIndicator(
              color: Constants.baseColor,
              backgroundColor: Colors.white,
              onRefresh: () => _init(isRefresh: true),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = _categories[index];
                          return TweenAnimationBuilder<double>(
                            duration:
                                Duration(milliseconds: 300 + (index * 50)),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOutCubic,
                            child: RepaintBoundary(
                              child: _buildCategoryCard(category),
                            ),
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(
                                  opacity: value,
                                  child: child,
                                ),
                              );
                            },
                          );
                        },
                        childCount: _categories.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        color: const Color(0xffF9FBF9),
        child: SafeArea(child: innerContent),
      ),
    );
  }

  Widget _buildCategoryCard(CategoriesModel category) {
    return WidgetButton(
      onTap: () {
        Routers.goTO(
          context,
          toBody: CollectionView(
              collectionId: category.id.toString(), title: category.title),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Constants.baseColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Constants.baseColor.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: KskNetworkImage(
            category.image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return SafeArea(
      child: Container(
        color: const Color(0xffF9FBF9),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Constants.shimmer(height: 24, width: 180),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Constants.shimmer(height: 6, width: 6),
                            const SizedBox(width: 6),
                            Constants.shimmer(height: 12, width: 100),
                          ],
                        ),
                      ],
                    ),
                    Constants.shimmer(height: 36, width: 36),
                  ],
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Constants.shimmer(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Constants.baseColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _categories.length.toString(),
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Constants.baseColor,
            ),
          ),
          Text(
            "TOTAL",
            style: GoogleFonts.inter(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              color: Constants.baseColor,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
