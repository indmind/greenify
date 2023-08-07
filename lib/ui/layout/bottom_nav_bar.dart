import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenify/states/bottom_nav_bar_state.dart';
import 'package:greenify/states/home_state.dart';
import 'package:greenify/states/users_state.dart';
import 'package:ionicons/ionicons.dart';

class GrBottomNavBar extends ConsumerWidget {
  const GrBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int bottomNavIndex = ref.watch(bottomNavProvider);

    return Card(
      margin: const EdgeInsets.only(top: 1, right: 4, left: 4),
      elevation: 4,
      shadowColor: Theme.of(context).colorScheme.shadow,
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: bottomNavIndex,
        onTap: (int index) => changeIndex(index, ref),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).textTheme.bodySmall!.color,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Ionicons.book_outline),
            activeIcon: Icon(Ionicons.book),
            label: "Artikel",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Ionicons.leaf_outline),
            activeIcon: Icon(Ionicons.leaf),
            label: "Garden",
          ),
          bottomNavIndex == 3
              ? const BottomNavigationBarItem(
                  icon: Icon(
                    Ionicons.home_outline,
                  ),
                  label: "home")
              : const BottomNavigationBarItem(
                  icon: Icon(CupertinoIcons.wind, color: Colors.transparent),
                  label: ""),
          const BottomNavigationBarItem(
            icon: Icon(Ionicons.heart_outline),
            activeIcon: Icon(Ionicons.heart),
            label: "Detektor",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Ionicons.trophy_outline),
            activeIcon: Icon(Ionicons.trophy),
            label: "Peringkat",
          ),
        ],
      ),
    );
  }

  void changeIndex(int index, WidgetRef ref) {
    final potRef = ref.read(homeProvider.notifier);
    final userClientController = ref.read(userClientProvider.notifier);
    if (index == 0) {
      potRef.getPots();
    }
    if (index == 1) {
      userClientController.setVisitedUser();
    }
    ref.read(bottomNavProvider.notifier).setValueToDB(index);
  }
}
