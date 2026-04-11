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
  Future<File>? _svgFuture;
  String? _lastUrl;

  @override
  void initState() {
    super.initState();
    _initSvgFuture();
  }

  void _initSvgFuture() {
    final cleanUrl = widget.imageUrl.trim();
    final isSvg = cleanUrl.split('?').first.toLowerCase().endsWith('.svg');
    if (isSvg && cleanUrl.startsWith("http")) {
      _svgFuture = DefaultCacheManager().getSingleFile(cleanUrl);
      _lastUrl = cleanUrl;
    } else {
      _svgFuture = null;
      _lastUrl = null;
    }
  }

  @override
  void didUpdateWidget(KskNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _initSvgFuture();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = widget.imageUrl.trim();
    if (cleanUrl.isEmpty || !cleanUrl.startsWith("http")) {
      return _buildPlaceholder();
    }

    if (_svgFuture != null) {
      return FutureBuilder<File>(
        future: _svgFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return SvgPicture.file(
              snapshot.data!,
              height: widget.height,
              width: widget.width,
              fit: widget.fit ?? BoxFit.contain,
            );
          }
          if (snapshot.hasError) {
            return _buildPlaceholder();
          }
          return _buildShimmer();
        },
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
          height: widget.height != null ? widget.height! * 0.4 : 40,
          width: widget.width != null ? widget.width! * 0.4 : 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
