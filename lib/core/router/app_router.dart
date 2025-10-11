import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/events/screens/events_screen.dart';
import '../../features/events/screens/event_detail_screen.dart';
import '../../core/models/event.dart';
import '../../features/listings/screens/listing_detail_screen.dart';
import '../../features/listings/screens/listings_screen.dart';
import '../../features/booking/screens/booking_screen.dart';
import '../../features/booking/screens/booking_confirmation_screen.dart';
import '../../features/zoea_card/screens/zoea_card_screen.dart';
import '../../features/zoea_card/screens/transaction_history_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/events_attended_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/referrals/screens/referral_screen.dart';
import '../widgets/shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/explore',
    redirect: (context, state) {
      // No authentication required - users can browse freely
      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Shell
      ShellRoute(
        builder: (context, state, child) => Shell(child: child),
        routes: [
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/listings',
            builder: (context, state) => const ListingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Detail Routes
      GoRoute(
        path: '/event/:id',
        builder: (context, state) {
          final event = state.extra as Event?;
          if (event == null) {
            // Fallback - redirect to events screen if no event provided
            return const EventsScreen();
          }
          return EventDetailScreen(event: event);
        },
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ListingDetailScreen(listingId: id);
        },
      ),
      GoRoute(
        path: '/booking/:listingId',
        builder: (context, state) {
          final listingId = state.pathParameters['listingId']!;
          return BookingScreen(listingId: listingId);
        },
      ),
      GoRoute(
        path: '/booking-confirmation/:bookingId',
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BookingConfirmationScreen(bookingId: bookingId);
        },
      ),

      // Zoea Card Routes
      GoRoute(
        path: '/zoea-card',
        builder: (context, state) => const ZoeaCardScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionHistoryScreen(),
      ),

      // Settings Routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Referral Routes
      GoRoute(
        path: '/referrals',
        builder: (context, state) => const ReferralScreen(),
      ),

      // Profile Routes
      GoRoute(
        path: '/profile/events-attended',
        builder: (context, state) => const EventsAttendedScreen(),
      ),
    ],
  );
});
