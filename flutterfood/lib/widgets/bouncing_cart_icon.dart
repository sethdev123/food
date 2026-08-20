import 'package:flutter/material.dart';

class BouncingCartIcon extends StatefulWidget {
  final int count;
  final IconData icon;

  const BouncingCartIcon({
    super.key,
    required this.count,
    this.icon = Icons.shopping_cart,
  });

  @override
  State<BouncingCartIcon> createState() => _BouncingCartIconState();
}

class _BouncingCartIconState extends State<BouncingCartIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 0.9).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant BouncingCartIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(widget.icon),
          if (widget.count > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  '${widget.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
