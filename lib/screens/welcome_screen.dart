import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/app_localizations.dart';
import '../core/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'create_account_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldBody(
      child: Column(
        children: [
          const LanguageButton(),
          const Expanded(
            flex: 11,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: _WelcomeIllustration(),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                boxShadow: [
                  BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -8)),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    context.l10n.text('welcomeTitle'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.text('welcomeSubtitle'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textMuted,
                          height: 1.45,
                        ),
                  ),
                  const Spacer(),
                  AppPrimaryButton(
                    label: context.l10n.text('login'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                  ),
                  const SizedBox(height: 12),
                  AppOutlinedButton(
                    label: context.l10n.text('createAccount'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateAccountScreen()));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPatternPainter(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: height * 0.10,
                child: Container(
                  width: width * 0.74,
                  height: height * 0.56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFFFF1C9), Color(0xFFF3C861)],
                    ),
                    borderRadius: BorderRadius.circular(160),
                    boxShadow: const [
                      BoxShadow(color: Color(0x22F0B54A), blurRadius: 28, offset: Offset(0, 12)),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: height * 0.14,
                child: SizedBox(
                  width: width * 0.82,
                  height: height * 0.60,
                  child: const _LandmarkCollage(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LandmarkCollage extends StatelessWidget {
  const _LandmarkCollage();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: const [
        Positioned(left: 0, right: 0, bottom: 26, child: _Ground()),
        Positioned(left: 28, bottom: 104, child: _PillarGroup()),
        Positioned(left: 80, bottom: 140, child: _TwinTowers()),
        Positioned(left: 142, bottom: 142, child: _ClockTower()),
        Positioned(right: 48, bottom: 132, child: _Pyramids()),
        Positioned(right: 6, bottom: 98, child: _Mosque()),
        Positioned(left: 22, bottom: 60, child: _Domes()),
        Positioned(left: 104, bottom: 18, child: _StudentFigure()),
      ],
    );
  }
}

class _Ground extends StatelessWidget {
  const _Ground();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFDC8D33), Color(0xFFF0C06A)]),
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}

class _PillarGroup extends StatelessWidget {
  const _PillarGroup();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 90,
      child: Stack(
        children: List.generate(4, (index) {
          return Positioned(
            left: index * 14,
            bottom: 0,
            child: Container(
              width: 10,
              height: 70 - (index % 2) * 8,
              decoration: BoxDecoration(color: const Color(0xFFC46B1F), borderRadius: BorderRadius.circular(4)),
            ),
          );
        })
          ..add(
            Positioned(
              left: 0,
              right: 0,
              top: 8,
              child: Container(height: 10, color: const Color(0xFFE8AC49)),
            ),
          ),
      ),
    );
  }
}

class _TwinTowers extends StatelessWidget {
  const _TwinTowers();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _tower(const Color(0xFF174A7C), 46, 98),
        const SizedBox(width: 10),
        _tower(const Color(0xFF2F6CA0), 58, 122),
      ],
    );
  }

  Widget _tower(Color color, double width, double height) {
    return ClipPath(
      clipper: _TriangleClipper(),
      child: Container(width: width, height: height, color: color),
    );
  }
}

class _ClockTower extends StatelessWidget {
  const _ClockTower();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 150,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 30,
            height: 128,
            decoration: BoxDecoration(color: const Color(0xFFB26B17), borderRadius: BorderRadius.circular(8)),
          ),
          Positioned(
            top: 18,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(color: Color(0xFFF7D373), shape: BoxShape.circle),
            ),
          ),
          const Positioned(top: 0, child: Icon(Icons.keyboard_arrow_up, color: Color(0xFFB26B17), size: 32)),
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
        _pyramid(70, const Color(0xFFE3B247)),
        Transform.translate(offset: const Offset(-12, 0), child: _pyramid(90, const Color(0xFFE6BE63))),
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
      width: 112,
      height: 120,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: 112,
              height: 44,
              decoration: BoxDecoration(color: const Color(0xFFD9A355), borderRadius: BorderRadius.circular(12)),
            ),
          ),
          Positioned(
            bottom: 32,
            child: Container(
              width: 50,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFE4B94F),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 30,
            child: Container(
              width: 18,
              height: 72,
              decoration: BoxDecoration(color: const Color(0xFFD49844), borderRadius: BorderRadius.circular(8)),
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
        _dome(const Color(0xFF3A93A7)),
        Transform.translate(offset: const Offset(-12, 0), child: _dome(const Color(0xFF66B8C7))),
      ],
    );
  }

  Widget _dome(Color color) {
    return Container(
      width: 34,
      height: 24,
      decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
    );
  }
}

