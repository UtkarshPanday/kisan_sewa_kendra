import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kisan_sewa_kendra/components/cart_icon.dart';
import 'package:kisan_sewa_kendra/components/products_grid.dart';
import 'package:kisan_sewa_kendra/controller/constants.dart';
import 'package:kisan_sewa_kendra/l10n/app_localizations.dart';

class SearchResultsView extends StatelessWidget {
  final String query;
  final String title;

  const SearchResultsView({
    super.key,
    required this.query,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xffF9FBF9),
      body: Stack(
        children: [
          // Background Shapes
          Positioned(
            top: -50,
            right: -30,
            child: _buildShape(200, 0.04),
          ),
          Positioned(
            top: 220,
            left: -40,
            child: _buildShape(120, 0.03),
          ),

          // Products Grid
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(top: topPad + 80),
              child: ProductsGrid(
                query: query,
                isFilter: true,
                shrinkWrap: false,
              ),
            ),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context, topPad),
          ),
        ],
      ),
    );
  }

  Widget _buildShape(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Constants.baseColor.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPad) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPad + 10, 16, 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded, size: 20),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Constants.baseColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppLocalizations.of(context)!.pureSelection,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const KskCartIcon(showBackground: true),
        ],
      ),
    );
  }
}
