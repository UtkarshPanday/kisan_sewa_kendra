import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controller/constants.dart';
import '../controller/auth_controller.dart';
import '../shopify/shopify.dart';
import '../model/order_model.dart';
import 'order_detail_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan_sewa_kendra/components/network_image.dart';
import 'support_view.dart';
import '../controller/cart_controller.dart';
import '../controller/routers.dart';
import 'cart_view.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with AutomaticKeepAliveClientMixin {
  List<OrderModel> _orders = [];
  bool _isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    var customerId = await AuthController.getShopifyCustomerId();
    if (customerId == null) {
      final phone = await AuthController.getSavedPhone();
      if (phone != null) {
        await AuthController.syncWithShopify(phone);
        customerId = await AuthController.getShopifyCustomerId();
      }
    }
    if (customerId == null) return;

    if (mounted) setState(() => _isLoadingOrders = true);
    try {
      final orderData = await ShopifyAPI.getCustomerOrders(customerId);
      if (mounted) {
        setState(() {
          _orders = orderData.map((e) => OrderModel.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint("Fetch Orders Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingOrders = false);
    }
  }

  @override
  bool get wantKeepAlive => true;

  List<OrderModel> _filterOrders(int index) {
    if (index == 0) return _orders; // All
    if (index == 1) {
      // Ongoing
      return _orders
          .where((o) =>
              o.trackingStatus != 'Completed' &&
              o.trackingStatus != 'Delivered' &&
              o.trackingStatus != 'Cancelled')
          .toList();
    }
    if (index == 2) {
      // Completed
      return _orders
          .where((o) =>
              o.trackingStatus == 'Completed' ||
              o.trackingStatus == 'Delivered')
          .toList();
    }
    if (index == 3) {
      // Cancelled
      return _orders.where((o) => o.trackingStatus == 'Cancelled').toList();
    }
    return _orders;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool loggedIn = AuthController.isLoggedIn();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffF9FBF9),
        body: Stack(
          children: [
            // Background Layer (Covers the whole screen, including status bar)
            Positioned.fill(
              child: Container(color: const Color(0xffF9FBF9)),
            ),

            // Background Shapes (Allowed to bleed into status bar area for "transparent" effect)
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Constants.baseColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 70, // Kept lower as previously requested
              left: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Constants.baseColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main Content (Protected by SafeArea)
            SafeArea(
              child: !loggedIn
                  ? _buildLoginPrompt()
                  : DefaultTabController(
                      length: 4,
                      child: Builder(builder: (context) {
                        final tabController = DefaultTabController.of(context);
                        return Column(
                          children: [
                            _buildAdvancedHeader(),
                            _buildFilterChips(tabController),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildOrderList(0),
                                  _buildOrderList(1),
                                  _buildOrderList(2),
                                  _buildOrderList(3),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedHeader() {
    int activeCount = _filterOrders(1).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Orders",
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Constants.baseColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Constants.baseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      activeCount > 0
                          ? "$activeCount ACTIVE"
                          : "NO ACTIVE ORDERS",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Order History",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildStatIndicator(),
        ],
      ),
    );
  }

  Widget _buildStatIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Constants.baseColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            _orders.length.toString(),
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Constants.baseColor,
            ),
          ),
          Text(
            "TOTAL",
            style: GoogleFonts.inter(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              color: Constants.baseColor,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(TabController controller) {
    const filters = ["All Orders", "Ongoing", "Delivered", "Cancelled"];
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          color: Colors.transparent,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filters.length,
            itemBuilder: (context, index) {
              final isSelected = controller.index == index;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => controller.animateTo(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Constants.baseColor
                          : Colors.grey.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? Constants.baseColor
                            : Colors.grey.withOpacity(0.1),
                      ),
                      boxShadow: [],
                    ),
                    child: Center(
                      child: Text(
                        filters[index],
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderList(int filterIndex) {
    final filteredOrders = _filterOrders(filterIndex);

    if (_isLoadingOrders && filteredOrders.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        itemBuilder: (context, index) => _buildAdvancedShimmer(),
      );
    }

    if (filteredOrders.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchOrders,
        color: Constants.baseColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 400,
            child: _buildEmptyOrders(),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: Constants.baseColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) =>
            _buildAdvancedCard(filteredOrders[index]),
      ),
    );
  }

  Widget _buildAdvancedShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Constants.shimmer(height: 20, width: 100),
                Constants.shimmer(height: 20, width: 60),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Constants.shimmer(height: 50, width: 50),
                const SizedBox(width: 12),
                Constants.shimmer(height: 50, width: 50),
                const SizedBox(width: 12),
                Constants.shimmer(height: 50, width: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedCard(OrderModel order) {
    String status = order.trackingStatus;
    Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => OrderDetailView(order: order)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusIndicator(status, statusColor),
                      Text(
                        "${Constants.inr}${order.totalPrice}",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${order.totalQuantity} Item${order.totalQuantity > 1 ? 's' : ''}",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            order.formattedDate,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDynamicProductList(order),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          label: "Details",
                          icon: Icons.info_outline,
                          color: Colors.grey.withOpacity(0.1),
                          textColor: Colors.grey[500]!,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      OrderDetailView(order: order)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          label: "Reorder",
                          icon: Icons.refresh_rounded,
                          color: Constants.baseColor,
                          onPressed: () async {
                            final scaffoldMessenger =
                                ScaffoldMessenger.of(context);
                            for (var item in order.lineItems) {
                              if (item.variantId != null) {
                                await CartController.addToCart(
                                  variantId: item.variantId!,
                                  productId: item.productId,
                                  qty: item.quantity,
                                  title: item.title,
                                  price: item.price,
                                  image: item.image,
                                  variantTitle: item.variantTitle ?? '',
                                );
                              }
                            }
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                  content: Text("Items added to bag")),
                            );
                            if (mounted) {
                              Routers.goTO(context, toBody: const CartView());
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicProductList(OrderModel order) {
    final items = order.lineItems;
    const double itemWidth = 36.0;
    const double spacing = 4.0;
    const double totalItemMetric = itemWidth + spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        int maxPossible = (maxWidth / totalItemMetric).floor();
        if (maxPossible < 1) return const SizedBox.shrink();

        int displayCount;
        bool showCounter = items.length > maxPossible;

        if (showCounter) {
          displayCount = maxPossible; // last one will be the counter
        } else {
          displayCount = items.length;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(displayCount, (index) {
            final bool isLast = showCounter && index == displayCount - 1;
            // If we are showing a counter in the last spot,
            // the number of hidden items is total - (displayCount - 1)
            final int hiddenCount = items.length - (displayCount - 1);

            return Container(
              width: itemWidth,
              height: itemWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isLast
                    ? Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Text(
                            "+$hiddenCount",
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    : (items[index].image == null || items[index].image!.isEmpty
                        ? Container(
                            color: Colors.grey[50],
                            child: Icon(Icons.shopping_bag_outlined,
                                color: Colors.grey[200], size: 16))
                        : KskNetworkImage(items[index].image!,
                            fit: BoxFit.cover)),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        elevation: 0,
        minimumSize: const Size(double.infinity, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 14),
      label: Text(label,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Color _getStatusColor(String status) {
    status = status.toLowerCase();
    if (status.contains('delivered') || status.contains('completed'))
      return const Color(0xFF43A047);
    if (status.contains('cancelled')) return const Color(0xFFE53935);
    if (status.contains('pending') || status.contains('processing'))
      return const Color(0xFFFB8C00);
    return Constants.baseColor;
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Constants.baseColor.withOpacity(0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shield_moon_rounded,
                  size: 80, color: Constants.baseColor.withOpacity(0.2)),
            ),
            const SizedBox(height: 32),
            Text(
              "Access Restricted",
              style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E)),
            ),
            const SizedBox(height: 12),
            Text(
              "Please sign in to view your orders and track the progress of your shipments in real-time.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Colors.grey[500], fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.shopping_bag_outlined,
                  size: 80, color: Colors.grey[200]),
            ),
            const SizedBox(height: 32),
            Text(
              "Your Bag is Empty",
              style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E1E1E)),
            ),
            const SizedBox(height: 10),
            Text(
              "Looks like you haven't placed any orders yet. Start shopping to fill it up!",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Colors.grey[400], fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
