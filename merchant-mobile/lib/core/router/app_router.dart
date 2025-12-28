import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/business/screens/businesses_screen.dart';
import '../../features/business/screens/business_form_screen.dart';
import '../../features/listings/screens/listings_screen.dart';
import '../../features/listings/screens/listing_form_screen.dart';
import '../../features/bookings/screens/bookings_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/events/screens/events_screen.dart';
import '../../features/events/screens/event_form_screen.dart';
import '../../features/events/screens/event_detail_screen.dart';
import '../../features/subscription/screens/plans_screen.dart';
import '../../features/subscription/screens/checkout_screen.dart';
import '../../features/subscription/screens/success_screen.dart';
import '../../features/subscription/screens/manage_subscription_screen.dart';
import '../../core/models/subscription.dart';
import '../widgets/shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    redirect: (context, state) {
      // Authentication check can be added here
      return null;
    },
    routes: [
      // Auth Routes (outside shell)
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
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Main App Routes (inside shell)
      ShellRoute(
        builder: (context, state, child) => MerchantShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/businesses',
            builder: (context, state) => const BusinessesScreen(),
          ),
          GoRoute(
            path: '/listings',
            builder: (context, state) => const ListingsScreen(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingsScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Form routes (outside shell - full screen)
      GoRoute(
        path: '/businesses/new',
        builder: (context, state) => const BusinessFormScreen(),
      ),
      GoRoute(
        path: '/businesses/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BusinessFormScreen(businessId: id);
        },
      ),
      GoRoute(
        path: '/listings/new',
        builder: (context, state) => const ListingFormScreen(),
      ),
      GoRoute(
        path: '/listings/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ListingFormScreen(listingId: id);
        },
      ),
      // Wallet Route
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      // Notifications Route
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      // Profile Routes
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      // Analytics Route
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      // Event Routes
      GoRoute(
        path: '/events/new',
        builder: (context, state) => const EventFormScreen(),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventDetailScreen(eventId: id);
        },
      ),
      GoRoute(
        path: '/events/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventFormScreen(eventId: id);
        },
      ),
      // Subscription Routes
      GoRoute(
        path: '/subscription/plans',
        builder: (context, state) => const PlansScreen(),
      ),
      GoRoute(
        path: '/subscription/checkout',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return CheckoutScreen(
            plan: extra['plan'] as SubscriptionPlan,
            billingCycle: extra['billingCycle'] as BillingCycle,
          );
        },
      ),
      GoRoute(
        path: '/subscription/success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SubscriptionSuccessScreen(
            plan: extra['plan'] as SubscriptionPlan,
            billingCycle: extra['billingCycle'] as BillingCycle,
            hasTin: extra['hasTin'] as bool,
          );
        },
      ),
      GoRoute(
        path: '/subscription/manage',
        builder: (context, state) => const ManageSubscriptionScreen(),
      ),
    ],
  );
});
