import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'historial_screen.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});

  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _indiceActual = 0;

  final GlobalKey<State<HomeScreen>> _homeKey = GlobalKey<State<HomeScreen>>();
  final GlobalKey<State<HistorialScreen>> _historialKey =
      GlobalKey<State<HistorialScreen>>();

  @override
  Widget build(BuildContext context) {
    final paginas = [
      HomeScreen(key: _homeKey),
      HistorialScreen(key: _historialKey),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _indiceActual,
        children: paginas,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF2E2448), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _indiceActual,
          onTap: (index) {
            setState(() => _indiceActual = index);
          },
          backgroundColor: const Color(0xFF140F21),
          selectedItemColor: const Color(0xFF9D65FF),
          unselectedItemColor: const Color(0xFF8E83A8),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Historial',
            ),
          ],
        ),
      ),
    );
  }
}