class _StudentFigure extends StatelessWidget {
  const _StudentFigure();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 170,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Positioned(top: 0, child: Icon(Icons.school, size: 34, color: Color(0xFF3A241B))),
          Positioned(
            top: 24,
            child: Container(
              width: 46,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFE58B26),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA65913), width: 2),
              ),
            ),
          ),
          const Positioned(top: 82, child: SizedBox(width: 18, height: 44, child: ColoredBox(color: Color(0xFF4B6E9A)))),
          Positioned(
            left: 24,
            top: 82,
            child: Transform.rotate(
              angle: 0.35,
              child: const SizedBox(width: 10, height: 48, child: ColoredBox(color: Color(0xFF4B6E9A))),
            ),
          ),
          Positioned(
            right: 24,
            top: 82,
            child: Transform.rotate(
              angle: -0.35,
              child: const SizedBox(width: 10, height: 48, child: ColoredBox(color: Color(0xFF4B6E9A))),
            ),
          ),
          Positioned(
            left: 30,
            bottom: 12,
            child: Transform.rotate(
              angle: 0.18,
              child: const SizedBox(width: 10, height: 56, child: ColoredBox(color: Color(0xFF2F3A56))),
            ),
          ),
          Positioned(
            right: 30,
            bottom: 12,
            child: Transform.rotate(
              angle: -0.18,
              child: const SizedBox(width: 10, height: 56, child: ColoredBox(color: Color(0xFF2F3A56))),
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
      ..color = const Color(0xFFF3DFCC)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    void drawBulb(Offset center) {
      canvas.drawCircle(center, 16, paint);
      canvas.drawLine(Offset(center.dx - 6, center.dy + 16), Offset(center.dx + 6, center.dy + 16), paint);
      canvas.drawLine(Offset(center.dx, center.dy + 16), Offset(center.dx, center.dy + 26), paint);
    }

    void drawStar(Offset center) {
      final path = Path();
      for (var i = 0; i < 5; i++) {
        final outerAngle = (-90 + i * 72) * 3.14159 / 180;
        final innerAngle = (-54 + i * 72) * 3.14159 / 180;
        final outer = Offset(center.dx + 10 * math.cos(outerAngle), center.dy + 10 * math.sin(outerAngle));
        final inner = Offset(center.dx + 4 * math.cos(innerAngle), center.dy + 4 * math.sin(innerAngle));
        if (i == 0) {
          path.moveTo(outer.dx, outer.dy);
        } else {
          path.lineTo(outer.dx, outer.dy);
        }
        path.lineTo(inner.dx, inner.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }

    void drawPlane(Offset center) {
      final path = Path()
        ..moveTo(center.dx - 14, center.dy + 2)
        ..lineTo(center.dx + 16, center.dy)
        ..lineTo(center.dx - 4, center.dy - 8)
        ..lineTo(center.dx - 2, center.dy)
        ..close();
      canvas.drawPath(path, paint);
    }

    final offsets = <Offset>[
      const Offset(28, 40),
      Offset(size.width * 0.18, 92),
      Offset(size.width * 0.76, 50),
      Offset(size.width - 34, 118),
      Offset(size.width * 0.12, size.height * 0.76),
      Offset(size.width * 0.82, size.height * 0.72),
      Offset(size.width * 0.48, size.height * 0.08),
      Offset(size.width * 0.58, size.height * 0.86),
    ];

    drawStar(Offset(size.width * 0.08, size.height * 0.24));
    drawStar(Offset(size.width * 0.9, size.height * 0.9));

    for (var i = 0; i < offsets.length; i++) {
      if (i % 3 == 0) {
        drawBulb(offsets[i]);
      } else if (i % 3 == 1) {
        drawPlane(offsets[i]);
      } else {
        canvas.drawCircle(offsets[i], 12, paint);
      }
    }

    canvas.drawLine(Offset(size.width * 0.14, 146), Offset(size.width * 0.22, 178), paint);
    canvas.drawLine(Offset(size.width * 0.82, 160), Offset(size.width * 0.9, 130), paint);
    canvas.drawLine(Offset(size.width * 0.2, size.height * 0.92), Offset(size.width * 0.28, size.height * 0.96), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
