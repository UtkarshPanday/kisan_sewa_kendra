import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:kisan_sewa_kendra/generated/assets.dart';

import '../controller/constants.dart';
import '../controller/pref.dart';
import '../controller/routers.dart';
import '../model/product_model.dart';
import '../shopify/shopify.dart';
import '../view/cart_view.dart';
import '../view/home_view.dart';
import '../view/product_view.dart';
import 'network_image.dart';
import 'widget_button.dart';

class KskAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String? title, share, subTitle;
  final Widget? filter;

  const KskAppbar({
    super.key,
    this.title,
    this.share,
    this.subTitle,
    this.filter,
  });

  @override
  State<KskAppbar> createState() => _KskAppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(135);
}

class _KskAppbarState extends State<KskAppbar> {
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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      String? cart = await Pref.getPref(PrefKey.cart);
      List<dynamic> cartList;
      if (cart == null) {
        cartList = [];
      } else {
        cartList = jsonDecode(cart);
      }
      if (mounted) {
        setState(() {
          _cartCount = cartList.length;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        centerTitle: false, // DO NOT center logo horizontally
        toolbarHeight: 85,
        leading: Builder(
          builder: (context) => IconButton(
            padding: const EdgeInsets.only(left: 12),
            icon: Icon(Icons.menu_rounded, color: Constants.baseColor, size: 32), // Increased size
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Container(
          height: 85,
          alignment: Alignment.centerLeft, // Keep left, but center vertically
          child: Image.asset(
            Assets.assetsLogo,
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          if (Constants.languageList.isNotEmpty && widget.title == null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Constants.baseColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Constants.baseColor.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.language_rounded, size: 16, color: Constants.baseColor),
                      const SizedBox(width: 4),
                      Text(
                        Constants.lang.toUpperCase(),
                        style: TextStyle(color: Constants.baseColor, fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                onSelected: (String code) async {
                  await Pref.setPref(key: PrefKey.lang, value: code);
                  Constants.lang = code;
                  if (!context.mounted) return;
                  await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (route) => false,
                  );
                },
                itemBuilder: (context) => Constants.languageList.map((lang) {
                  return PopupMenuItem<String>(
                    value: lang.iso,
                    child: Text(lang.name),
                  );
                }).toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: badges.Badge(
              badgeContent: Text('$_cartCount', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              position: badges.BadgePosition.topEnd(top: -4, end: -4),
              showBadge: _cartCount > 0,
              badgeStyle: badges.BadgeStyle(badgeColor: Constants.baseColor, padding: const EdgeInsets.all(4)),
              child: InkWell(
                onTap: () => Routers.goTO(context, toBody: const CartView()),
                child: Icon(Icons.shopping_bag_outlined, color: Constants.baseColor, size: 28),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: WidgetButton(
              onTap: () => showSearch(context: context, delegate: CustomSearchDelegate()),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.grey[500], size: 20),
                    const SizedBox(width: 12),
                    Text(
                      "Search for products...",
                      style: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded, size: 24),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchContent(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: Shopify.fetchSearchResults(context, query: query.isEmpty ? "organic" : query), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Search for your favorite products"));
        }
        return _buildProductList(context, snapshot.data!, query.isEmpty ? "Top Suggestions" : "Results for '$query'");
      },
    );
  }

  Widget _buildSearchContent(BuildContext context) {
    return FutureBuilder<List<ProductModel>>(
      future: Shopify.fetchSearchResults(context, query: query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No results found for '$query'"));
        }
        return _buildProductList(context, snapshot.data!);
      },
    );
  }

  Widget _buildProductList(BuildContext context, List<ProductModel> products, [String? title]) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length + (title != null ? 1 : 0),
      separatorBuilder: (context, index) => const Divider(height: 24, color: Color(0xFFF0F0F0)),
      itemBuilder: (context, index) {
        if (title != null && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          );
        }
        final product = products[title != null ? index - 1 : index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF5F5F5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: KskNetworkImage(product.image ?? '', fit: BoxFit.contain),
            ),
          ),
          title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text("${Constants.inr}${product.variants.isNotEmpty ? product.variants.first.price : '0'}", style: TextStyle(color: Constants.baseColor, fontWeight: FontWeight.w900, fontSize: 15)),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          onTap: () => Routers.goTO(context, toBody: ProductView(product: product)),
        );
      },
    );
  }
}
