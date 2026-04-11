import 'package:flutter/material.dart';

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
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Constants.baseColor,
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text("No categories found."),
      );
    }

    return RefreshIndicator(
      color: Constants.baseColor,
      onRefresh: () => _init(isRefresh: true),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return WidgetButton(
            onTap: () {
              Routers.goTO(
                context,
                toBody: CollectionView(
                  collectionId: category.id.toString(),
                ),
              );
            },
            child: Card(
              elevation: 0.5,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                clipBehavior: Clip.none,
                child: KskNetworkImage(
                  category.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
