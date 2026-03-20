import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDE3CF), Color(0xFFFFFBF7), Color(0xFFFCE1CB)],
          stops: [0, .42, 1],
        ),
      ),
      child: child,
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.center = false, this.compact = false});

  final bool center;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final arabicStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppColors.logo,
          height: .84,
          fontSize: compact ? 20 : 34,
        );
    final englishStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
          height: 1,
          fontSize: compact ? 8 : 14,
        );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          'جامعات\nالعرب',
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: arabicStyle,
        ),
        SizedBox(height: compact ? 4 : 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: compact ? 16 : 34, height: 2, color: AppColors.accent),
            SizedBox(width: compact ? 4 : 8),
            Text('ARAB\nUNIVERSITIES', style: englishStyle),
          ],
        ),
      ],
    );

    return center ? Center(child: content) : content;
  }
}

class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topEnd,
      child: TextButton.icon(
        onPressed: context.toggleLanguage,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.logo,
          backgroundColor: Colors.white.withOpacity(.92),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.language),
        label: Text(context.l10n.text('langLabel')),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.text,
          disabledBackgroundColor: AppColors.primary.withOpacity(.7),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.text),
              )
            : Text(label),
      ),
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          side: const BorderSide(color: Color(0xFFF1C7A2)),
          backgroundColor: const Color(0xFFFFFCF8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.icon,
    this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null ? null : Icon(icon, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class AppDropdownField extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.text)),
        const SizedBox(height: 10),
        InputDecorator(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textMuted),
            suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
          ),
          child: Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted)),
        ),
      ],
    );
  }
}

class AppTextLink extends StatelessWidget {
  const AppTextLink({
    super.key,
    required this.prefix,
    required this.link,
    this.onTap,
  });

  final String prefix;
  final String link;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        Text(prefix, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            link,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

class AppScaffoldBody extends StatelessWidget {
  const AppScaffoldBody({super.key, required this.child, this.horizontalPadding = 20, this.topPadding = 12});

  final Widget child;
  final double horizontalPadding;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: context.l10n.textDirection,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, topPadding, horizontalPadding, 20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class HeroIllustration extends StatelessWidget {
  const HeroIllustration({super.key, this.height = 320, this.showPattern = true});

  final double height;
  final bool showPattern;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: const [
          Positioned.fill(child: _SkyGlow()),
          Positioned.fill(child: _LinePattern()),
          Positioned.fill(child: _LandmarkScene()),
        ],
      ),
    );

    if (!showPattern) {
      return SizedBox(
        height: height,
        child: const _LandmarkScene(),
      );
    }

    return content;
  }
}

class _SkyGlow extends StatelessWidget {
  const _SkyGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -.3),
            radius: .9,
            colors: [Colors.white, const Color(0xFFFFF6D9).withOpacity(.9), Colors.transparent],
          ),
        ),
      ),
    );
  }
}

class _LinePattern extends StatelessWidget {
  const _LinePattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackgroundPatternPainter());
  }
}

class _LandmarkScene extends StatelessWidget {
  const _LandmarkScene();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: const [
        Positioned(bottom: 16, left: 32, right: 32, child: _GroundShape()),
        Positioned(bottom: 46, left: 12, child: _Domes()),
        Positioned(bottom: 64, left: 54, child: _Ruins()),
        Positioned(bottom: 88, left: 108, child: _KuwaitTowers()),
        Positioned(bottom: 102, left: 160, child: _ClockTower()),
        Positioned(bottom: 92, right: 92, child: _Pyramids()),
        Positioned(bottom: 72, right: 18, child: _Mosque()),
        Positioned(bottom: 10, child: _StudentFigure()),
      ],
    );
  }
}

class _GroundShape extends StatelessWidget {
  const _GroundShape();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE4A248), Color(0xFFF1C76E)]),
        borderRadius: BorderRadius.circular(120),
      ),
    );
  }
}

