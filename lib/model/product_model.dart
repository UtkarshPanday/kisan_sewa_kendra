import 'package:intl/intl.dart';

class ProductModel {
  final String id;
  final String title;
  final String body;
  final String vendor;
  final String productType;
  final String handle;
  final List<VariantModel> variants;
  final List<String> images;
  final String? image;
  final String? collectionId;


  ProductModel({
    required this.id,
    required this.title,
    required this.body,
    required this.vendor,
    required this.productType,
    required this.handle,
    required this.variants,
    required this.images,
    this.image,
    this.collectionId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      body: json['body_html'] ?? '',
      vendor: json['vendor'] ?? '',
      productType: json['product_type'] ?? '',
      handle: json['handle'] ?? '',
      variants: (json['variants'] as List? ?? [])
          .map((v) => VariantModel.fromJson(v))
          .toList(),
      images: (json['images'] as List? ?? [])
          .map((e) => e is Map ? e['url'].toString() : e.toString())
          .toList(),
      image: json['image'] != null ? (json['image'] is Map ? json['image']['url'] : json['image']) : null,
      collectionId: json['collectionId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body_html': body,
      'vendor': vendor,
      'product_type': productType,
      'handle': handle,
      'variants': variants.map((v) => v.toJson()).toList(),
      'images': images,
      'image': image,
      'collectionId': collectionId,
    };
  }
}

class VariantModel {
  final String id;
  final String title;
  final String price;
  final String? compareAtPrice;
  final int inventoryQuantity;

  VariantModel({
    required this.id,
    required this.title,
    required this.price,
    this.compareAtPrice,
    required this.inventoryQuantity,
  });

  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      price: json['price']?.toString() ?? '0',
      compareAtPrice: json['compare_at_price']?.toString() ?? json['compareAtPrice']?.toString(),
      inventoryQuantity: json['inventory_quantity'] ?? json['inventoryQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'compare_at_price': compareAtPrice,
      'inventory_quantity': inventoryQuantity,
    };
  }
}
