import 'package:flutter/foundation.dart';

class OrderModel {
  final String id;
  final String orderNumber;
  final String createdAt;
  final String totalPrice;
  final String currency;
  final String fulfillmentStatus;
  final String financialStatus;
  final String? cancelledAt;
  final String? closedAt;
  final bool confirmed;
  final List<LineItem> lineItems;
  final List<Fulfillment> fulfillments;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.totalPrice,
    required this.currency,
    required this.fulfillmentStatus,
    required this.financialStatus,
    this.cancelledAt,
    this.closedAt,
    required this.confirmed,
    required this.lineItems,
    required this.fulfillments,
  });

  String get trackingStatus {
    if (cancelledAt != null) return 'Cancelled';
    if (fulfillments.isNotEmpty) {
      final lastFulfillment = fulfillments.last;
      switch (lastFulfillment.shipmentStatus?.toLowerCase()) {
        case 'delivered':
          return 'Delivered';
        case 'out_for_delivery':
          return 'Out for Delivery';
        case 'in_transit':
          return 'In Transit';
        case 'failure':
          return 'Delivery Failed';
        case 'attempted_delivery':
          return 'Delivery Attempted';
        case 'ready_for_pickup':
          return 'Ready for Pickup';
        default:
          return 'Shipped';
      }
    }
    if (fulfillmentStatus.toLowerCase() == 'fulfilled') return 'Shipped';
    if (fulfillmentStatus.toLowerCase() == 'partial')
      return 'Partially Shipped';
    if (closedAt != null) return 'Completed';
    if (confirmed) return 'Processing';
    return 'Order Placed';
  }

  String get formattedDate {
    if (createdAt.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(createdAt).toLocal();
      const monthNames = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];
      String month = monthNames[dt.month - 1];
      int hour = dt.hour;
      String ampm = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      String minute = dt.minute.toString().padLeft(2, '0');
      return "${dt.day} $month ${dt.year}, $hour:$minute $ampm";
    } catch (e) {
      return createdAt.split('T')[0];
    }
  }

  int get totalQuantity {
    return lineItems.fold(0, (sum, item) => sum + item.quantity);
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'].toString(),
      orderNumber: json['order_number'].toString(),
      createdAt: json['created_at'] ?? '',
      totalPrice: json['total_price'] ?? '0.00',
      currency: json['currency'] ?? 'INR',
      fulfillmentStatus: json['fulfillment_status'] ?? 'pending',
      financialStatus: json['financial_status'] ?? 'pending',
      cancelledAt: json['cancelled_at'],
      closedAt: json['closed_at'],
      confirmed: json['confirmed'] ?? false,
      lineItems: (json['line_items'] as List? ?? [])
          .map((item) => LineItem.fromJson(item))
          .toList(),
      fulfillments: (json['fulfillments'] as List? ?? [])
          .map((f) => Fulfillment.fromJson(f))
          .toList(),
    );
  }
}

class Fulfillment {
  final String id;
  final String? shipmentStatus;
  final String? trackingNumber;
  final String? trackingUrl;
  final String? trackingCompany;

  Fulfillment({
    required this.id,
    this.shipmentStatus,
    this.trackingNumber,
    this.trackingUrl,
    this.trackingCompany,
  });

  factory Fulfillment.fromJson(Map<String, dynamic> json) {
    return Fulfillment(
      id: json['id'].toString(),
      shipmentStatus: json['shipment_status'],
      trackingNumber: json['tracking_number'],
      trackingUrl: json['tracking_url'],
      trackingCompany: json['tracking_company'],
    );
  }
}

class LineItem {
  final String title;
  final int quantity;
  final String price;
  final String? variantTitle;
  final String? image;

  LineItem({
    required this.title,
    required this.quantity,
    required this.price,
    this.variantTitle,
    this.image,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) {
    // Advanced image detection for multiple API formats (REST, GraphQL mapped, etc.)
    String? img;
    var rawImage = json['image'];

    if (rawImage != null) {
      if (rawImage is String) {
        img = rawImage;
      } else if (rawImage is Map) {
        img = rawImage['src'] ?? rawImage['url'];
      }
    }

    // Fallback search in nested structures
    img ??= json['product']?['image']?['src'] ??
        json['product']?['featuredImage']?['url'] ??
        json['variant']?['image']?['url'] ??
        json['variant']?['product']?['featuredImage']?['url'];

    // Clean the URL
    if (img != null) {
      img = img.trim();
      if (img.isEmpty || !img.startsWith('http')) img = null;
    }

    debugPrint("[Model Parse] Item: ${json['title']} | Image: $img");

    return LineItem(
      title: json['title'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price']?.toString() ?? '0.00',
      variantTitle: json['variant_title'],
      image: img,
    );
  }
}
