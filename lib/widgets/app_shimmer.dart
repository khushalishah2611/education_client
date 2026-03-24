import 'package:flutter/material.dart';

class AppShimmerBox extends StatefulWidget {
  const AppShimmerBox({
    super.key,
    this.height,
    this.width = double.infinity,
    this.borderRadius,
    this.baseColor = const Color(0xFFECE7DE),
    this.highlightColor = const Color(0xFFF9F7F3),
  });

  final double? height;
  final double width;
  final BorderRadius? borderRadius;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<AppShimmerBox> createState() => _AppShimmerBoxState();
}

class _AppShimmerBoxState extends State<AppShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final shimmerPosition = (_controller.value * 2) - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + shimmerPosition, -0.3),
              end: Alignment(1.5 + shimmerPosition, 0.3),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
        );
      },
    );
  }
}

class UniversityCardSkeleton extends StatelessWidget {
  const UniversityCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E3DB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppShimmerBox(
                height: 96,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 10),
              AppShimmerBox(
                height: 14,
                width: double.infinity,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 6),
              AppShimmerBox(
                height: 12,
                width: 90,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          AppShimmerBox(
            height: 40,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}
