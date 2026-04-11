import 'package:flutter/material.dart';
import '../home_view.dart';
import '../../controller/constants.dart';

class OrderSuccessView extends StatefulWidget {
  final String orderNumber;
  final double totalAmount;
  final String paymentId;

  const OrderSuccessView({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
    required this.paymentId,
  });

  @override
  State<OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends State<OrderSuccessView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated checkmark
                ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Constants.baseColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Constants.baseColor.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Text(
                  'Order Placed!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thank you for shopping with ${Constants.title}. Your order has been confirmed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade500,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // Order Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Constants.baseColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Constants.baseColor.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Order Number', widget.orderNumber),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        'Amount Pending',
                        '₹${widget.totalAmount.toStringAsFixed(2)}',
                        isHighlight: true,
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        'Payment Method',
                        'Cash on Delivery',
                        isSmall: true,
                      ),
                      if (widget.paymentId.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _buildDetailRow('Payment ID', widget.paymentId,
                            isSmall: true),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Delivery info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_shipping_rounded,
                        color: Constants.baseColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'You will receive a confirmation email shortly',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade500),
                    ),
                  ],
                ),

                const Spacer(),

                // Continue Shopping Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const MyHomePage()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.baseColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue Shopping',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlight = false, bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: isSmall ? 12 : 14, color: Colors.grey.shade600),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.w700,
              color:
                  isHighlight ? Constants.baseColor : const Color(0xFF1a1a1a),
            ),
          ),
        ),
      ],
    );
  }
}
