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
              subtotalPriceSet {
                presentmentMoney {
                   amount
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
                  variantTitle
                  originalUnitPriceSet {
                    presentmentMoney {
                       amount
                    }
                  }
                  image {
                    url
                  }
                  variant {
                    id
                    product {
                      id
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
                'id': node['id'].toString(),
                'order_number': node['name'].toString().replaceAll('#', ''),
                'created_at': node['createdAt'],
                'total_price': totalPrice,
                'subtotal_price': node['subtotalPriceSet']?['presentmentMoney']
                        ?['amount']
                    ?.toString(),
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
                    'price': li['originalUnitPriceSet']?['presentmentMoney']
                                ?['amount']
                            ?.toString() ??
                        '0.00',
                    'variant_title': li['variantTitle'] ?? '',
                    'variant_id':
                        li['variant']?['id']?.toString().split('/').last,
                    'product_id': li['variant']?['product']?['id']
                        ?.toString()
                        .split('/')
                        .last,
                    'image': img,
                  };
                }).toList(),
              });

              // Fallback calculation for subtotal in list view too
              var lastOrder = orders.last;
              if (lastOrder['subtotal_price'] == null ||
                  lastOrder['subtotal_price'] == '0.00' ||
                  lastOrder['subtotal_price'] == '0') {
                double sub = 0;
                for (var item in lastOrder['line_items']) {
                  sub +=
                      (double.tryParse(item['price']?.toString() ?? '0') ?? 0) *
                          (item['quantity'] ?? 0);
                }
                lastOrder['subtotal_price'] = sub.toStringAsFixed(2);
              }
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

  static Future<Map<String, dynamic>> _getAdminData({
    required String body,
    Map<String, dynamic>? variables,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$_baseUrl/graphql.json"),
        headers: _header,
        body: jsonEncode({
          'query': body,
          'variables': variables ?? {},
        }),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("ShopifyAdmin GraphQL Error: $e");
    }
    return {};
  }

  static Future<Map<String, dynamic>> getOrderFullDetails(
      String orderId) async {
    try {
      final String gid =
          orderId.contains('gid://') ? orderId : "gid://shopify/Order/$orderId";

      final String query = r'''
        query getOrder($id: ID!) {
          order(id: $id) {
            id
            name
            createdAt
            totalPriceSet { presentmentMoney { amount } }
            subtotalPriceSet { presentmentMoney { amount } }
            totalTaxSet { presentmentMoney { amount } }
            totalShippingPriceSet { presentmentMoney { amount } }
            displayFulfillmentStatus
            displayFinancialStatus
            confirmed
            cancelledAt
            statusPageUrl
            
            fulfillments(first: 10) {
              id
              shipmentStatus
              trackingInfo(first: 10) {
                number
                url
                company
              }
            }
            
            shippingAddress {
              name
              phone
              company
              firstName
              lastName
              address1
              address2
              city
              province
              zip
              country
            }
            billingAddress {
              name
              phone
              company
              firstName
              lastName
              address1
              address2
              city
              province
              zip
              country
            }
            customer {
              firstName
              lastName
              phone
              email
              defaultAddress {
                firstName
                lastName
                company
                address1
                address2
                city
                province
                zip
                country
                phone
              }
            }
            lineItems(first: 50) {
              nodes {
                title
                quantity
                variantTitle
                image { url }
                originalUnitPriceSet { presentmentMoney { amount } }
              }
            }
          }
        }
      ''';

      final res = await _getAdminData(body: query, variables: {"id": gid});

      Map<String, dynamic> finalData = {};

      if (res['data']?['order'] != null) {
        var o = res['data']['order'];
        var sa = o['shippingAddress'] ?? {};
        var ba = o['billingAddress'] ?? {};
        var c = o['customer'] ?? {};
        var da = c['defaultAddress'] ?? {};

        // 1. Resolve Identity
        String firstName = (sa['firstName'] ??
                ba['firstName'] ??
                da['firstName'] ??
                c['firstName'] ??
                "")
            .toString()
            .trim();
        String lastName = (sa['lastName'] ??
                ba['lastName'] ??
                da['lastName'] ??
                c['lastName'] ??
                "")
            .toString()
            .trim();
        String fullName = (sa['name'] ??
                ba['name'] ??
                (firstName.isNotEmpty ? "$firstName $lastName" : ""))
            .toString()
            .trim();
        String phone =
            (sa['phone'] ?? ba['phone'] ?? da['phone'] ?? c['phone'] ?? "")
                .toString()
                .trim();
        String zip =
            (sa['zip'] ?? ba['zip'] ?? da['zip'] ?? "").toString().trim();
        String company = (sa['company'] ?? ba['company'] ?? da['company'] ?? "")
            .toString()
            .trim();

        // 2. REST FALLBACK: If identity is blocked (redacted/null), try the REST door
        if (fullName.isEmpty || phone.isEmpty || zip.isEmpty) {
          try {
            final numericId = gid.split('/').last;
            final restRes = await _getData(link: "orders/$numericId");
            if (restRes['order'] != null) {
              var ro = restRes['order'];
              var rsa = ro['shipping_address'] ?? ro['billing_address'] ?? {};
              var rc = ro['customer'] ?? {};

              if (fullName.isEmpty || fullName == "Customer") {
                fullName = rsa['name'] ??
                    '${rc['first_name'] ?? ''} ${rc['last_name'] ?? ''}'.trim();
              }
              if (phone.isEmpty) phone = rsa['phone'] ?? rc['phone'] ?? "";
              if (zip.isEmpty) zip = rsa['zip'] ?? "";
              if (company.isEmpty) company = rsa['company'] ?? "";

              // Updates address parts if needed
              if (sa['address1'] == null) sa['address1'] = rsa['address1'];
              if (sa['address2'] == null) sa['address2'] = rsa['address2'];
              if (sa['city'] == null) sa['city'] = rsa['city'];
              if (sa['province'] == null) sa['province'] = rsa['province'];
              if (sa['country'] == null) sa['country'] = rsa['country'];
              if (o['statusPageUrl'] == null)
                o['statusPageUrl'] = ro['order_status_url'];

              // Map REST fulfillments to GraphQL-like nodes for unified parsing
              if (o['fulfillments'] == null && ro['fulfillments'] != null) {
                o['fulfillments'] = {
                  'nodes': (ro['fulfillments'] as List)
                      .map((rf) => {
                            'id': rf['id'],
                            'shipmentStatus': rf['shipment_status'],
                            'trackingInfo': [
                              {
                                'number': rf['tracking_number'],
                                'url': rf['tracking_url'],
                                'company': rf['tracking_company'],
                              }
                            ]
                          })
                      .toList()
                };
              }
            }
          } catch (e) {
            debugPrint("REST Fallback Error: $e");
          }
        }

        if (fullName.isEmpty) fullName = "Customer";

        // 3. Resolve Location
        String a1 = (sa['address1'] ?? ba['address1'] ?? da['address1'] ?? "")
            .toString()
            .trim();
        String a2 = (sa['address2'] ?? ba['address2'] ?? da['address2'] ?? "")
            .toString()
            .trim();
        String city =
            (sa['city'] ?? ba['city'] ?? da['city'] ?? "").toString().trim();
        String prov = (sa['province'] ?? ba['province'] ?? da['province'] ?? "")
            .toString()
            .trim();
        String country = (sa['country'] ?? ba['country'] ?? da['country'] ?? "")
            .toString()
            .trim();

        // Build COMPLETE composite address string
        String addr = [
          fullName,
          phone.isNotEmpty ? phone : null,
          company.isNotEmpty ? company : null,
          a1.isNotEmpty ? a1 : null,
          a2.isNotEmpty ? a2 : null,
          city.isNotEmpty ? city : null,
          prov.isNotEmpty ? prov : null,
          zip.isNotEmpty ? zip : null,
          country.isNotEmpty ? country : null,
        ].where((e) => e != null && e.toString().trim().isNotEmpty).join(", ");

        if (addr.length < 15 && zip.isEmpty) {
          addr = "No shipping address provided";
        }

        final lineItemsMapped = (o['lineItems']?['nodes'] as List? ?? [])
            .map((li) => {
                  'title': li['title'],
                  'quantity': li['quantity'],
                  'price': li['originalUnitPriceSet']?['presentmentMoney']
                          ?['amount']
                      ?.toString(),
                  'variant_title': li['variantTitle'],
                  'image': li['image']?['url'] ?? '',
                })
            .toList();

        finalData = {
          'id': o['id'],
          'order_number': o['name']?.toString().replaceAll('#', '') ?? 'N/A',
          'created_at': o['createdAt'],
          'total_price':
              o['totalPriceSet']?['presentmentMoney']?['amount']?.toString(),
          'subtotal_price':
              o['subtotalPriceSet']?['presentmentMoney']?['amount']?.toString(),
          'total_tax':
              o['totalTaxSet']?['presentmentMoney']?['amount']?.toString(),
          'total_shipping': o['totalShippingPriceSet']?['presentmentMoney']
                  ?['amount']
              ?.toString(),
          'shipping_address': addr,
          'order_status_url': o['statusPageUrl']?.toString(),
          'customer_first_name': firstName,
          'customer_last_name': lastName,
          'customer_phone': phone,
          'fulfillment_status': o['displayFulfillmentStatus']?.toLowerCase(),
          'financial_status': o['displayFinancialStatus']?.toLowerCase(),
          'cancelled_at': o['cancelledAt'],
          'confirmed': o['confirmed'] ?? true,
          'fulfillments': (o['fulfillments']?['nodes'] as List? ?? []).map((f) {
            var ti = (f['trackingInfo'] as List? ?? []).firstOrNull ?? {};
            return {
              'id': f['id'],
              'shipment_status': f['shipmentStatus'],
              'tracking_number': ti['number'],
              'tracking_url': ti['url'],
              'tracking_company': ti['company'],
            };
          }).toList(),
          'line_items': lineItemsMapped,
        };

        // Fallback: If subtotal_price is missing or 0, calculate from line items
        if (finalData['subtotal_price'] == null ||
            finalData['subtotal_price'] == '0' ||
            finalData['subtotal_price'] == '0.0' ||
            finalData['subtotal_price'] == '0.00') {
          double calculatedSubtotal = 0;
          for (var item in lineItemsMapped) {
            double price =
                double.tryParse(item['price']?.toString() ?? '0') ?? 0;
            int qty = int.tryParse(item['quantity']?.toString() ?? '0') ?? 0;
            calculatedSubtotal += (price * qty);
          }
          finalData['subtotal_price'] = calculatedSubtotal.toStringAsFixed(2);
        }
      }
      return finalData;
    } catch (e) {
      debugPrint("getOrderFullDetails Overall Error: $e");
    }
    return {};
  }

  static Future<Map<String, dynamic>> createOrder({
    String? customerId,
    required List<Map<String, dynamic>> lineItems,
    required Map<String, dynamic> shippingAddress,
    required double totalAmount,
    String? paymentId,
    bool isCod = false,
  }) async {
    try {
      final List<Map<String, dynamic>> cleanLineItems = lineItems.map((item) {
        String vid = item['variant_id']?.toString() ?? '';
        return {
          "variant_id": int.parse(vid.split('/').last),
          "quantity": item['quantity'],
        };
      }).toList();

      final Map<String, dynamic> orderPayload = {
        "line_items": cleanLineItems,
        "financial_status": isCod ? "pending" : "paid",
        "total_price": totalAmount.toStringAsFixed(2),
        "currency": "INR",
        "email": shippingAddress['email'] ?? "",
        "phone": shippingAddress['phone'] ?? "",
        "note_attributes": [
          {
            "name": "payment_id",
            "value": paymentId ?? (isCod ? "COD" : "Online")
          },
          {"name": "channel", "value": "Mobile App"}
        ],
        "shipping_address": {
          "first_name":
              shippingAddress['name']?.toString().split(' ').first ?? '',
          "last_name": shippingAddress['name']
                  ?.toString()
                  .split(' ')
                  .skip(1)
                  .join(' ') ??
              '',
          "address1": shippingAddress['address1'] ?? "",
          "address2": shippingAddress['address2'] ?? "",
          "city": shippingAddress['city'] ?? "",
          "province": shippingAddress['state'] ?? "",
          "zip": shippingAddress['pincode'] ?? "",
          "phone": shippingAddress['phone'] ?? "",
          "country": "India"
        },
        "inventory_behavior": "decrement_ignoring_policy",
        "send_receipt": true,
      };

      if (customerId != null && customerId.isNotEmpty && customerId != "null") {
        try {
          final int cleanId = int.parse(customerId.split('/').last);
          orderPayload["customer"] = {"id": cleanId};
        } catch (_) {}
      }

      final res = await http.post(
        Uri.parse("$_baseUrl/orders.json"),
        headers: _header,
        body: jsonEncode({"order": orderPayload}),
      );

      debugPrint("Shopify Create Order Status: ${res.statusCode}");

      if (res.statusCode == 201) {
        return jsonDecode(res.body);
      } else {
        debugPrint("Create Order Error ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      debugPrint("createOrder Overall Error: $e");
    }
    return {};
  }

  static Future<bool> cancelOrder(String orderId) async {
    try {
      final numericId =
          orderId.contains('gid://') ? orderId.split('/').last : orderId;
      var res = await http.post(
        Uri.parse("$_baseUrl/orders/$numericId/cancel.json"),
        headers: _header,
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      }
      debugPrint("Cancel Order Error ${res.statusCode}: ${res.body}");
    } catch (e) {
      debugPrint("cancelOrder Error: $e");
    }
    return false;
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

  static Future<Map<String, dynamic>> getGraphQLData(BuildContext? context,
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

      debugPrint("Shopify Request [Lang: ${variables['lang']}]: $body");

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
        if (decoded['data'] != null) {
          debugPrint("Shopify Response Data: ${jsonEncode(decoded['data'])}");
        } else {
          debugPrint(
              "Shopify Response: No data returned for lang ${variables['lang']}");
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

  static Future<ProductModel?> getProductDetails(BuildContext context,
      {required String productId}) async {
    debugPrint("Fetching localized product details for: $productId");
    try {
      final fullId =
          productId.contains(_proIdPre) ? productId : "$_proIdPre$productId";
      var res = await getGraphQLData(
        context,
        body: '''
          node(id: "$fullId") {
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
              variants(first: 20) {
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
        ''',
      );

      if (res['data'] != null && res['data']['node'] != null) {
        var p = res['data']['node'];

        List<Map<String, dynamic>> variants = [];
        if (p['variants'] != null && p['variants']['nodes'] != null) {
          for (var v in p['variants']['nodes']) {
            variants.add({
              "id": v['id'].toString().replaceAll(_proVarIdPre, ''),
              "title": v['title'] ?? '',
              "price": v['price']?['amount']?.toString() ?? '0',
              "compare_at_price": v['compareAtPrice']?['amount']?.toString(),
              "inventory_quantity": v['quantityAvailable'] ?? 0,
            });
          }
        }

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
      debugPrint("Error fetching product details: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>> getProductsFromCollections(
    BuildContext context, {
    required String id,
    int? limit,
    String? cursor,
  }) async {
    try {
      var res = await getGraphQLData(
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
      var res = await getGraphQLData(
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
      var res = await getGraphQLData(
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
      var res = await getGraphQLData(
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

  static Future<Map<String, String>> getCollectionDetails(
    BuildContext context, {
    required String id,
    String? forcedLang,
  }) async {
    try {
      var res = await getGraphQLData(
        context,
        forcedLang: forcedLang,
        body: '''
          collection(id: "$_colIdPre$id") {
            id
            title
            handle
            description
            image { url }
          }
        ''',
      );

      if (res.isNotEmpty &&
          res['data'] != null &&
          res['data']['collection'] != null) {
        var node = res['data']['collection'];
        return {
          "title": node['title'] ?? '',
          "handle": node['handle'] ?? '',
          "description": node['description'] ?? '',
          "image": node['image']?['url'] ?? '',
        };
      }
    } catch (e) {
      debugPrint("Error in getCollectionDetails: $e");
    }
    return {};
  }

  static Future<List<CategoriesModel>> getCategories(
    BuildContext context, {
    String? forcedLang,
  }) async {
    try {
      var res = await getGraphQLData(
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
      var res = await getGraphQLData(
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

      var res = await getGraphQLData(
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
      var res = await getGraphQLData(
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
        var res = await getGraphQLData(
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
