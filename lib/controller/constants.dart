import 'package:cached_network_image_plus/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shimmer/shimmer.dart';

import '../model/localization_model.dart';
import '../shopify/shopify.dart';
import 'pref.dart';

class Constants {
  static String cdnUrl =
      "https://cdn.shopify.com/s/files/1/0627/9204/0601/files/";
  static String inr = "₹", title = "Krishi Bhandar";
  static Color baseColor = const Color(0xff26842c);
  static String razorpayKey = dotenv.get('RAZORPAY_KEY', fallback: "");

  static String shopifyAccessToken =
      dotenv.get('SHOPIFY_ADMIN_ACCESS_TOKEN', fallback: "");
  static String storefrontAccessToken =
      dotenv.get('SHOPIFY_STOREFRONT_ACCESS_TOKEN', fallback: "");

  static String lang = 'EN';
  static String payOnlineDiscountCode = "PAYONLINE60";
  static double payOnlineDiscountAmount = 60.0;
  static List<Map<String, String>> circles = [],
      homeScreenCatBanners = [
        {
          "id": "329119367321",
          "image":
              "https://cdn.shopify.com/s/files/1/0627/9204/0601/files/best_seller_hindi_new.png?v=1771321702",
          "color": "#eef9f2",
        },
        {
          "id": "329026371737",
          "image":
              "https://cdn.shopify.com/s/files/1/0627/9204/0601/files/insecticides_hindi_new.png?v=1771321759",
          "color": "#f0f4ff",
        },
        {
          "id": "329026175129",
          "image":
              "https://cdn.shopify.com/s/files/1/0627/9204/0601/files/fungicides_hindi_new.png?v=1771321776",
          "color": "#f9f0ff",
        },
        {
          "id": "329026142361",
          "image":
              "https://cdn.shopify.com/s/files/1/0627/9204/0601/files/fertilizers_hindi_new.png?v=1771321821",
          "color": "#f0fff4",
        },
        {
          "id": "329026240665",
          "image":
              "https://cdn.shopify.com/s/files/1/0627/9204/0601/files/herbicides_hindi_new.png?v=1771321839",
          "color": "#fff0f0",
        },
        {
          "id": "329026470041",
          "image":
              "https://cdn.shopify.com/s/files/1/0627/9204/0601/files/growth_promotors_hindi_new.png?v=1771321881",
          "color": "#f0fcff",
        },
        {
          "id": "333391134873",
          "image":
              "https://cdn.shopify.com/s/files/1/0627/9204/0601/files/buy_1_get_1_free.png?v=1771321912",
          "color": "#fff9f0",
        },
      ],
      cropsList = [];
  static List<LocalizationModel> languageList = [];

  static Widget shimmer({double? height, double? width}) => ShimmerWidget(
        shimmerDirection: ShimmerDirection.ltr,
        shimmerDuration: const Duration(milliseconds: 1500),
        baseColor: const Color.fromRGBO(64, 64, 64, 0.5),
        highlightColor: const Color.fromRGBO(166, 166, 166, 1.0),
        backColor: const Color.fromRGBO(217, 217, 217, 0.5),
        height: height,
        width: width,
      );

  static Widget shimmerText({int lines = 1}) => Column(
        children: [
          for (int i = 0; i < lines; i++) ...[
            shimmer(height: 15),
            if (i - 1 < lines) ...[
              const SizedBox(
                height: 5,
              ),
            ],
          ],
        ],
      );

  static Color stringToColor({required String color}) =>
      Color(int.parse(color.replaceFirst('#', '0XFF')));

  static Future<void> fetchRemoteConfig(
    context,
  ) async {
    try {
      languageList = await Shopify.getLocalization(
        context,
      );

      lang = (await Pref.getPref(PrefKey.lang)) ?? "EN";

      final disc =
          await ShopifyAdmin.validateDiscountCode(code: payOnlineDiscountCode);
      if (disc != null && disc['type'] == 'fixed_amount') {
        payOnlineDiscountAmount = disc['value'].toDouble();
      }
    } catch (e) {
      debugPrint("Failed to fetch remote config: $e");
    }
  }
}
