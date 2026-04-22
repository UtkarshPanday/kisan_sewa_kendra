import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kisan_sewa_kendra/components/cart_summary_bar.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
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
            : Stack(
                children: [
                  IndexedStack(
                    index: _currentIndex,
                    children: [
                      Home(scrollController: _scrollController),
                      const Categories(),
                      const OrderView(),
                      const SupportView(),
                    ],
                  ),
                  const Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CartSummaryBar(),
                    ),
                  ),
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
            items: [
              BottomNavigationBarItem(
                  icon: const Icon(FontAwesomeIcons.house, size: 18),
                  label: AppLocalizations.of(context)!.home),
              BottomNavigationBarItem(
                  icon: const Icon(FontAwesomeIcons.list, size: 18),
                  label: AppLocalizations.of(context)!.categories),
              BottomNavigationBarItem(
                  icon: const Icon(FontAwesomeIcons.bagShopping, size: 18),
                  label: AppLocalizations.of(context)!.myOrders),
              BottomNavigationBarItem(
                  icon: const Icon(FontAwesomeIcons.headset, size: 18),
                  label: AppLocalizations.of(context)!.support),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFDFDFD),
      width: MediaQuery.of(context).size.width * 0.80,
      child: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.zero,
            height: 215,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Constants.baseColor,
                        Constants.baseColor.withBlue(45).withGreen(100),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(45),
                    ),
                  ),
                ),
                Positioned(
                  top: -45,
                  right: -45,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AnimatedDrawerLogo(size: 56),
                        const SizedBox(height: 12),
                        const Text(
                          "हर किसान की पहचान !",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSectionHeader(AppLocalizations.of(context)!.menu),
                _drawerItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    title: AppLocalizations.of(context)!.home,
                    isSelected: _currentIndex == 0,
                    onTap: () => Navigator.pop(context)),
                _drawerItem(
                    icon: Icons.grid_view_outlined,
                    activeIcon: Icons.grid_view_rounded,
                    title: AppLocalizations.of(context)!.categories,
                    isSelected: _currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 1);
                    }),
                _drawerItem(
                    icon: Icons.shopping_bag_outlined,
                    activeIcon: Icons.shopping_bag_rounded,
                    title: AppLocalizations.of(context)!.myOrders,
                    isSelected: _currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 2);
                    }),
                _drawerItem(
                    icon: Icons.shopping_cart_outlined,
                    activeIcon: Icons.shopping_cart_rounded,
                    title: AppLocalizations.of(context)!.myCart,
                    onTap: () {
                      Navigator.pop(context);
                      Routers.goTO(context, toBody: const CartView());
                    }),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF5F5F5)),
                ),
                _buildSectionHeader(AppLocalizations.of(context)!.support),
                _drawerItem(
                    icon: Icons.contact_support_outlined,
                    activeIcon: Icons.contact_support_rounded,
                    title: AppLocalizations.of(context)!.contactUs,
                    isSelected: _currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentIndex = 3);
                    }),
                _drawerItem(
                    icon: Icons.privacy_tip_outlined,
                    title: AppLocalizations.of(context)!.privacyPolicy,
                    onTap: () {
                      Navigator.pop(context);
                      Routers.goTO(context,
                          toBody: PolicyPage(
                              title:
                                  AppLocalizations.of(context)!.privacyPolicy,
                              content: PolicyContent.privacyPolicy));
                    }),
                _drawerItem(
                    icon: Icons.local_shipping_outlined,
                    title: AppLocalizations.of(context)!.shippingPolicy,
                    onTap: () {
                      Navigator.pop(context);
                      Routers.goTO(context,
                          toBody: PolicyPage(
                              title:
                                  AppLocalizations.of(context)!.shippingPolicy,
                              content: PolicyContent.shippingPolicy));
                    }),
                _drawerItem(
                    icon: Icons.rule_rounded,
                    title: AppLocalizations.of(context)!.termsConditions,
                    onTap: () {
                      Navigator.pop(context);
                      Routers.goTO(context,
                          toBody: PolicyPage(
                              title:
                                  AppLocalizations.of(context)!.termsConditions,
                              content: PolicyContent.termsConditions));
                    }),
              ],
            ),
          ),

          // Bottom Version Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.02),
              border: const Border(
                top: BorderSide(color: Color(0xFFF5F5F5)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "v3.0.0",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.madeWithHeartForFarmers,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.eco_rounded,
                  color: Constants.baseColor.withOpacity(0.2),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 10, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    IconData? activeIcon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Constants.baseColor.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? (activeIcon ?? icon) : icon,
                size: 22,
                color: isSelected ? Constants.baseColor : Colors.grey[600],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Constants.baseColor : Colors.black87,
                  ),
                ),
              ),
              if (!isSelected)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: Colors.grey[300],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedDrawerLogo extends StatefulWidget {
  final double size;
  const AnimatedDrawerLogo({super.key, this.size = 60});

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
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Image.asset(Assets.assetsLogo,
            height: widget.size, width: widget.size),
      ),
    );
  }
}
