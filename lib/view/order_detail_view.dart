import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/order_model.dart';
import '../controller/constants.dart';
import '../shopify/shopify.dart';
import '../components/network_image.dart';
import '../controller/cart_controller.dart';
import '../controller/routers.dart';
import 'cart_view.dart';
import 'support_view.dart';

class OrderDetailView extends StatefulWidget {
  final OrderModel order;
  const OrderDetailView({super.key, required this.order});

  @override
  State<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  late OrderModel _currentOrder;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _refreshOrder();
  }

  Future<void> _refreshOrder() async {
    setState(() => _isLoading = true);
    try {
      final data = await ShopifyAPI.getOrderFullDetails(widget.order.id);
      if (data.isNotEmpty && mounted) {
        setState(() {
          _currentOrder = OrderModel.fromJson(data);
        });
      }
    } catch (e) {
      debugPrint("Refresh detail error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Constants.baseColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Order Summary",
          style: GoogleFonts.outfit(
              color: Constants.baseColor,
              fontWeight: FontWeight.w800,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading && _currentOrder.shippingAddress == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  _buildOrderInfoSection(),
                  _buildTrackingTimeline(),
                  _buildItemList(),
                  _buildBillSummary(),
                  _buildHelpAction(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildTrackingTimeline() {
    String status = _currentOrder.trackingStatus;
    bool isCancelled = status == 'Cancelled';

    List<Map<String, dynamic>> stages = [
      {'title': 'Order Placed', 'key': 'placed', 'active': true},
      {
        'title': 'Processing',
        'key': 'processing',
        'active': _currentOrder.confirmed ||
            ['Shipped', 'Out for Delivery', 'Delivered', 'Completed']
                .contains(status)
      },
      {
        'title': 'Shipped',
        'key': 'shipped',
        'active': ['Shipped', 'Out for Delivery', 'Delivered', 'Completed']
            .contains(status)
      },
      {
        'title': 'Out for Delivery',
        'key': 'out',
        'active':
            ['Out for Delivery', 'Delivered', 'Completed'].contains(status)
      },
      {
        'title': 'Delivered',
        'key': 'delivered',
        'active': ['Delivered', 'Completed'].contains(status)
      },
    ];

    if (isCancelled) {
      stages = [
        {'title': 'Order Placed', 'active': true},
        {'title': 'Cancelled', 'active': true, 'isError': true},
      ];
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TRACK ORDER",
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Constants.baseColor,
                  letterSpacing: 1)),
          const SizedBox(height: 20),
          Column(
            children: List.generate(stages.length, (index) {
              final stage = stages[index];
              bool isActive = stage['active'];
              bool isError = stage['isError'] ?? false;
              bool isLast = index == stages.length - 1;
              Color activeColor = isError ? Colors.red : Constants.baseColor;

              return IntrinsicHeight(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    isActive ? activeColor : Colors.grey[300]!,
                                width: 2),
                            color: isActive ? activeColor : Colors.white,
                          ),
                          child: isActive
                              ? const Icon(Icons.check,
                                  size: 8, color: Colors.white)
                              : null,
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isActive
                                  ? activeColor.withOpacity(0.3)
                                  : Colors.grey[200],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(stage['title'],
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: isActive
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: isActive
                                        ? (isError
                                            ? Colors.red
                                            : const Color(0xFF1E1E1E))
                                        : Colors.grey[400])),
                            if (isActive && !isLast && !isError)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text("Status updated recently",
                                    style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.grey[400],
                                        fontWeight: FontWeight.w500)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          if (_currentOrder.orderStatusUrl != null &&
              _currentOrder.orderStatusUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(_currentOrder.orderStatusUrl!);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text("Track order on Shopify"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Constants.baseColor,
                  side: BorderSide(color: Constants.baseColor, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          // FORCED TEST TRACKING (User requested: 19041902964601 for 17TRACK)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  const awb = "19041902964601";
                  final url = Uri.parse("https://t.17track.net/en#nums=$awb");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.local_shipping_outlined, size: 16),
                label: const Text("Track your Order (19041902964601)"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE91E63),
                  side: const BorderSide(color: Color(0xFFE91E63), width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ORDER INFO",
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Constants.baseColor,
                      letterSpacing: 1)),
              Text("#${_currentOrder.orderNumber}",
                  style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1E1E))),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.calendar_today_rounded, "Placed on",
              _currentOrder.formattedDate),
          const SizedBox(height: 12),
          _infoRow(
              Icons.payment_rounded, "Payment", _currentOrder.financialStatus),
        ],
      ),
    );
  }

  Widget _buildItemList() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text("YOUR ORDER ITEMS",
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Constants.baseColor,
                    letterSpacing: 1)),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _currentOrder.lineItems.length,
            separatorBuilder: (_, __) => Divider(
                height: 1, indent: 20, endIndent: 20, color: Colors.grey[100]),
            itemBuilder: (context, index) {
              final item = _currentOrder.lineItems[index];
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[100]!)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: item.image != null
                            ? KskNetworkImage(item.image!, fit: BoxFit.cover)
                            : Icon(Icons.shopping_bag_outlined,
                                color: Colors.grey[200]),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E1E1E))),
                          const SizedBox(height: 4),
                          Text(
                              "Qty: ${item.quantity} • ${item.variantTitle ?? 'Standard'}",
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[500])),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text("${Constants.inr}${item.price}",
                        style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E1E1E))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummary() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("BILL SUMMARY",
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Constants.baseColor,
                  letterSpacing: 1)),
          const SizedBox(height: 20),
          _billRow("Item Total", _currentOrder.subtotalPrice ?? '0.00'),
          const SizedBox(height: 12),
          _billRow("Delivery Charge", _currentOrder.totalShipping ?? 'FREE',
              isFree: _currentOrder.totalShipping == '0.00' ||
                  _currentOrder.totalShipping == null),
          const SizedBox(height: 12),
          _billRow("Handling Fee", "0.00"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Grand Total",
                  style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E1E1E))),
              Text("${Constants.inr}${_currentOrder.totalPrice}",
                  style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Constants.baseColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelpAction() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: () {
              Routers.goTO(context, toBody: const SupportView());
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(color: Colors.grey[200]!),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: Icon(Icons.headset_mic_outlined,
                size: 18, color: Constants.baseColor),
            label: Text("Need help with this order?",
                style: GoogleFonts.inter(
                    color: const Color(0xFF1E1E1E),
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
          const SizedBox(height: 20),
          Text(
            "Paid via ${(_currentOrder.financialStatus).toUpperCase()}",
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.grey[300],
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                for (var item in _currentOrder.lineItems) {
                  if (item.variantId != null) {
                    await CartController.addToCart(
                      variantId: item.variantId!,
                      qty: item.quantity,
                      title: item.title,
                      price: item.price,
                      image: item.image,
                      variantTitle: item.variantTitle ?? '',
                    );
                  }
                }
                messenger.showSnackBar(
                    const SnackBar(content: Text("Order items added to bag")));
                Routers.goTO(context, toBody: const CartView());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.baseColor,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text("REORDER",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500])),
        const Spacer(),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E1E))),
      ],
    );
  }

  Widget _billRow(String label, String value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600])),
        Text(isFree ? "FREE" : "${Constants.inr}$value",
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isFree ? Colors.green : const Color(0xFF1E1E1E))),
      ],
    );
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('delivered') || status.contains('completed')) {
      return const Color(0xFF43A047);
    }
    if (status.contains('cancelled')) return const Color(0xFFE53935);
    if (status.contains('pending') || status.contains('processing')) {
      return const Color(0xFFFB8C00);
    }
    return Constants.baseColor;
  }

  IconData _getStatusIcon(String status) {
    status = status.toLowerCase();
    if (status.contains('delivered') || status.contains('completed')) {
      return Icons.check_circle_rounded;
    }
    if (status.contains('cancelled')) return Icons.cancel_rounded;
    if (status.contains('out for delivery'))
      return Icons.delivery_dining_rounded;
    if (status.contains('shipped')) return Icons.local_shipping_rounded;
    return Icons.access_time_filled_rounded;
  }

  String _getFriendlyStatusMsg(String status) {
    status = status.toLowerCase();
    if (status.contains('delivered'))
      return "Successfully delivered to your doorstep.";
    if (status.contains('shipped'))
      return "Merchant has handed over the order to courier.";
    if (status.contains('processing'))
      return "Order is being packed and prepared for pickup.";
    if (status.contains('cancelled'))
      return "Your order was cancelled. Refund will be processed.";
    return "Great! Looking forward to serving you.";
  }
}
