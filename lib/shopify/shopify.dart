import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../controller/constants.dart';
import '../controller/pref.dart';
import '../model/categories_model.dart';
import '../model/localization_model.dart';
import '../model/product_model.dart';

class ShopifyAPI {
  static const String _baseUrl =
      "https://3b7f20-3.myshopify.com/admin/api/2024-10";
  static Map<String, String> _header = {
    'content-type': 'application/json',
    'X-Shopify-Access-Token': Constants.shopifyAccessToken,
  };

  static Future<Map<String, dynamic>> _getData({
    required String link,
  }) async {
    try {
      String path =
          link.contains('?') ? link.replaceFirst('?', '.json?') : '$link.json';

      var res = await http.get(
        Uri.parse("$_baseUrl/$path"),
        headers: _header,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("ShopifyAPI Error: $e");
    }
    return {};
  }

  static Future<Map<String, String>> getCollection({required String id}) async {
    var res = await _getData(
      link: "collections/$id",
    );
    if (res.isNotEmpty && res['collection'] != null) {
      return {
        "title": res['collection']['title']?.toString() ?? '',
        "handle": res['collection']['handle']?.toString() ?? '',
        "pro": res['collection']['products_count']?.toString() ?? '0',
        "image": res['collection']['image']?['src']?.toString() ?? '',
      };
    }
    return {};
  }

  static Future<List<dynamic>> getCustomerOrders(String customerId) async {
    try {
      final String query = '''
        query {
          orders(first: 50, reverse: true, query: "customer_id:$customerId") {
            nodes {
              id
              name
              createdAt
              totalPriceSet {
                presentmentMoney {
                   amount
                   currencyCode
                }
              }
              displayFulfillmentStatus
              displayFinancialStatus
              cancelledAt
              closedAt
              confirmed
              lineItems(first: 50) {
                nodes {
                  title
                  quantity
                  image {
                    url
                  }
                  variant {
                    product {
                      featuredImage {
                        url
                      }
                    }
                  }
                }
              }
            }
          }
        }
      ''';

      var res = await http.post(
        Uri.parse(
            "https://3b7f20-3.myshopify.com/admin/api/2024-10/graphql.json"),
        body: json.encode({'query': query}),
        headers: {
          'content-type': 'application/json',
          'X-Shopify-Access-Token': Constants.shopifyAccessToken,
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null && decoded['data']['orders'] != null) {
          final List orders = [];
          for (var node in decoded['data']['orders']['nodes']) {
            try {
              String totalPrice = '0.00';
              String currency = 'INR';
              if (node['totalPriceSet'] != null &&
                  node['totalPriceSet']['presentmentMoney'] != null) {
                totalPrice = node['totalPriceSet']['presentmentMoney']['amount']
                        ?.toString() ??
                    '0.00';
                currency = node['totalPriceSet']['presentmentMoney']
                            ['currencyCode']
                        ?.toString() ??
                    'INR';
              }

              orders.add({
                'id': node['id'].toString().split('/').last,
                'order_number': node['name'].toString().replaceAll('#', ''),
                'created_at': node['createdAt'],
                'total_price': totalPrice,
                'currency': currency,
                'fulfillment_status':
                    node['displayFulfillmentStatus']?.toLowerCase() ??
                        'pending',
                'financial_status':
                    node['displayFinancialStatus']?.toLowerCase() ?? 'pending',
                'cancelled_at': node['cancelledAt'],
                'closed_at': node['closedAt'],
                'confirmed': node['confirmed'] ?? false,
                'line_items':
                    (node['lineItems']?['nodes'] as List? ?? []).map((li) {
                  String? img = li['image']?['url'] ??
                      li['variant']?['product']?['featuredImage']?['url'];
                  return {
                    'title': li['title'] ?? '',
                    'quantity': li['quantity'] ?? 0,
                    'image': img,
                  };
                }).toList(),
              });
            } catch (e) {
              debugPrint("Mapper Error for order node: $e");
            }
          }
          return orders;
        }
      }
    } catch (e) {
      debugPrint("getCustomerOrders Error: $e");
    }
    return [];
  }

  static Future<List<dynamic>> getOrderDetails(String orderId) async {
    try {
      final String query = '''
        query {
          order(id: "gid://shopify/Order/$orderId") {
            lineItems(first: 50) {
              nodes {
                title
                variantTitle
                originalUnitPrice
                image {
                  url
                }
                variant {
                  image {
                    url
                  }
                  product {
                    featuredImage {
                      url
                    }
                  }
                }
              }
            }
          }
        }
      ''';

      var res = await http.post(
        Uri.parse(
            "https://3b7f20-3.myshopify.com/admin/api/2024-10/graphql.json"),
        body: json.encode({'query': query}),
        headers: {
          'content-type': 'application/json',
          'X-Shopify-Access-Token': Constants.shopifyAccessToken,
        },
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['data'] != null && decoded['data']['order'] != null) {
          final nodes = decoded['data']['order']['lineItems']['nodes'] as List;
          return nodes.map((li) {
            String? imageUrl = li['image']?['url'] ??
                li['variant']?['image']?['url'] ??
                li['variant']?['product']?['featuredImage']?['url'];
            return {
              'title': li['title'],
              'quantity': 1,
              'price': li['originalUnitPrice'],
              'variant_title': li['variantTitle'],
              'image': imageUrl,
            };
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("getOrderDetails Error: $e");
    }
    return [];
  }
}

class Shopify {
  static const String _defaultVersion = "2024-10";
  static const String _baseUrl =
      "https://3b7f20-3.myshopify.com/api/$_defaultVersion/graphql.json";

  static const String _colIdPre = "gid://shopify/Collection/";
  static const String _proIdPre = "gid://shopify/Product/";
  static const String _proVarIdPre = "gid://shopify/ProductVariant/";

  static Map<String, String> _header = {
    'content-type': 'application/json',
    'X-Shopify-Storefront-Access-Token': Constants.storefrontAccessToken,
  };

  static Future<Map<String, dynamic>> _getData(BuildContext? context,
      {required String body,
      String? version,
      String? forcedLang,
      Map<String, dynamic>? variable}) async {
    try {
      String query;
      Map<String, dynamic> variables = {};

      if (version != null) {
        query = body;
        if (variable != null) {
          variables.addAll(variable);
        }
      } else {
        query = '''
          query(\$lang: LanguageCode!) @inContext(language: \$lang) {
            $body
          }
        ''';
        variables = {'lang': (forcedLang ?? Constants.lang).toUpperCase()};
        if (variable != null) {
          variables.addAll(variable);
        }
      }

      Map<String, dynamic> data = {
        'query': query,
        'variables': variables,
      };

      var res = await http.post(
        Uri.parse(
          version == null
              ? _baseUrl
              : _baseUrl.replaceAll(
                  _defaultVersion,
                  version,
                ),
        ),
        body: json.encode(data),
        headers: _header,
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['errors'] != null) {
          debugPrint("Shopify GraphQL Errors: ${decoded['errors']}");
        }
        return decoded;
      } else {
        debugPrint("Shopify Error ${res.statusCode}: ${res.reasonPhrase}");
        return {};
      }
    } catch (e) {
      debugPrint("Shopify Network/Parsing Error: $e");
      return {};
    }
  }

  static Future<Map<String, dynamic>> getProductsFromCollections(
    BuildContext context, {
    required String id,
    int? limit,
    String? cursor,
  }) async {
    try {
      var res = await _getData(
        context,
        body: '''
          collection(id: "$_colIdPre$id") {
          products(first: ${limit ?? 100}, after: ${cursor != null ? "\"$cursor\"" : "null"}) {
              nodes {
                  id
                  title
                  descriptionHtml
                  vendor
                  productType
                  handle
                  featuredImage {
                      url
                  }
                  images(first: 10) {
                      nodes {
                          url
                      }
                  }
                  variants(first: 100) {
                      nodes {
                          id
                          title
                          price {
                              amount
                          }
                          compareAtPrice {
                              amount
                          }                   
                          quantityAvailable
                      }
                  }
              }
              pageInfo {
                  hasNextPage
                  endCursor
                  hasPreviousPage
                  startCursor
              }
          }
        }
        ''',
      );

      if (res.isNotEmpty &&
          res['data'] != null &&
          res['data']['collection'] != null &&
          res['data']['collection']['products'] != null) {
        List<ProductModel> list = [];
        for (var lis in res['data']['collection']['products']['nodes']) {
          List<Map<String, dynamic>> variants = [];

          if (lis['variants'] != null && lis['variants']['nodes'] != null) {
            for (var variant in lis['variants']['nodes']) {
              Map<String, dynamic> vari = {
                "id": variant['id'].toString().replaceAll(_proVarIdPre, ''),
                "title": variant['title'] ?? '',
                "price": variant['price']?['amount']?.toString() ?? '0',
                "compare_at_price":
                    variant['compareAtPrice']?['amount']?.toString(),
                "inventory_quantity": variant['quantityAvailable'] ?? 0,
              };
              variants.add(vari);
            }
          }

          Map<String, dynamic> li = {
            "id": lis['id'].toString().replaceAll(_proIdPre, ''),
            "title": lis["title"] ?? '',
            "body_html": lis["descriptionHtml"] ?? '',
            "vendor": lis["vendor"] ?? '',
            "product_type": lis["productType"] ?? '',
            "handle": lis["handle"] ?? '',
            "images": lis["images"] != null && lis["images"]['nodes'] != null
                ? (lis["images"]['nodes'] as List)
                    .map((e) => {"url": e['url']})
                    .toList()
                : [],
            "variants": variants,
            "image": lis["featuredImage"],
          };
          list.add(ProductModel.fromJson(li));
        }

        var pageInfo = res['data']['collection']['products']['pageInfo'];
        return {
          "product": list,
          "end": (pageInfo != null && pageInfo['hasNextPage'] == true)
              ? pageInfo["endCursor"]
              : null,
        };
      }
    } catch (e) {
      debugPrint("Error in getProductsFromCollections: $e");
    }
    return {"product": <ProductModel>[], "end": null};
  }

  static Future<ProductModel?> getProductVariantDetails(BuildContext context,
      {required String variantId}) async {
    try {
      final fullId = variantId.contains(_proVarIdPre)
          ? variantId
          : "$_proVarIdPre$variantId";
      var res = await _getData(
        context,
        body: '''
          node(id: "$fullId") {
            ... on ProductVariant {
              id
              title
              price {
                amount
              }
              compareAtPrice {
                amount
              }
              quantityAvailable
              product {
                id
                title
                descriptionHtml
                vendor
                productType
                handle
                featuredImage {
                  url
                }
                images(first: 10) {
                  nodes {
                    url
                  }
                }
              }
            }
          }
        ''',
      );

      if (res['data'] != null && res['data']['node'] != null) {
        var v = res['data']['node'];
        var p = v['product'];

        List<Map<String, dynamic>> variants = [
          {
            "id": v['id'].toString().replaceAll(_proVarIdPre, ''),
            "title": v['title'] ?? '',
            "price": v['price']?['amount']?.toString() ?? '0',
            "compare_at_price": v['compareAtPrice']?['amount']?.toString(),
            "inventory_quantity": v['quantityAvailable'] ?? 0,
          }
        ];

        Map<String, dynamic> li = {
          "id": p['id'].toString().replaceAll(_proIdPre, ''),
          "title": p["title"] ?? '',
          "body_html": p["descriptionHtml"] ?? '',
          "vendor": p["vendor"] ?? '',
          "product_type": p["productType"] ?? '',
          "handle": p["handle"] ?? '',
          "images": p["images"] != null && p["images"]['nodes'] != null
              ? (p["images"]['nodes'] as List)
                  .map((e) => {"url": e['url']})
                  .toList()
              : [],
          "variants": variants,
          "image": p["featuredImage"],
        };
        return ProductModel.fromJson(li);
      }
    } catch (e) {
      debugPrint("Error in getProductVariantDetails: $e");
    }
    return null;
  }

  static Future<List<LocalizationModel>> getLocalization(
    BuildContext context,
  ) async {
    try {
      var res = await _getData(
        context,
        body: '''
          localization {
            availableLanguages {
                isoCode
                endonymName
            }
          }
        ''',
      );
      if (res.isNotEmpty &&
          res['data'] != null &&
          res['data']['localization'] != null) {
        List<LocalizationModel> list = [];
        for (var lis in res['data']['localization']['availableLanguages']) {
          list.add(LocalizationModel(
            iso: lis['isoCode'] ?? '',
            name: lis['endonymName'] ?? '',
          ));
        }
        return list;
      }
    } catch (e) {
      debugPrint("Error in getLocalization: $e");
    }
    return [];
  }

  static Future<List<ProductModel>> getProductsRecommend(BuildContext context,
      {required String id}) async {
    try {
      var res = await _getData(
        context,
        body: '''
            productRecommendations(productId: "$_proIdPre$id") {
            id
            title
            descriptionHtml
            vendor
            productType
            handle
            featuredImage {
                url
            }
            images(first: 10) {
                nodes {
                    url
                }
            }
            variants(first: 100) {
                nodes {
                    id
                    title
                    price {
                        amount
                    }
                    compareAtPrice {
                        amount
                    }                   
                    quantityAvailable
                }
            }
        }
          ''',
      );
      if (res.isNotEmpty &&
          res['data'] != null &&
          res['data']['productRecommendations'] != null) {
        List<ProductModel> list = [];
        for (var lis in res['data']['productRecommendations']) {
          List<Map<String, dynamic>> variants = [];

          if (lis['variants'] != null && lis['variants']['nodes'] != null) {
            for (var variant in lis['variants']['nodes']) {
              variants.add({
                "id": variant['id'].toString().replaceAll(_proVarIdPre, ''),
                "title": variant['title'] ?? '',
                "price": variant['price']?['amount']?.toString() ?? '0',
                "compare_at_price":
                    variant['compareAtPrice']?['amount']?.toString(),
                "inventory_quantity": variant['quantityAvailable'] ?? 0,
              });
            }
          }

          Map<String, dynamic> li = {
            "id": lis['id'].toString().replaceAll(_proIdPre, ''),
            "title": lis["title"] ?? '',
            "body_html": lis["descriptionHtml"] ?? '',
            "vendor": lis["vendor"] ?? '',
            "product_type": lis["productType"] ?? '',
            "handle": lis["handle"] ?? '',
            "images": lis["images"] != null && lis["images"]['nodes'] != null
                ? (lis["images"]['nodes'] as List)
                    .map((e) => {"url": e['url']})
                    .toList()
                : [],
            "variants": variants,
            "image": lis["featuredImage"],
          };
          list.add(ProductModel.fromJson(li));
        }
        list.shuffle(Random());
        return list;
      }
    } catch (e) {
      debugPrint("Error in getProductsRecommend: $e");
    }
    return [];
  }

  static Future<List<CategoriesModel>> getCategories(
    BuildContext context, {
    String? forcedLang,
  }) async {
    try {
      var res = await _getData(
        context,
        forcedLang: forcedLang,
        body: '''
            collections(first: 100) {
                edges {
                    node {
                        id
                        title
                        handle
                        description
                        image {  
                            url
                            altText
                        }
                    }
                }
            }
          ''',
      );
      if (res.isNotEmpty &&
          res['data'] != null &&
          res['data']['collections'] != null) {
        List<CategoriesModel> list = [];
        for (var edge in res['data']['collections']['edges']) {
          var node = edge['node'];
          String image = "";
          if (node["image"] != null && node["image"]["url"] != null) {
            image = node["image"]["url"];
          }
          list.add(
            CategoriesModel(
              id: int.tryParse(
                      node['id'].toString().replaceAll(_colIdPre, '')) ??
                  0,
              title: node['title'] ?? '',
              handle: node['handle'] ?? '',
              description: node['description'] ?? '',
              image: image,
            ),
          );
        }
        return list;
      }
    } catch (e) {
      debugPrint("Error in getCategories: $e");
    }
    return [];
  }

  static Future<List<CategoriesModel>> getBannerCollections(
      BuildContext context) async {
    try {
      var res = await _getData(
        context,
        body: '''
            b1: collection(handle: "homepage-banner-1") { id title handle description image { url altText } }
            b2: collection(handle: "homepage-banner-2") { id title handle description image { url altText } }
            b3: collection(handle: "homepage-banner-3") { id title handle description image { url altText } }
            b4: collection(handle: "homepage-banner-4") { id title handle description image { url altText } }
            b5: collection(handle: "homepage-banner-5") { id title handle description image { url altText } }
          ''',
      );
      if (res.isNotEmpty && res['data'] != null) {
        List<CategoriesModel> list = [];
        for (int i = 1; i <= 5; i++) {
          var node = res['data']['b$i'];
          if (node != null) {
            String image = "";
            if (node["image"] != null && node["image"]["url"] != null) {
              image = node["image"]["url"];
            }
            list.add(
              CategoriesModel(
                id: int.tryParse(
                        node['id'].toString().replaceAll(_colIdPre, '')) ??
                    0,
                title: node['title'] ?? '',
                handle: node['handle'] ?? '',
                description: node['description'] ?? '',
                image: image,
              ),
            );
          }
        }
        return list;
      }
    } catch (e) {
      debugPrint("Error in getBannerCollections: $e");
    }
    return [];
  }

  static Future<String> checkout(BuildContext context,
      {required List<dynamic> cartList}) async {
    try {
      List<Map<String, dynamic>> list = [];
      for (var cart in cartList) {
        list.add({
          "merchandiseId": "$_proVarIdPre${cart["id"]}",
          "quantity": cart["qty"],
        });
      }
      String query = '''
        mutation cartCreate(\$input: CartInput!) {
          cartCreate(input: \$input) {
            cart {
              id
              checkoutUrl
            }
            userErrors {
              field
              message
            }
          }
        }
      ''';

      var res = await _getData(
        context,
        body: query,
        version: "2024-01",
        variable: {
          "input": {"lines": list},
        },
      );
      if (res['data'] != null &&
          res['data']['cartCreate'] != null &&
          res['data']['cartCreate']['cart'] != null) {
        await Pref.setPref(
          key: PrefKey.checkoutId,
          value: res['data']['cartCreate']['cart']['id'],
        );
        return res['data']['cartCreate']['cart']['checkoutUrl'] ?? '';
      }
    } catch (e) {
      debugPrint("Error in checkout: $e");
    }
    return '';
  }

  static Future<List<ProductModel>> fetchSearchResults(
    BuildContext context, {
    required String query,
    bool isSugg = false,
  }) async {
    try {
      var res = await _getData(
        context,
        body: '''
            search(first:${isSugg ? 10 : 50},  query: "$query") {
              nodes {
                  ... on Product {
                      id
                      title
                      descriptionHtml
                      vendor
                      productType
                      handle
                      featuredImage {
                          url
                      }
                      images(first: 10) {
                          nodes {
                              url
                          }
                      }
                      variants(first: 100) {
                          nodes {
                              id
                              title
                              price {
                                  amount
                              }
                              compareAtPrice {
                                  amount
                              }                   
                              quantityAvailable
                          }
                      }
                  }
              }
          }
          ''',
      );
      if (res.isNotEmpty &&
          res['data'] != null &&
          res['data']['search'] != null) {
        List<ProductModel> list = [];
        for (var lis in res['data']['search']['nodes']) {
          List<Map<String, dynamic>> variants = [];

          if (lis['variants'] != null && lis['variants']['nodes'] != null) {
            for (var variant in lis['variants']['nodes']) {
              variants.add({
                "id": variant['id'].toString().replaceAll(_proVarIdPre, ''),
                "title": variant['title'] ?? '',
                "price": variant['price']?['amount']?.toString() ?? '0',
                "compare_at_price":
                    variant['compareAtPrice']?['amount']?.toString(),
                "inventory_quantity": variant['quantityAvailable'] ?? 0,
              });
            }
          }

          Map<String, dynamic> li = {
            "id": lis['id'].toString().replaceAll(_proIdPre, ''),
            "title": lis["title"] ?? '',
            "body_html": lis["descriptionHtml"] ?? '',
            "vendor": lis["vendor"] ?? '',
            "product_type": lis["productType"] ?? '',
            "handle": lis["handle"] ?? '',
            "images": lis["images"] != null && lis["images"]['nodes'] != null
                ? (lis["images"]['nodes'] as List)
                    .map((e) => {"url": e['url']})
                    .toList()
                : [],
            "variants": variants,
            "image": lis["featuredImage"],
          };
          list.add(ProductModel.fromJson(li));
        }
        return list;
      }
    } catch (e) {
      debugPrint("Error in fetchSearchResults: $e");
    }
    return [];
  }

  static Future<void> getCheckoutStatus(
    BuildContext context,
  ) async {
    try {
      String? id = await Pref.getPref(PrefKey.checkoutId);
      if (id != null) {
        String query = '''
        query GetCheckoutDetails {
          node(id: "$id") {
            ... on Checkout {
              id
              orderStatusUrl
            }
          }
        }
      ''';
        var res = await _getData(
          context,
          body: query,
          version: "2024-01",
        );

        if (res['data'] != null && res['data']['node'] != null) {
          bool status = res['data']['node']['orderStatusUrl'] != null;
          if (status) {
            await Pref.removePrefKey(PrefKey.cart);
            await Pref.removePrefKey(PrefKey.checkoutId);
          }
        }
      }
    } catch (e) {
      debugPrint("Error in getCheckoutStatus: $e");
    }
  }

  // Auth functions removed
  static Future<Map<String, dynamic>?> getUserInfo(
          BuildContext context) async =>
      null;
  static Future<bool> login(context,
          {required String email, required String password}) async =>
      false;
  static Future<String> signUp(context,
          {required String fName,
          required String lName,
          required String mobile,
          required String email,
          required String password}) async =>
      "";
  static Future<String> updateDetails(context,
          {required String fName,
          required String lName,
          required String mobile,
          required String email}) async =>
      "";

  static Future<void> share({required String url}) async {
    await Share.share(url);
  }
}

class ShopifyAdmin {
  static const String _baseUrl =
      "https://3b7f20-3.myshopify.com/admin/api/2024-10/graphql.json";

  static const String _proIdPre = "gid://shopify/Product/";
  static const String _proVarIdPre = "gid://shopify/ProductVariant/";

  static Map<String, String> _header = {
    'content-type': 'application/json',
    'X-Shopify-Access-Token': Constants.shopifyAccessToken,
  };

  static Future<Map<String, dynamic>> _getData({
    required String body,
  }) async {
    try {
      String query = '''
        query {
          $body
        }
        ''';
      var res = await http.post(
        Uri.parse(_baseUrl),
        body: json.encode({'query': query}),
        headers: _header,
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("ShopifyAdmin Error: $e");
    }
    return {};
  }

  static Future<ProductModel?> getProductsByVariant(
      {required String id}) async {
    try {
      var res = await _getData(
        body: '''
            productVariant(id: "$_proVarIdPre$id") {
                id
                title
                price
                compareAtPrice
                sellableOnlineQuantity
                product {
                  id
                  title
                  descriptionHtml
                  vendor
                  productType
                  handle
                  featuredImage {
                    url
                  }
                  images(first: 10) {
                    nodes {
                      url
                    }
                  }
                }
              }
          ''',
      );
      if (res.isNotEmpty &&
          res['data'] != null &&
          res['data']['productVariant'] != null) {
        var proVer = res['data']['productVariant'];
        var proud = proVer['product'];
        List<String> imgList = [];
        if (proud['images'] != null && proud['images']['nodes'] != null) {
          for (var img in proud['images']['nodes']) {
            imgList.add(img['url']?.toString() ?? '');
          }
        }

        return ProductModel(
          id: proud["id"].toString().replaceAll(_proIdPre, ''),
          title: proud["title"] ?? '',
          body: proud["descriptionHtml"] ?? '',
          vendor: proud["vendor"] ?? '',
          productType: proud["productType"] ?? '',
          handle: proud["handle"] ?? '',
          variants: [
            VariantModel(
              id: proVer['id'].toString().replaceAll(_proVarIdPre, ''),
              title: proVer['title'] ?? '',
              price: proVer['price']?.toString() ?? '0',
              compareAtPrice: proVer['compareAtPrice']?.toString(),
              inventoryQuantity: proVer['sellableOnlineQuantity'] ?? 0,
            ),
          ],
          images: imgList,
          image: proud["featuredImage"]?['url'],
        );
      }
    } catch (e) {
      debugPrint("Error in getProductsByVariant: $e");
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getAvailableDiscounts() async {
    try {
      const String query = '''
        query {
          codeDiscountNodes(first: 10, query: "status:active") {
            edges {
              node {
                codeDiscount {
                  ... on DiscountCodeBasic {
                    title
                    summary
                    status
                    codes(first: 1) {
                      edges {
                        node {
                          code
                        }
                      }
                    }
                    customerGets {
                      value {
                        ... on DiscountAmount {
                          amount {
                            amount
                          }
                        }
                        ... on DiscountPercentage {
                          percentage
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      ''';

      var res = await http.post(
        Uri.parse(_baseUrl),
        body: json.encode({'query': query}),
        headers: _header,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<Map<String, dynamic>> discounts = [];

        if (data['data'] != null && data['data']['codeDiscountNodes'] != null) {
          final nodes = data['data']['codeDiscountNodes']['edges'] as List;

          for (var edge in nodes) {
            final node = edge['node']['codeDiscount'];
            if (node == null || node.isEmpty) continue;

            final codesList = node['codes']['edges'] as List?;
            if (codesList == null || codesList.isEmpty) continue;

            final codeNode = codesList.first['node'];
            if (codeNode == null) continue;

            final valObj = node['customerGets']?['value'];
            double value = 0;
            String type = 'fixed_amount';

            if (valObj != null) {
              if (valObj['amount'] != null) {
                value =
                    double.tryParse(valObj['amount']['amount'].toString()) ?? 0;
                type = 'fixed_amount';
              } else if (valObj['percentage'] != null) {
                value =
                    (double.tryParse(valObj['percentage'].toString()) ?? 0) *
                        100;
                type = 'percentage';
              }
            }

            discounts.add({
              'code': codeNode['code'],
              'title': node['title'],
              'summary': node['summary'] ?? '',
              'value': value,
              'type': type,
              'description': node['summary'] ?? node['title'],
            });
          }
        }
        return discounts;
      }
    } catch (e) {
      debugPrint("Get Discounts Error: $e");
    }
    return [];
  }

  static Future<Map<String, dynamic>?> validateDiscountCode(
      {required String code}) async {
    try {
      String query = '''
        query {
          codeDiscountNodeByCode(code: "$code") {
            id
            codeDiscount {
              ... on DiscountCodeBasic {
                title
                status
                summary
                customerGets {
                  value {
                    ... on DiscountAmount {
                      amount {
                        amount
                      }
                    }
                    ... on DiscountPercentage {
                      percentage
                    }
                  }
                }
              }
            }
          }
        }
      ''';

      var res = await http.post(
        Uri.parse(_baseUrl),
        body: json.encode({'query': query}),
        headers: _header,
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['data'] != null &&
            data['data']['codeDiscountNodeByCode'] != null) {
          final discount =
              data['data']['codeDiscountNodeByCode']['codeDiscount'];

          if (discount['status'] != 'ACTIVE') return null;

          final valObj = discount['customerGets']['value'];
          double value = 0;
          String type = 'fixed_amount';

          if (valObj['amount'] != null) {
            value = double.tryParse(valObj['amount']['amount'].toString()) ?? 0;
            type = 'fixed_amount';
          } else if (valObj['percentage'] != null) {
            value =
                (double.tryParse(valObj['percentage'].toString()) ?? 0) * 100;
            type = 'percentage';
          }

          return {
            'code': code,
            'title': discount['title'],
            'value': value,
            'type': type,
            'summary': discount['summary']
          };
        }
      }
    } catch (e) {
      debugPrint("Validate Discount Error: $e");
    }
    return null;
  }
}
