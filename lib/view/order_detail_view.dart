import 'package:flutter/material.dart';
import '../model/order_model.dart';
import '../controller/constants.dart';
import '../shopify/shopify.dart';
import '../components/network_image.dart';

class OrderDetailView extends StatefulWidget {
  final OrderModel order;
  const OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  late OrderModel _currentOrder;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _refreshOrderDetails();
  }

  Future<void> _refreshOrderDetails() async {
    // Only refresh if we might be missing images or deep details
    setState(() => _isRefreshing = true);
    try {
      final details = await ShopifyAPI.getOrderDetails(widget.order.id);
      if (details.isNotEmpty && mounted) {
        // Map fetched details back to LineItems
        List<LineItem> updatedItems = details.map((d) {
          return LineItem(
            title: d['title'] ?? '',
            quantity: d['quantity'] ?? 1,
            price: d['price']?.toString() ?? '0.00',
            variantTitle: d['variant_title'],
            image: d['image'],
          );
        }).toList();

        setState(() {
          _currentOrder = OrderModel(
            id: widget.order.id,
            orderNumber: widget.order.orderNumber,
            createdAt: widget.order.createdAt,
            totalPrice: widget.order.totalPrice,
            currency: widget.order.currency,
            fulfillmentStatus: widget.order.fulfillmentStatus,
            financialStatus: widget.order.financialStatus,
            cancelledAt: widget.order.cancelledAt,
            closedAt: widget.order.closedAt,
            confirmed: widget.order.confirmed,
            lineItems: updatedItems,
            fulfillments: widget.order.fulfillments,
          );
        });
      }
    } catch (e) {
      debugPrint("Error refreshing order details: $e");
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Order Details",
          style: TextStyle(
              fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order #${_currentOrder.orderNumber}",
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 22),
                ),
                _statusBadge(_currentOrder.trackingStatus.toUpperCase()),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _currentOrder.formattedDate,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),

            if (_isRefreshing)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[100],
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Constants.baseColor.withOpacity(0.5)),
                  minHeight: 2,
                ),
              ),

            const SizedBox(height: 30),

            // Tracking Section
            const Text(
              "Tracking Progress",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 16),
            _buildTrackingTimeline(),

            const SizedBox(height: 30),

            // Line Items
            const Text(
              "Order Items",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _currentOrder.lineItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[200]!)),
                          child: item.image == null || item.image!.isEmpty
                              ? Icon(Icons.inventory_2_outlined,
                                  color: Constants.baseColor, size: 22)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: KskNetworkImage(
                                    item.image!,
                                    fit: BoxFit.cover,
                                    width: 45,
                                    height: 45,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Qty: ${item.quantity} ${item.variantTitle != null && item.variantTitle!.isNotEmpty ? '• ${item.variantTitle}' : ''}",
                                style: TextStyle(
                                    color:
                                        const Color.fromRGBO(117, 117, 117, 1),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "${Constants.inr}${item.price}",
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Totals
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total Amount",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  Text(
                    "${Constants.inr}${_currentOrder.totalPrice}",
                    style: TextStyle(
                        color: Constants.baseColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    List<Map<String, dynamic>> stages = [
      {'title': 'Order Placed', 'active': true},
      {
        'title': 'Processing',
        'active': _currentOrder.confirmed ||
            _currentOrder.trackingStatus == 'Shipped' ||
            _currentOrder.trackingStatus == 'Delivered' ||
            _currentOrder.trackingStatus == 'Out for Delivery' ||
            _currentOrder.trackingStatus == 'In Transit'
      },
      {
        'title': 'Shipped',
        'active': _currentOrder.trackingStatus == 'Shipped' ||
            _currentOrder.trackingStatus == 'Delivered' ||
            _currentOrder.trackingStatus == 'Out for Delivery' ||
            _currentOrder.trackingStatus == 'In Transit'
      },
      {
        'title': 'Out for Delivery',
        'active': _currentOrder.trackingStatus == 'Out for Delivery' ||
            _currentOrder.trackingStatus == 'Delivered'
      },
      {
        'title': 'Delivered',
        'active': _currentOrder.trackingStatus == 'Delivered' ||
            _currentOrder.trackingStatus == 'Completed'
      },
    ];

    if (_currentOrder.trackingStatus == 'Cancelled') {
      stages = [
        {'title': 'Order Placed', 'active': true},
        {'title': 'Cancelled', 'active': true, 'isError': true},
      ];
    }

    return Column(
      children: List.generate(stages.length, (index) {
        bool isActive = stages[index]['active'];
        bool isError = stages[index]['isError'] ?? false;
        bool isLast = index == stages.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isActive
                        ? (isError ? Colors.red : Constants.baseColor)
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: isActive
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 30,
                    color: isActive ? Constants.baseColor : Colors.grey[300],
                  )
              ],
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text(
                stages[index]['title'],
                style: TextStyle(
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 15,
                    color: isActive
                        ? (isError ? Colors.red[700] : Colors.black87)
                        : Colors.grey[500]),
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _statusBadge(String status) {
    bool isDone =
        status == 'SHIPPED' || status == 'DELIVERED' || status == 'COMPLETED';
    bool isCancelled = status == 'CANCELLED';

    Color textColor;
    Color bgColor;

    if (isCancelled) {
      textColor = Colors.red[700]!;
      bgColor = Colors.red.withOpacity(0.12);
    } else if (isDone) {
      textColor = Colors.green[700]!;
      bgColor = Colors.green.withOpacity(0.12);
    } else {
      textColor = Colors.orange[800]!;
      bgColor = Colors.orange.withOpacity(0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
