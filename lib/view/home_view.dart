import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kisan_sewa_kendra/view/support_view.dart';
import 'package:kisan_sewa_kendra/view/policy_pages.dart';

import '../components/ksk_appbar.dart';
import '../controller/constants.dart';
import '../controller/routers.dart';
import '../generated/assets.dart';
import 'component/home.dart';
import 'component/categories.dart';
import 'order_view.dart';
import 'cart_view.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await Constants.fetchRemoteConfig(context);
    if (mounted) {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false; // Prevent pop, stay in app
        }
        return true; // Allow pop, exit app
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF9FBF9),
        extendBodyBehindAppBar: false,
        appBar: _currentIndex == 0 ? const KskAppbar() : null,
        drawer: _buildModernDrawer(context),
        body: !_isDataLoaded
            ? AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
                child: const Center(child: CircularProgressIndicator()),
              )
            : IndexedStack(
                index: _currentIndex,
                children: [
                  Home(scrollController: _scrollController),
                  const Categories(),
                  const OrderView(),
                  const SupportView(),
                ],
              ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, -2))
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (value) {
              setState(() => _currentIndex = value);
            },
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.house, size: 18), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.list, size: 18),
                  label: "Categories"),
              BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.bagShopping, size: 18),
                  label: "My Orders"),
              BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.headset, size: 18),
                  label: "Support"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // Header Section with Gradient and Animated Logo
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Constants.baseColor,
                  Constants.baseColor.withOpacity(0.85)
                ],
              ),
              borderRadius:
                  const BorderRadius.only(bottomRight: Radius.circular(60)),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AnimatedDrawerLogo(),
                  const SizedBox(height: 15),
                  Text(
                    Constants.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5),
                  ),
                  const Text(
                    "Pure Organic Agriculture",
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              children: [
                _drawerItem(
                    icon: Icons.home_rounded,
                    title: "Home",
                    isSelected: _currentIndex == 0,
                    onTap: () => Navigator.pop(context)),
                _drawerItem(
                    icon: Icons.shopping_cart_rounded,
                    title: "My Cart",
                    onTap: () {
                      Navigator.pop(context);
                      Routers.goTO(context, toBody: const CartView());
                    }),
                _drawerItem(
                    icon: Icons.shopping_bag_rounded,
                    title: "My Orders",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  child: Divider(height: 1, color: Color(0xFFF0F0F0)),
                ),
                _drawerItem(
                    icon: Icons.privacy_tip_rounded,
                    title: "Privacy Policy",
                    onTap: () {
                      Navigator.pop(context);
                      Routers.goTO(context,
                          toBody: const PolicyPage(
                              title: "Privacy Policy",
                              content: PolicyContent.privacyPolicy));
                    }),
                _drawerItem(
                    icon: Icons.local_shipping_rounded,
                    title: "Shipping Policy",
                    onTap: () {
                      Navigator.pop(context);
                      Routers.goTO(context,
                          toBody: const PolicyPage(
                              title: "Shipping Policy",
                              content: PolicyContent.shippingPolicy));
                    }),
                _drawerItem(
                    icon: Icons.assignment_return_rounded,
                    title: "Return & Refund",
                    onTap: () {
                      Navigator.pop(context);
                      Routers.goTO(context,
                          toBody: const PolicyPage(
                              title: "Return & Refund",
                              content: PolicyContent.refundPolicy));
                    }),
                _drawerItem(
                    icon: Icons.gavel_rounded,
                    title: "Terms & Conditions",
                    onTap: () {
                      Navigator.pop(context);
                      Routers.goTO(context,
                          toBody: const PolicyPage(
                              title: "Terms & Conditions",
                              content: PolicyContent.termsConditions));
                    }),
                _drawerItem(
                    icon: Icons.contact_support_rounded,
                    title: "Contact Us",
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 3);
                    }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text("App Version 2.0.11",
                style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      {required IconData icon,
      required String title,
      required VoidCallback onTap,
      bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? Constants.baseColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon,
            size: 22,
            color: isSelected ? Constants.baseColor : Colors.grey[700]),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected ? Constants.baseColor : Colors.black87,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        dense: true,
        hoverColor: Constants.baseColor.withOpacity(0.05),
      ),
    );
  }
}

class AnimatedDrawerLogo extends StatefulWidget {
  const AnimatedDrawerLogo({super.key});

  @override
  State<AnimatedDrawerLogo> createState() => _AnimatedDrawerLogoState();
}

class _AnimatedDrawerLogoState extends State<AnimatedDrawerLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5))
          ],
        ),
        child: Image.asset(Assets.assetsLogo, height: 60, width: 60),
      ),
    );
  }
}
