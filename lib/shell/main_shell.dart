import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:apdeteksi/core/theme/app_colors.dart';
import 'package:apdeteksi/deteksi/deteksi_page.dart';
import 'package:apdeteksi/history/presentation/history_page.dart';
import 'package:apdeteksi/home/home_page.dart';
import 'package:apdeteksi/laporan/presentation/report_page.dart';
import 'package:apdeteksi/statistik/presentation/statistics_page.dart';
import 'nav_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const _tabs = [
    _TabItem('Beranda', Icons.home_outlined),
    _TabItem('Deteksi', Icons.center_focus_strong_outlined),
    _TabItem('Riwayat', Icons.access_time),
    _TabItem('Statistik', Icons.bar_chart),
    _TabItem('Laporan', Icons.description_outlined),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);

    final pages = <Widget>[
      const HomePage(),
      DeteksiPage(isActive: index == 1),
      const HistoryPage(),
      const StatisticsPage(),
      const ReportPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < _tabs.length; i++)
                Expanded(
                  child: _NavButton(
                    item: _tabs[i],
                    selected: i == index,
                    onTap: () => ref.read(navIndexProvider.notifier).select(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  const _TabItem(this.label, this.icon);
}

class _NavButton extends StatelessWidget {
  final _TabItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navy : Colors.white;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.yellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
