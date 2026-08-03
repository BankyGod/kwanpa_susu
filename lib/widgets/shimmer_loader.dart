import 'package:flutter/material.dart';

class ShimmerLoader extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoader({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double width = bounds.width;
            final double dx = width * _shimmerController.value * 2 - width;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFF4F4FD),
                Color(0xFFEBEBF4),
              ],
              stops: const [0.1, 0.5, 0.9],
              transform: _SlidingGradientTransform(slidePercent: _shimmerController.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent * 2 - bounds.width, 0, 0);
  }
}

class ShimmerCardPlaceholder extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerCardPlaceholder({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAE9),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
