import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../components/network_image.dart';
import '../../components/products_grid.dart';
import '../../components/widget_button.dart';
import '../../controller/constants.dart';
import '../../controller/routers.dart';
import '../collection_view.dart';
import '../product_view.dart';
import '../../model/categories_model.dart';
import '../../model/product_model.dart';
import '../../shopify/shopify.dart';

class Home extends StatefulWidget {
  final ScrollController scrollController;

  const Home({
    super.key,
    required this.scrollController,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoriesModel> _categories = [];
  List<CategoriesModel> _banners = [];
  bool _isLoadingCats = true;
  bool _isLoadingBanners = true;
  List<String> _bestSellerIds = [];

  @override
  void initState() {
    super.initState();
    _initCategories();
    _fetchBanners();
    _fetchBestSellerIds();
    Constants.languageController.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    Constants.languageController.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) {
      _refresh();
    }
  }

  /// Refreshes all home data simultaneously (called on pull-to-refresh)
  Future<void> _refresh() async {
    await Future.wait([
      _fetchBanners(),
      _initCategories(),
      _fetchBestSellerIds(),
    ]);
  }

  Future<void> _fetchBanners() async {
    final banners = await Shopify.getBannerCollections(context);
    if (mounted) {
      setState(() {
        _banners = banners;
        _isLoadingBanners = false;
      });
      // Preload banner images
      for (var banner in _banners) {
        if (banner.image.isNotEmpty) {
          precacheImage(NetworkImage(banner.image), context);
        }
      }
    }
  }

  Future<void> _fetchBestSellerIds() async {
    final allCats = Constants.homeScreenCatBanners;
    String? bestSellerId;
    for (var cat in allCats) {
      if (cat['image']?.toLowerCase().contains('best') ?? false) {
        bestSellerId = cat['id'];
        break;
      }
    }

    if (bestSellerId != null) {
      final result = await Shopify.getProductsFromCollections(
        context,
        id: bestSellerId,
        limit: 10,
      );
      final List<ProductModel> products =
          (result['product'] as List<dynamic>?)?.cast<ProductModel>() ?? [];
      if (mounted) {
        setState(() {
          _bestSellerIds = products.map((p) => p.id).toList();
        });
      }
    }
  }

  void _handleBannerClick(CategoriesModel banner) async {
    int index = _banners.indexOf(banner);

    debugPrint("Banner Index: $index");

    // 🟢 Banner 0 → Collection
    if (index == 0) {
      Routers.goTO(
        context,
        toBody: CollectionView(
          collectionId: "329026470041",
        ),
      );
    }

    // 🔥 Banner 1 → Product 1
    else if (index == 1) {
      await _openProduct("bifent-10-ec-bifenthrin-10-ec");
    }

    // 🔥 Banner 2 → Clearmite (Mites & Thrips)
    else if (index == 2) {
      await _openProduct("Clearmite");
    }

    // 🔥 Banner 3 → Product 3
    else if (index == 3) {
      await _openProduct("humiroot-humic-acid-fulvic-acid-98");
    }

    // 🔥 Banner 4 → Product 4
    else if (index == 4) {
      await _openProduct("humic-acid-premium-quality");
    }

    // 🛑 fallback
    else {
      Routers.goTO(
        context,
        toBody: CollectionView(
          collectionId: "329026142361",
        ),
      );
    }
  }

  Future<void> _openProduct(String handle,
      {String? fallbackCollectionId}) async {
    try {
      debugPrint("🔍 Fetching product handle: $handle");

      final results = await Shopify.fetchSearchResults(context, query: handle);

      debugPrint("🔍 Search results count: ${results.length}");
      for (var r in results) {
        debugPrint("   → handle: ${r.handle}  title: ${r.title}");
      }

      if (results.isNotEmpty) {
        // Try exact handle match first, fallback to first result
        final product = results.any((p) => p.handle == handle)
            ? results.firstWhere((p) => p.handle == handle)
            : results.first;

        if (mounted) {
          Routers.goTO(context, toBody: ProductView(product: product));
        }
      } else {
        debugPrint("⚠️ Product not found: $handle");
        if (mounted) {
          // Fallback → go to a collection if provided
          if (fallbackCollectionId != null) {
            Routers.goTO(context,
                toBody: CollectionView(collectionId: fallbackCollectionId));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Product not available right now."),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("❌ Product open error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong. Please try again."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _initCategories() async {
    final allCategories =
        await Shopify.getCategories(context, forcedLang: 'EN');

    final List<String> orderedTitles = [
      'PGRs',
      'Insecticides',
      'Fungicides',
      'Fertilizers',
      'Herbicides',
      'NPK Fertilizers',
      'Bio-Pesticides',
      'Bio-Fungicide',
      'Bio-Fertilizers',
    ];

    final Map<String, List<String>> titleAliases = {
      'PGRs': [
        'PGR',
        'Growth Promoter',
        'Plant Growth Regulator',
        'Growth Promoters',
        'Growth Promotors',
        'Promoter',
        'PGRS'
      ],
      'Insecticides': ['Insecticide', 'Insecticides'],
      'Fungicides': ['Fungicide', 'Fungicides'],
      'Fertilizers': [
        'Fertilizer',
        'Fertilizers',
        'Organic Fertilizer',
        'Organic Fertilizers',
        'Bio-Fertilizer',
        'Bio Fertilizer'
      ],
      'Herbicides': ['Herbicide', 'Herbicides', 'Weedicide'],
      'NPK Fertilizers': ['NPK', 'NPK Fertilizer', 'NPK Fertilizers'],
      'Bio-Pesticides': [
        'Bio-Pesticide',
        'Bio Pesticide',
        'Biological Pesticide',
        'Bio-Insecticide',
        'Bio Insecticide',
        'Bio-Pesticides'
      ],
      'Bio-Fungicide': [
        'Bio-Fungicide',
        'Bio Fungicide',
        'Biological Fungicide',
        'Bio-Fungicides'
      ],
      'Bio-Fertilizers': [
        'Bio-Fertilizer',
        'Bio Fertilizer',
        'Biological Fertilizer',
        'Bio-Fertilizers'
      ],
    };

    List<CategoriesModel> filtered = [];
    for (var title in orderedTitles) {
      CategoriesModel? found;

      List<String> aliases = titleAliases[title] ?? [title];
      for (var alias in aliases) {
        for (var cat in allCategories) {
          final catTitle = cat.title.toLowerCase().trim();
          final aliasLower = alias.toLowerCase().trim();

          if (catTitle == aliasLower || catTitle.contains(aliasLower)) {
            found = cat;
            break;
          }
        }
        if (found != null) break;
      }

      if (found != null) {
        final isSvg =
            found.image.split('?').first.toLowerCase().endsWith('.svg');
        if (isSvg) {
          filtered.add(CategoriesModel(
            id: found.id,
            title: _getLocalizedCategoryTitle(context, title),
            handle: found.handle,
            description: found.description,
            image: found.image,
          ));
        }
      }
    }

    if (mounted) {
      setState(() {
        _categories = filtered;
        _isLoadingCats = false;
      });
      // Pre-cache SVGs to disk for near-instant loading
      for (var cat in _categories) {
        if (cat.image.isNotEmpty) {
          DefaultCacheManager().downloadFile(cat.image);
        }
      }
    }
  }

  String _getLocalizedCategoryTitle(BuildContext context, String title) {
    if (!mounted) return title;
    final l10n = AppLocalizations.of(context)!;
    switch (title) {
      case 'PGRs':
        return l10n.pgr;
      case 'Insecticides':
        return l10n.insecticides;
      case 'Fungicides':
        return l10n.fungicides;
      case 'Fertilizers':
        return l10n.fertilizers;
      case 'Herbicides':
        return l10n.herbicides;
      case 'NPK Fertilizers':
        return l10n.npkFertilizer;
      case 'Bio-Pesticides':
        return l10n.bioPesticide;
      case 'Bio-Fungicide':
        return l10n.bioFungicide;
      case 'Bio-Fertilizers':
        return l10n.bioFertilizer;
      default:
        return title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allCats = Constants.homeScreenCatBanners;

    Map<String, String>? bestSeller;
    for (var cat in allCats) {
      if (cat['image']?.toLowerCase().contains('best') ?? false) {
        bestSeller = cat;
        break;
      }
    }

    Map<String, String>? badiBachat;
    for (var cat in allCats) {
      if (cat['image']?.toLowerCase().contains('bachat') ?? false) {
        badiBachat = cat;
        break;
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Black icons
        statusBarBrightness: Brightness.light, // For iOS
      ),
      child: Container(
        color: const Color(0xffF9FBF9),
        child: Stack(
          children: [
            // Header Shapes (For consistency with Categories & Orders)
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
              top: 70,
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

            RefreshIndicator(
              color: const Color(0xFF26842c),
              onRefresh: _refresh,
              child: ListView(
                controller: widget.scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(
                    top: 15), // Adjusted for non-overlapping Appbar
                children: [
                  if (_isLoadingBanners)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF26842c))),
                      ),
                    )
                  else if (_banners.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: HomeCarousel(
                        banners: _banners,
                        onBannerClick: _handleBannerClick,
                      ),
                    ),

                  const SizedBox(height: 4),
                  const SizedBox(height: 4),

                  // --- CATEGORIES SECTION ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFF26842c),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              AppLocalizations.of(context)!.categories,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingCats)
                          const SizedBox(
                            height: 120,
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF26842c))),
                          )
                        else
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              return WidgetButton(
                                onTap: () => Routers.goTO(context,
                                    toBody: CollectionView(
                                        collectionId: cat.id.toString(),
                                        title: cat.title)),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                      border:
                                          Border.all(color: Colors.grey[100]!)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: KskNetworkImage(
                                      cat.image,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --- DYNAMIC SECTIONS ---
                  if (bestSeller != null) _buildDynamicSection(bestSeller, []),

                  if (badiBachat != null)
                    _buildDynamicSection(badiBachat, _bestSellerIds),

                  for (var section in allCats)
                    if (section != bestSeller && section != badiBachat)
                      _buildDynamicSection(section, []),

                  // --- PREMIUM FOOTER ---
                  _buildPremiumFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicSection(
      Map<String, String> data, List<String> excludeIds) {
    if (data['image'] == null || data['image']!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: WidgetButton(
              onTap: () => Routers.goTO(context,
                  toBody: CollectionView(collectionId: data['id']!)),
              child: AspectRatio(
                aspectRatio: 5.0,
                child: KskNetworkImage(
                  data['image']!,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Constants.stringToColor(color: data['color'] ?? "#fff")
                .withOpacity(0.04),
          ),
          child: Column(
            children: [
              ProductsGrid(
                id: data['id']!,
                limit: 4,
                shrinkWrap: true,
                excludeIds: excludeIds,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextButton.icon(
                  onPressed: () => Routers.goTO(context,
                      toBody: CollectionView(collectionId: data['id']!)),
                  icon: Text(AppLocalizations.of(context)!.exploreMore,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                  label: const Icon(Icons.arrow_right_alt, size: 18),
                  style: TextButton.styleFrom(
                      foregroundColor: Constants.baseColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumFooter() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _trustItem(Icons.local_shipping_outlined,
                    AppLocalizations.of(context)!.freeShipping),
                _trustItem(Icons.verified_outlined,
                    AppLocalizations.of(context)!.securePay),
                _trustItem(Icons.support_agent_rounded,
                    AppLocalizations.of(context)!.agriSupport),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              children: [
                Image.asset('assets/logo.png',
                    height: 60, opacity: const AlwaysStoppedAnimation(0.6)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () =>
                      launchUrlString("https://wa.me/919399022060"),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: Text(AppLocalizations.of(context)!.whatsAppSupport),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    elevation: 0,
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "© ${DateTime.now().year} Krishi Bhandar",
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 11,
                      letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trustItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Constants.baseColor),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black54)),
      ],
    );
  }
}

class HomeCarousel extends StatefulWidget {
  final List<CategoriesModel> banners;
  final Function(CategoriesModel) onBannerClick;

  const HomeCarousel({
    super.key,
    required this.banners,
    required this.onBannerClick,
  });

  @override
  State<HomeCarousel> createState() => _HomeCarouselState();
}

class _HomeCarouselState extends State<HomeCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _carouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                aspectRatio: 2.6,
                viewportFraction: 1.0, // Full width slider
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                autoPlayCurve: Curves.easeInOutQuart,
                onPageChanged: (index, _) {
                  setState(() {
                    _carouselIndex = index;
                  });
                },
              ),
              items: widget.banners.map((banner) {
                return WidgetButton(
                  onTap: () => widget.onBannerClick(banner),
                  child: KskNetworkImage(
                    banner.image,
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                );
              }).toList(),
            ),
            // Floating Indicator Dots
            Positioned(
              bottom: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.banners.asMap().entries.map((entry) {
                  bool isActive = _carouselIndex == entry.key;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? 18.0 : 6.0,
                    height: 4.0,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              )
                            ]
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
