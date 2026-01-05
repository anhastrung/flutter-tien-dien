import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../pages/home_page.dart';
import '../pages/input_page.dart';
import '../pages/room_page.dart';
import '../pages/electric_price_page.dart';
import '../pages/login_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    const headerBg = Colors.white;
    const headerText = Color(0xFF222222);
    const iconColor = Color(0xFF222222);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Dart
          DrawerHeader(
            decoration: const BoxDecoration(color: headerBg),
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Tính tiền điện',
                style: const TextStyle(
                  color: headerText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListTileTheme(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              iconColor: iconColor,
              textColor: iconColor,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _menuItem(
                    context,
                    icon: Icons.home,
                    title: 'Trang chủ',
                    onTap: () => _go(context, const HomePage()),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.calculate,
                    title: 'Tính tiền điện',
                    onTap: () => _go(context, const InputPage()),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.home_work,
                    title: 'Quản lý phòng',
                    onTap: () => _go(context, const RoomPage()),
                  ),
                  _menuItem(
                    context,
                    icon: Icons.flash_on,
                    title: 'Giá điện',
                    onTap: () => _go(context, const ElectricPricePage()),
                  ),
                  const Divider(height: 32, color: Color(0xFFE0E0E0)),
                  _menuItem(
                    context,
                    icon: Icons.logout,
                    title: 'Đăng xuất',
                    isDanger: true,
                    onTap: () {
                      auth.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (_) => false,
                      );
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

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    const iconColor = Color(0xFF222222);
    const dangerColor = Colors.red;
    const hoverColor = Color(0xFFF5F5F5);

    final color = isDanger ? dangerColor : iconColor;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: isDanger ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 12,
      hoverColor: hoverColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
