import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/order_model.dart';
import '../controller/constants.dart';
import '../shopify/shopify.dart';
import '../components/network_image.dart';
import '../controller/cart_controller.dart';
import '../controller/routers.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
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
          AppLocalizations.of(context)!.orderSummary,
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
      {
        'title': AppLocalizations.of(context)!.orderPlaced,
        'key': 'placed',
        'active': true
      },
      {
        'title': AppLocalizations.of(context)!.processing,
        'key': 'processing',
        'active': _currentOrder.confirmed ||
            ['Shipped', 'Out for Delivery', 'Delivered', 'Completed']
                .contains(status)
      },
      {
        'title': AppLocalizations.of(context)!.shipped,
        'key': 'shipped',
        'active': ['Shipped', 'Out for Delivery', 'Delivered', 'Completed']
            .contains(status)
      },
      {
        'title': AppLocalizations.of(context)!.outForDelivery,
        'key': 'out',
        'active':
            ['Out for Delivery', 'Delivered', 'Completed'].contains(status)
      },
      {
        'title': AppLocalizations.of(context)!.delivered,
        'key': 'delivered',
        'active': ['Delivered', 'Completed'].contains(status)
      },
    ];

    if (isCancelled) {
      stages = [
        {'title': AppLocalizations.of(context)!.orderPlaced, 'active': true},
        {
          'title': AppLocalizations.of(context)!.cancelled,
          'active': true,
          'isError': true
        },
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
          Text(AppLocalizations.of(context)!.trackOrder,
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
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .statusUpdatedRecently,
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
                label: Text(AppLocalizations.of(context)!.trackOnShopify),
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
              Text(AppLocalizations.of(context)!.orderInfo,
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
          _infoRow(
              Icons.calendar_today_rounded,
              AppLocalizations.of(context)!.placedOn,
              _currentOrder.formattedDate),
          const SizedBox(height: 12),
          _infoRow(
              Icons.payment_rounded,
              AppLocalizations.of(context)!.payment,
              _currentOrder.financialStatus.toUpperCase() == 'PENDING'
                  ? 'COD'
                  : _currentOrder.financialStatus),
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
            child: Text(AppLocalizations.of(context)!.yourOrderItems,
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
          Text(AppLocalizations.of(context)!.billSummary,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Constants.baseColor,
                  letterSpacing: 1)),
          const SizedBox(height: 20),
          _billRow(AppLocalizations.of(context)!.itemTotal,
              _currentOrder.subtotalPrice ?? '0.00'),
          const SizedBox(height: 12),
          _billRow(AppLocalizations.of(context)!.deliveryCharge,
              _currentOrder.totalShipping ?? 'FREE',
              isFree: _currentOrder.totalShipping == '0.00' ||
                  _currentOrder.totalShipping == null),
          const SizedBox(height: 12),
          _billRow(AppLocalizations.of(context)!.handlingFee, "0.00"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppLocalizations.of(context)!.grandTotal,
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
            label: Text(AppLocalizations.of(context)!.needHelp,
                style: GoogleFonts.inter(
                    color: const Color(0xFF1E1E1E),
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.of(context)!.paidVia(
                _currentOrder.financialStatus.toUpperCase() == 'PENDING'
                    ? 'COD'
                    : _currentOrder.financialStatus.toUpperCase()),
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

  Future<void> _handleCancelOrder() async {
    String? selectedReason;
    final reasons = [
      AppLocalizations.of(context)!.reasonChangedMind,
      AppLocalizations.of(context)!.reasonMistake,
      AppLocalizations.of(context)!.reasonBetterPrice,
      AppLocalizations.of(context)!.reasonLongTime,
      AppLocalizations.of(context)!.reasonCoupon,
      AppLocalizations.of(context)!.reasonOther,
    ];

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                AppLocalizations.of(context)!.cancelOrder,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.cancellationReason,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              ...reasons.map((reason) => InkWell(
                    onTap: () => setModalState(() => selectedReason = reason),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedReason == reason
                              ? Colors.red
                              : Colors.grey[200]!,
                        ),
                        color: selectedReason == reason
                            ? Colors.red.withOpacity(0.05)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              reason,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: selectedReason == reason
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selectedReason == reason
                                    ? Colors.red
                                    : const Color(0xFF1E1E1E),
                              ),
                            ),
                          ),
                          if (selectedReason == reason)
                            const Icon(Icons.check_circle,
                                size: 20, color: Colors.red),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.goBack,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: selectedReason == null
                          ? null
                          : () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[200],
                        disabledForegroundColor: Colors.grey[500],
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancelOrder,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).then((confirmed) async {
      if (confirmed == true && mounted) {
        setState(() => _isLoading = true);
        final success = await ShopifyAPI.cancelOrder(widget.order.id);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.cancelSuccess),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            _refreshOrder();
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.cancelFail),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() => _isLoading = false);
          }
        }
      }
    });
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentOrder.isCancellable) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleCancelOrder,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(
                        color: Colors.red.withOpacity(0.5), width: 1.2),
                    backgroundColor: Colors.red.withOpacity(0.02),
                    minimumSize: const Size(double.infinity, 48),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.red),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cancel_outlined, size: 16),
                            const SizedBox(width: 8),
                            Text(AppLocalizations.of(context)!.cancelOrder,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700, fontSize: 13)),
                          ],
                        ),
                ),
              ),
              const SizedBox(width: 12),
            ],
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
                  messenger.showSnackBar(const SnackBar(
                      content: Text("Order items added to bag")));
                  Routers.goTO(context, toBody: const CartView());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.baseColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 48),
                  padding: const EdgeInsets.symmetric(vertical: 0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(AppLocalizations.of(context)!.reorder,
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w900, fontSize: 13)),
              ),
            ),
          ],
        ),
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
      return AppLocalizations.of(context)!.statusDeliveredMsg;
    if (status.contains('shipped'))
      return AppLocalizations.of(context)!.statusShippedMsg;
    if (status.contains('processing'))
      return AppLocalizations.of(context)!.statusProcessingMsg;
    if (status.contains('cancelled'))
      return AppLocalizations.of(context)!.statusCancelledMsg;
    return AppLocalizations.of(context)!.statusDefaultMsg;
  }
}