class _Ruins extends StatelessWidget {
  const _Ruins();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: 88,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 84,
              height: 26,
              decoration: BoxDecoration(color: const Color(0xFFC06B25), borderRadius: BorderRadius.circular(6)),
            ),
          ),
          ...List.generate(
            4,
            (index) => Positioned(
              left: 10 + (index * 17),
              bottom: 18,
              child: Container(
                width: 10,
                height: 44,
                decoration: BoxDecoration(color: const Color(0xFFD18135), borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KuwaitTowers extends StatelessWidget {
  const _KuwaitTowers();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 112,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(left: 6, bottom: 0, child: _tower(14, 78, const Color(0xFF164A7A), 12)),
          Positioned(right: 4, bottom: 0, child: _tower(18, 98, const Color(0xFF2F6EA2), 16)),
          Positioned(left: 2, top: 32, child: _sphere(18)),
          Positioned(right: 6, top: 20, child: _sphere(22)),
        ],
      ),
    );
  }

  Widget _tower(double width, double height, Color color, double radius) {
    return ClipPath(
      clipper: _TriangleClipper(),
      child: Container(width: width, height: height, color: color),
    );
  }

  Widget _sphere(double size) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(color: Color(0xFF8D6D52), shape: BoxShape.circle),
      );
}

class _ClockTower extends StatelessWidget {
  const _ClockTower();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 148,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 36,
            height: 122,
            decoration: BoxDecoration(color: const Color(0xFFB66C18), borderRadius: BorderRadius.circular(8)),
          ),
          Positioned(
            top: 18,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(color: Color(0xFFF7D67B), shape: BoxShape.circle),
            ),
          ),
          const Positioned(top: 0, child: Icon(Icons.keyboard_arrow_up, size: 36, color: Color(0xFFB66C18))),
        ],
      ),
    );
  }
}

class _Pyramids extends StatelessWidget {
  const _Pyramids();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _pyramid(68, const Color(0xFFE2B04B)),
        Transform.translate(
          offset: const Offset(-10, 0),
          child: _pyramid(88, const Color(0xFFE8C065)),
        ),
      ],
    );
  }

  Widget _pyramid(double size, Color color) {
    return ClipPath(
      clipper: _TriangleClipper(),
      child: Container(width: size, height: size, color: color),
    );
  }
}

