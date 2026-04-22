import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';
import '../generated/assets.dart';

class KskNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width, height;
  final BoxFit? fit;

  const KskNetworkImage(
    this.imageUrl, {
    super.key,
    this.width,
    this.height,
    this.fit,
  });

  @override
  State<KskNetworkImage> createState() => _KskNetworkImageState();
}

class _KskNetworkImageState extends State<KskNetworkImage> {
  @override
  Widget build(BuildContext context) {
    final cleanUrl = widget.imageUrl.trim();
    if (cleanUrl.isEmpty || !cleanUrl.startsWith("http")) {
      return _buildPlaceholder();
    }

    final isSvg = cleanUrl.split('?').first.toLowerCase().endsWith('.svg');

    if (isSvg) {
      return SvgPicture.network(
        cleanUrl,
        height: widget.height,
        width: widget.width,
        fit: widget.fit ?? BoxFit.contain,
        placeholderBuilder: (BuildContext context) => _buildShimmer(),
      );
    }

    return CachedNetworkImage(
      imageUrl: cleanUrl,
      height: widget.height,
      width: widget.width,
      fit: widget.fit ?? BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => _buildShimmer(),
      errorWidget: (context, url, error) => _buildPlaceholder(),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.grey[50],
      alignment: Alignment.center,
      child: Opacity(
        opacity: 0.2,
        child: Image.asset(
          Assets.assetsLogo,
          height: (widget.height != null && widget.height != double.infinity)
              ? widget.height! * 0.4
              : 40,
          width: (widget.width != null && widget.width != double.infinity)
              ? widget.width! * 0.4
              : 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
