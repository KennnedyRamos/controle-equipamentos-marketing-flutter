import 'package:estoque_vendas/widgets/animated_3d_button.dart';
import 'package:flutter/material.dart';
import 'equipamentos_screen.dart';
import 'materiais_marketing_screen.dart';
import '../theme/theme_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _irParaEquipamentos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EquipamentosScreen(),
      ),
    );
  }

  Future<void> _irParaMarketing() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MateriaisMarketingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Estoque'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Alterar tema',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  RotationTransition(turns: anim, child: child),
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                key: ValueKey(isDark),
              ),
            ),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Animated3DButton(
                  text: 'Equipamentos',
                  width: screenWidth * 0.6,
                  onPressed: _irParaEquipamentos,
                ),
                const SizedBox(height: 40),
                Animated3DButton(
                  text: 'Material de Marketing',
                  width: screenWidth * 0.6,
                  color: Colors.blue,
                  onPressed: _irParaMarketing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
