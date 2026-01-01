import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/theme_extensions.dart';

class Shell extends StatelessWidget {
  final Widget child;

  const Shell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    // Determine current index based on location
    int currentIndex = 0;
    if (location.startsWith('/events')) {
      currentIndex = 1;
    } else if (location.startsWith('/accommodation')) {
      currentIndex = 2;
    } else if (location.startsWith('/my-bookings')) {
      currentIndex = 3;
    } else if (location.startsWith('/profile')) {
      currentIndex = 4;
    } else if (location.startsWith('/explore')) {
      currentIndex = 0;
    }
    
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.surfaceColor,
        selectedItemColor: context.primaryColorTheme,
        unselectedItemColor: context.secondaryTextColor,
        currentIndex: currentIndex,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: context.primaryColorTheme,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.secondaryTextColor,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel_outlined),
            activeIcon: Icon(Icons.hotel),
            label: 'Stay',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online_outlined),
            activeIcon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/explore');
              break;
            case 1:
              context.go('/events');
              break;
            case 2:
              context.go('/accommodation');
              break;
            case 3:
              context.go('/my-bookings');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}
