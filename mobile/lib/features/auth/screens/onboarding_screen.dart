import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_extensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Discover Rwanda',
      subtitle: 'Explore the land of a thousand hills with verified experiences',
      icon: Icons.explore,
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      title: 'Book Seamlessly',
      subtitle: 'Reserve hotels, restaurants, and tours with our Zoea Card',
      icon: Icons.credit_card,
      color: AppTheme.successColor,
    ),
    OnboardingPage(
      title: 'Connect & Share',
      subtitle: 'Join the community and share your Rwandan adventures',
      icon: Icons.people,
      color: AppTheme.primaryColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    // Use theme-aware colors for icons
    final iconColor = page.color == AppTheme.primaryColor 
        ? context.primaryColorTheme 
        : (page.color == AppTheme.successColor 
            ? context.successColor 
            : context.primaryColorTheme);
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 120,
            color: iconColor,
          ).animate().scale(
            duration: 600.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 200.ms,
          ),
          const SizedBox(height: 16),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
            duration: 800.ms,
            delay: 400.ms,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? context.primaryColorTheme
                      : context.dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate().scale(
                duration: 300.ms,
                curve: Curves.easeOut,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage < _pages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  context.go('/login');
                }
              },
              child: Text(
                _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
              ),
            ),
          ).animate().slideY(
            begin: 1,
            duration: 600.ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/login'),
            child: Text(
              'Already have an account? Sign In',
              style: TextStyle(
                color: context.secondaryTextColor,
              ),
            ),
          ).animate().fadeIn(
            duration: 600.ms,
            delay: 200.ms,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}