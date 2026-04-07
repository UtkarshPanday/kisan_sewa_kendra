import 'dart:convert';
import 'pref.dart';

class CartItem {
  final String id;
  final String? productId;
  final int qty;
  final String title;
  final String price;
  final String image;
  final String variantTitle;

  CartItem({
    required this.id,
    this.productId,
    required this.qty,
    required this.title,
    required this.price,
    required this.image,
    required this.variantTitle,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'qty': qty,
        'title': title,
        'price': price,
        'image': image,
        'variantTitle': variantTitle,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'].toString(),
        productId: json['productId']?.toString(),
        qty: int.tryParse(json['qty'].toString()) ?? 1,
        title: json['title'] ?? '',
        price: json['price'] ?? '0',
        image: json['image'] ?? '',
        variantTitle: json['variantTitle'] ?? '',
      );
}

class CartController {
  static Future<void> addToCart({
    required String variantId,
    String? productId,
    required int qty,
    required String title,
    required String price,
    required String? image,
    required String variantTitle,
  }) async {
    String? cartJson = await Pref.getPref(PrefKey.cart);
    List<dynamic> cartList = cartJson == null ? [] : jsonDecode(cartJson);

    int index = cartList.indexWhere((item) => item['id'].toString() == variantId.toString());

    final newItem = CartItem(
      id: variantId,
      productId: productId,
      qty: qty,
      title: title,
      price: price,
      image: image ?? '',
      variantTitle: variantTitle,
    ).toJson();

    if (index >= 0) {
      cartList[index] = newItem;
    } else {
      cartList.add(newItem);
    }

    await Pref.setPref(key: PrefKey.cart, value: jsonEncode(cartList));
  }

  static Future<List<CartItem>> getCart() async {
    String? cartJson = await Pref.getPref(PrefKey.cart);
    if (cartJson == null || cartJson == '[]') return [];
    try {
      List<dynamic> list = jsonDecode(cartJson);
      return list.map((e) => CartItem.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> updateQty(String variantId, int newQty) async {
    String? cartJson = await Pref.getPref(PrefKey.cart);
    if (cartJson == null) return;
    List<dynamic> cartList = jsonDecode(cartJson);
    int index = cartList.indexWhere((item) => item['id'].toString() == variantId.toString());
    if (index >= 0) {
      if (newQty > 0) {
        cartList[index]['qty'] = newQty;
      } else {
        cartList.removeAt(index);
      }
      await Pref.setPref(key: PrefKey.cart, value: jsonEncode(cartList));
    }
  }

  static Future<void> removeFromCart(String variantId) async {
    String? cartJson = await Pref.getPref(PrefKey.cart);
    if (cartJson == null) return;
    List<dynamic> cartList = jsonDecode(cartJson);
    cartList.removeWhere((item) => item['id'].toString() == variantId.toString());
    await Pref.setPref(key: PrefKey.cart, value: jsonEncode(cartList));
  }

  // ─── Clear entire cart (called after successful payment) ─────────────────
  static Future<void> clearCart() async {
    await Pref.removePrefKey(PrefKey.cart);
  }
}
