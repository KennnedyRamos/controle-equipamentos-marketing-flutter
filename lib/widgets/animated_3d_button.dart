import 'package:flutter/material.dart';

class Animated3DButton extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;
  final double width;
  final double height;
  final Color? color;
  final bool enabled;
  final IconData? icon;

  const Animated3DButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
    this.height = 48,
    this.color,
    this.enabled = true,
    this.icon,
  });

  @override
  State<Animated3DButton> createState() => _Animated3DButtonState();
}

class _Animated3DButtonState extends State<Animated3DButton> {
  bool _pressed = false;
  bool _loading = false;

  Future<void> _handleTap() async {
    if (!widget.enabled || _loading) return;

    setState(() => _loading = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = widget.enabled
        ? (widget.color ?? theme.colorScheme.primary)
        : Colors.grey;

    final textColor = theme.colorScheme.onPrimary;

    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.text,
      child: GestureDetector(
        onTapDown: widget.enabled && !_loading
            ? (_) => setState(() => _pressed = true)
            : null,
        onTapUp: widget.enabled && !_loading
            ? (_) {
                setState(() => _pressed = false);
                _handleTap();
              }
            : null,
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.width,
          height: widget.height,
          transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _pressed || !widget.enabled
                ? []
                : [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.6)
                          : Colors.black26,
                      offset: const Offset(0, 6),
                      blurRadius: 10,
                    ),
                  ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: textColor),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
