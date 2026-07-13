import 'package:flutter/material.dart';
import 'package:haqvox/app/constant/constant.dart';


class MySpaceTabBar extends StatelessWidget {
  final TabController controller;

  const MySpaceTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        isScrollable: true,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        tabs: [
          _buildTab(Icons.bookmark, 'Bookmarks'),
          _buildTab(Icons.download, 'Downloads'),
          _buildTab(Icons.history, 'History'),
        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Tab(
      height: 45,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        constraints: const BoxConstraints(minWidth: 90),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
