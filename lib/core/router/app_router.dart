import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/onboarding_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/explore/screens/specials_screen.dart';
import '../../features/explore/screens/map_screen.dart';
import '../../features/explore/screens/dining_screen.dart';
import '../../features/explore/screens/experiences_screen.dart';
import '../../features/explore/screens/nightlife_screen.dart';
import '../../features/explore/screens/shopping_screen.dart';
import '../../features/explore/screens/accommodation_screen.dart';
import '../../features/explore/screens/accommodation_detail_screen.dart';
import '../../features/explore/screens/accommodation_booking_screen.dart';
import '../../features/explore/screens/place_detail_screen.dart';
import '../../features/explore/screens/dining_booking_screen.dart';
import '../../features/explore/screens/dining_booking_confirmation_screen.dart';
import '../../features/explore/screens/recommendations_screen.dart';
import '../../features/explore/screens/category_places_screen.dart';
import '../../features/events/screens/events_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/search/screens/search_screen.dart';
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
import '../../features/profile/screens/visited_places_screen.dart';
import '../../features/profile/screens/reviews_written_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/privacy_security_screen.dart';
import '../../features/profile/screens/my_bookings_screen.dart';
import '../../features/profile/screens/favorites_screen.dart';
import '../../features/profile/screens/reviews_ratings_screen.dart';
import '../../features/profile/screens/help_center_screen.dart';
import '../../features/profile/screens/about_screen.dart';
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
            path: '/accommodation',
            builder: (context, state) => const AccommodationScreen(),
          ),
          GoRoute(
            path: '/my-bookings',
            builder: (context, state) => const MyBookingsScreen(),
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
      GoRoute(
        path: '/profile/visited-places',
        builder: (context, state) => const VisitedPlacesScreen(),
      ),
      GoRoute(
        path: '/profile/reviews-written',
        builder: (context, state) => const ReviewsWrittenScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/privacy-security',
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: '/profile/my-bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/profile/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/profile/reviews-ratings',
        builder: (context, state) => const ReviewsRatingsScreen(),
      ),
      GoRoute(
        path: '/profile/help-center',
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: '/profile/about',
        builder: (context, state) => const AboutScreen(),
      ),

      // Specials Route
      GoRoute(
        path: '/specials',
        builder: (context, state) => const SpecialsScreen(),
      ),

      // Notifications Route
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),

      // Search Route
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'];
          final category = state.uri.queryParameters['category'];
          return SearchScreen(initialQuery: query, category: category);
        },
      ),

      // Map Route
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapScreen(),
      ),

      // Dining Route
      GoRoute(
        path: '/dining',
        builder: (context, state) => const DiningScreen(),
      ),

      // Experiences Route
      GoRoute(
        path: '/experiences',
        builder: (context, state) => const ExperiencesScreen(),
      ),

      // Nightlife Route
      GoRoute(
        path: '/nightlife',
        builder: (context, state) => const NightlifeScreen(),
      ),

      // Shopping Route
      GoRoute(
        path: '/shopping',
        builder: (context, state) => const ShoppingScreen(),
      ),
      GoRoute(
        path: '/accommodation/:accommodationId',
        builder: (context, state) {
          final accommodationId = state.pathParameters['accommodationId']!;
          final dateData = state.extra as Map<String, dynamic>?;
          final checkInDate = dateData?['checkInDate'] as DateTime?;
          final checkOutDate = dateData?['checkOutDate'] as DateTime?;
          final checkInTime = dateData?['checkInTime'] as TimeOfDay?;
          final guestCount = dateData?['guestCount'] as int?;
          return AccommodationDetailScreen(
            accommodationId: accommodationId,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            checkInTime: checkInTime,
            guestCount: guestCount,
          );
        },
      ),
      GoRoute(
        path: '/accommodation/:accommodationId/book',
        builder: (context, state) {
          final accommodationId = state.pathParameters['accommodationId']!;
          final bookingData = state.extra as Map<String, dynamic>?;
          final selectedRooms = bookingData?['selectedRooms'] as Map<String, Map<String, dynamic>>?;
          final checkInDate = bookingData?['checkInDate'] as DateTime?;
          final checkOutDate = bookingData?['checkOutDate'] as DateTime?;
          final checkInTime = bookingData?['checkInTime'] as TimeOfDay?;
          final guestCount = bookingData?['guestCount'] as int?;
          return AccommodationBookingScreen(
            accommodationId: accommodationId,
            selectedRooms: selectedRooms,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            checkInTime: checkInTime,
            guestCount: guestCount,
          );
        },
      ),


      // Place Detail Route
      GoRoute(
        path: '/place/:placeId',
        builder: (context, state) {
          final placeId = state.pathParameters['placeId']!;
          return PlaceDetailScreen(placeId: placeId);
        },
      ),

      // Dining Booking Route
      GoRoute(
        path: '/dining-booking',
        builder: (context, state) {
          final bookingData = state.extra as Map<String, dynamic>?;
          return DiningBookingScreen(
            placeId: bookingData?['placeId'] ?? '',
            placeName: bookingData?['placeName'] ?? '',
            placeLocation: bookingData?['placeLocation'] ?? '',
            placeImage: bookingData?['placeImage'] ?? '',
            placeRating: bookingData?['placeRating'] ?? 0.0,
            priceRange: bookingData?['priceRange'] ?? '',
          );
        },
      ),

      // Dining Booking Confirmation Route
      GoRoute(
        path: '/dining-booking-confirmation',
        builder: (context, state) {
          final confirmationData = state.extra as Map<String, dynamic>?;
          return DiningBookingConfirmationScreen(
            placeName: confirmationData?['placeName'] ?? '',
            placeLocation: confirmationData?['placeLocation'] ?? '',
            date: confirmationData?['date'] as DateTime?,
            time: confirmationData?['time'] ?? '',
            guests: confirmationData?['guests'] ?? 2,
            fullName: confirmationData?['fullName'] ?? '',
            phone: confirmationData?['phone'] ?? '',
            email: confirmationData?['email'] ?? '',
            specialRequests: confirmationData?['specialRequests'] ?? '',
          );
        },
      ),

      // Recommendations Route
      GoRoute(
        path: '/recommendations',
        builder: (context, state) => const RecommendationsScreen(),
      ),
      
      // Category Places Route
      GoRoute(
        path: '/category/:category',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          return CategoryPlacesScreen(category: category);
        },
      ),
    ],
  );
});