class _Mosque extends StatelessWidget {
  const _Mosque();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 128,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 116,
              height: 38,
              decoration: BoxDecoration(color: const Color(0xFFD8A255), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Positioned(
            bottom: 24,
            child: Container(
              width: 56,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFE6BA53),
                borderRadius: BorderRadius.vertical(top: Radius.circular(44)),
              ),
            ),
          ),
          Positioned(
            left: 8,
            bottom: 24,
            child: Container(
              width: 18,
              height: 70,
              decoration: BoxDecoration(color: const Color(0xFFDAA05A), borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 22,
            child: Container(
              width: 18,
              height: 80,
              decoration: BoxDecoration(color: const Color(0xFFD39342), borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Domes extends StatelessWidget {
  const _Domes();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dome(const Color(0xFF2B9DB1), 42),
        Transform.translate(offset: const Offset(-12, 8), child: _dome(const Color(0xFF5FC1CC), 52)),
      ],
    );
  }

  Widget _dome(Color color, double width) {
    return Container(
      width: width,
      height: width * .62,
      decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
    );
  }
}

class _StudentFigure extends StatelessWidget {
  const _StudentFigure();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 182,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Positioned(top: 0, child: Icon(Icons.school, size: 36, color: Color(0xFF3B241B))),
          Positioned(
            top: 28,
            child: Container(
              width: 50,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFE68D29),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF9D5A1A), width: 2),
              ),
            ),
          ),
          const Positioned(top: 22, child: CircleAvatar(radius: 10, backgroundColor: Color(0xFFB77344))),
          Positioned(
            top: 92,
            left: 26,
            child: Transform.rotate(
              angle: .28,
              child: const SizedBox(width: 12, height: 50, child: ColoredBox(color: Color(0xFF6A89AE))),
            ),
          ),
          Positioned(
            top: 92,
            right: 26,
            child: Transform.rotate(
              angle: -.28,
              child: const SizedBox(width: 12, height: 50, child: ColoredBox(color: Color(0xFF6A89AE))),
            ),
          ),
          const Positioned(top: 88, child: SizedBox(width: 20, height: 54, child: ColoredBox(color: Color(0xFF5C7C9D)))),
          Positioned(
            bottom: 16,
            left: 34,
            child: Transform.rotate(
              angle: .18,
              child: const SizedBox(width: 12, height: 62, child: ColoredBox(color: Color(0xFF2E3E5B))),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 34,
            child: Transform.rotate(
              angle: -.18,
              child: const SizedBox(width: 12, height: 62, child: ColoredBox(color: Color(0xFF2E3E5B))),
            ),
          ),
        ],
      ),
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEEDFD1)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    void drawBulb(Offset center) {
      canvas.drawCircle(center, 15, paint);
      canvas.drawLine(Offset(center.dx - 4, center.dy + 16), Offset(center.dx + 4, center.dy + 16), paint);
      canvas.drawLine(Offset(center.dx, center.dy + 16), Offset(center.dx, center.dy + 24), paint);
    }

    void drawMusic(Offset center) {
      canvas.drawLine(Offset(center.dx, center.dy - 12), Offset(center.dx, center.dy + 8), paint);
      canvas.drawLine(Offset(center.dx + 12, center.dy - 8), Offset(center.dx + 12, center.dy + 12), paint);
      canvas.drawLine(Offset(center.dx, center.dy - 12), Offset(center.dx + 12, center.dy - 8), paint);
      canvas.drawCircle(Offset(center.dx - 4, center.dy + 10), 4, paint);
      canvas.drawCircle(Offset(center.dx + 8, center.dy + 14), 4, paint);
    }

    void drawHeart(Offset center) {
      final path = Path()
        ..moveTo(center.dx, center.dy + 8)
        ..cubicTo(center.dx - 18, center.dy - 8, center.dx - 8, center.dy - 22, center.dx, center.dy - 12)
        ..cubicTo(center.dx + 8, center.dy - 22, center.dx + 18, center.dy - 8, center.dx, center.dy + 8);
      canvas.drawPath(path, paint);
    }

    void drawPlane(Offset center) {
      final path = Path()
        ..moveTo(center.dx - 16, center.dy + 4)
        ..lineTo(center.dx + 14, center.dy)
        ..lineTo(center.dx - 2, center.dy - 8)
        ..lineTo(center.dx - 2, center.dy - 2)
        ..close();
      canvas.drawPath(path, paint);
    }

    final shapes = <void Function(Offset)>[drawBulb, drawMusic, drawHeart, drawPlane];
    final points = <Offset>[
      const Offset(22, 46),
      Offset(size.width * .10, 162),
      Offset(size.width * .23, 56),
      Offset(size.width * .34, 118),
      Offset(size.width * .54, 26),
      Offset(size.width * .76, 72),
      Offset(size.width * .88, 156),
      Offset(size.width * .18, size.height * .82),
      Offset(size.width * .44, size.height * .90),
      Offset(size.width * .82, size.height * .84),
    ];

    for (var i = 0; i < points.length; i++) {
      shapes[i % shapes.length](points[i]);
    }

    for (var i = 0; i < 6; i++) {
      final dx = size.width * (0.1 + (i * 0.14));
      final dy = size.height * (0.28 + ((i % 2) * 0.2));
      canvas.drawCircle(Offset(dx, dy), 18, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text),
    );
  }
}

class FakeStatusBar extends StatelessWidget {
  const FakeStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text('9:41', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Spacer(),
          Icon(Icons.signal_cellular_alt, size: 18),
          SizedBox(width: 6),
          Icon(Icons.wifi, size: 18),
          SizedBox(width: 6),
          Icon(Icons.battery_full, size: 18),
        ],
      ),
    );
  }
}
