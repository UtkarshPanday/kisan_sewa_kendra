import 'package:flutter/material.dart';
import '../controller/constants.dart';
import '../controller/routers.dart';
import '../model/product_model.dart';
import '../shopify/shopify.dart';
import '../view/product_view.dart';
import 'network_image.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';

class CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
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
      future: Shopify.fetchSearchResults(context,
          query: query.isEmpty ? "organic" : query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Search for your favorite products"));
        }
        return _buildProductList(context, snapshot.data!,
            query.isEmpty ? "Top Suggestions" : "Results for '$query'");
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

  Widget _buildProductList(BuildContext context, List<ProductModel> products,
      [String? title]) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: products.length + (title != null ? 1 : 0),
      separatorBuilder: (context, index) =>
          const Divider(height: 24, color: Color(0xFFF0F0F0)),
      itemBuilder: (context, index) {
        if (title != null && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5)),
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
          title: Text(product.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
                "${Constants.inr}${product.variants.isNotEmpty ? product.variants.first.price : '0'}",
                style: TextStyle(
                    color: Constants.baseColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 15)),
          ),
          trailing: const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: Colors.grey),
          onTap: () =>
              Routers.goTO(context, toBody: ProductView(product: product)),
        );
      },
    );
  }
}
