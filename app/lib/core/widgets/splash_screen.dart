import 'dart:math';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function() loadDependencies;
  final Widget child;

  const SplashScreen({
    super.key,
    required this.loadDependencies,
    required this.child,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _loadApp();
  }

  Future<void> _loadApp() async {
    await widget.loadDependencies();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading) {
      return widget.child;
    }

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.teal.shade50,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: PawPrintsPainter(progress: _animation.value),
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'PetKeeper Lite',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Carregando...',
                style: TextStyle(fontSize: 16, color: Colors.teal.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PawPrintsPainter extends CustomPainter {
  final double progress;

  PawPrintsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Posições das patinhas em sequência (caminhada diagonal)
    final pawPositions = [
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.3, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.7, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.3),
    ];

    for (int i = 0; i < pawPositions.length; i++) {
      // Calcula a opacidade baseada no progresso da animação
      final pawProgress = (progress * pawPositions.length - i).clamp(0.0, 1.0);
      final opacity = _calculateOpacity(pawProgress, i, pawPositions.length);

      _drawPawPrint(
        canvas,
        pawPositions[i],
        20,
        opacity,
        isLeftPaw: i % 2 == 0,
      );
    }
  }

  double _calculateOpacity(double pawProgress, int index, int total) {
    // Cria um efeito de "onda" onde as patinhas aparecem e desaparecem
    final cyclePosition = (progress * 2 + index / total) % 1.0;
    return (sin(cyclePosition * pi) * 0.7 + 0.3).clamp(0.3, 1.0);
  }

  void _drawPawPrint(
    Canvas canvas,
    Offset center,
    double size,
    double opacity, {
    bool isLeftPaw = true,
  }) {
    final paint = Paint()
      ..color = Colors.teal.withAlpha((opacity * 255).toInt())
      ..style = PaintingStyle.fill;

    // Rotação para patas esquerda/direita
    final rotation = isLeftPaw ? -0.2 : 0.2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Almofada principal (oval grande)
    final mainPadRect = Rect.fromCenter(
      center: Offset(0, size * 0.3),
      width: size * 0.8,
      height: size * 0.6,
    );
    canvas.drawOval(mainPadRect, paint);

    // Dedos (4 círculos pequenos)
    final toePositions = [
      Offset(-size * 0.3, -size * 0.2),
      Offset(-size * 0.1, -size * 0.4),
      Offset(size * 0.1, -size * 0.4),
      Offset(size * 0.3, -size * 0.2),
    ];

    for (final toePos in toePositions) {
      canvas.drawCircle(toePos, size * 0.15, paint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(PawPrintsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
