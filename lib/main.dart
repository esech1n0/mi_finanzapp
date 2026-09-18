import 'package:flutter/material.dart';
import 'screens/principal_screen.dart';

void main() {
  runApp(const MiFinanzappApp());
}

class MiFinanzappApp extends StatelessWidget {
  const MiFinanzappApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiFinanzapp',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF120E1C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9D65FF),
          onPrimary: Colors.white,
          secondary: Color(0xFF7C4DFF),
          surface: Color(0xFF1D172E),
          onSurface: Color(0xFFEAE6F5),
          error: Color(0xFFEF5350),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1D172E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2E2448), width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF120E1C),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFFF3EFFF),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
          iconTheme: IconThemeData(color: Color(0xFFEAE6F5)),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF1D172E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF1D172E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          contentTextStyle: const TextStyle(
            color: Color(0xFFB8B1CC),
            fontSize: 14,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFF2E2448),
          thickness: 1,
        ),
      ),
      home: const PrincipalScreen(),
    );
  }
}
