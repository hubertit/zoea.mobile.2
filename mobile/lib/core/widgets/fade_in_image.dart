import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' as ui;

/// A widget that displays a network image with a skeleton/placeholder that fades in
/// and smoothly transitions to the actual image
class FadeInNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Color? placeholderColor;
  final Duration fadeInDuration;

  const FadeInNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.placeholderColor,
    this.fadeInDuration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    final placeholderColor = this.placeholderColor ?? Colors.grey[200]!;
    
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholder: (context, url) => _SkeletonPlaceholder(
        width: width,
        height: height,
        color: placeholderColor,
      ),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
    );

    // Always clip to prevent overflow, even without borderRadius
    imageWidget = ClipRect(
      child: imageWidget,
    );

    // Wrap in constraints to prevent overflow when dimensions are provided
    if (width != null || height != null) {
      imageWidget = SizedBox(
        width: width,
        height: height,
        child: imageWidget,
      );
    }

    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        clipBehavior: Clip.antiAlias,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey[400],
        size: height != null && height! < 100 ? 30 : 50,
      ),
    );
  }
}

/// Shimmer skeleton placeholder that fades in
class _SkeletonPlaceholder extends StatefulWidget {
  final double? width;
  final double? height;
  final Color color;

  const _SkeletonPlaceholder({
    this.width,
    this.height,
    required this.color,
  });

  @override
  State<_SkeletonPlaceholder> createState() => _SkeletonPlaceholderState();
}

class _SkeletonPlaceholderState extends State<_SkeletonPlaceholder>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
    
    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Container(
          color: widget.color,
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ShimmerPainter(
                  progress: _shimmerController.value,
                  baseColor: widget.color,
                  highlightColor: Colors.grey[100]!,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color highlightColor;

  _ShimmerPainter({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(-size.width * 0.5 + size.width * progress * 2, 0),
        Offset(size.width * 0.5 + size.width * progress * 2, size.height),
        [
          baseColor,
          highlightColor,
          baseColor,
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

