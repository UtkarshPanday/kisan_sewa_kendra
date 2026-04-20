import 'dart:convert';

class OrderModel {
  final String id;
  final String orderNumber;
  final String createdAt;
  final String totalPrice;
  final String currency;
  final String fulfillmentStatus;
  final String financialStatus;
  final List<LineItem> lineItems;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.totalPrice,
    required this.currency,
    required this.fulfillmentStatus,
    required this.financialStatus,
    required this.lineItems,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number'].toString(),
      createdAt: json['created_at'] ?? '',
      totalPrice: json['total_price'] ?? '0.00',
      currency: json['currency'] ?? 'INR',
      fulfillmentStatus: json['fulfillment_status'] ?? 'pending',
      financialStatus: json['financial_status'] ?? 'pending',
      lineItems: (json['line_items'] as List? ?? [])
          .map((item) => LineItem.fromJson(item))
          .toList(),
    );
  }
}

class LineItem {
  final String title;
  final int quantity;
  final String price;
  final String? variantTitle;

  LineItem({
    required this.title,
    required this.quantity,
    required this.price,
    this.variantTitle,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      title: json['title'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price'] ?? '0.00',
      variantTitle: json['variant_title'],
    );
  }
}

void main() {
  String jsonStr = '''
  {
    "orders": [
        {
            "id": 6866220122265,
            "created_at": "2026-04-07T17:49:31+05:30",
            "currency": "INR",
            "financial_status": "pending",
            "fulfillment_status": null,
            "name": "#15560",
            "order_number": 15560,
            "total_price": "3640.00",
            "line_items": [
                {
                    "title": "Grow",
                    "quantity": 6,
                    "price": "520.00",
                    "variant_title": "1 litre"
                }
            ]
        }
    ]
  }
  ''';

  try {
    var d = jsonDecode(jsonStr);
    var list =
        (d['orders'] as List).map((e) => OrderModel.fromJson(e)).toList();
  } catch (e) {}
}
