import 'package:dio/dio.dart';
import '../config/app_config.dart';

class BookingsService {
  /// Get authenticated Dio instance for API calls
  Future<Dio> _getDio() async {
    return AppConfig.authenticatedDioInstance();
  }

  /// Get user bookings with filters
  /// Returns: {data: [...], meta: {total, page, limit, totalPages}}
  Future<Map<String, dynamic>> getBookings({
    int? page,
    int? limit,
    String? status,
    String? type,
  }) async {
    try {
      final dio = await _getDio();
      final queryParams = <String, dynamic>{};
      
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final response = await dio.get(
        AppConfig.bookingsEndpoint,
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch bookings: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch bookings.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching bookings: $e');
    }
  }

  /// Get upcoming bookings
  Future<List<Map<String, dynamic>>> getUpcomingBookings({
    int limit = 5,
  }) async {
    try {
      final dio = await _getDio();
      final response = await dio.get(
        '${AppConfig.bookingsEndpoint}/upcoming',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
        return [];
      } else {
        throw Exception('Failed to fetch upcoming bookings: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch upcoming bookings.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching upcoming bookings: $e');
    }
  }

  /// Get booking details by ID
  Future<Map<String, dynamic>> getBooking(String id) async {
    try {
      final dio = await _getDio();
      final response = await dio.get('${AppConfig.bookingsEndpoint}/$id');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to fetch booking: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to fetch booking.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Booking not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching booking: $e');
    }
  }

  /// Create hotel booking
  Future<Map<String, dynamic>> createHotelBooking({
    required String listingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? roomTypeId,
    int guestCount = 1,
    int? adults,
    int? children,
    String? specialRequests,
    List<Map<String, dynamic>>? guests,
  }) async {
    try {
      final dio = await _getDio();
      
      final data = <String, dynamic>{
        'bookingType': 'hotel',
        'listingId': listingId,
        'checkInDate': _formatDate(checkInDate),
        'checkOutDate': _formatDate(checkOutDate),
        'guestCount': guestCount,
      };

      if (roomTypeId != null) data['roomTypeId'] = roomTypeId;
      if (adults != null) data['adults'] = adults;
      if (children != null) data['children'] = children;
      if (specialRequests != null && specialRequests.isNotEmpty) {
        data['specialRequests'] = specialRequests;
      }
      if (guests != null && guests.isNotEmpty) {
        data['guests'] = guests;
      }

      final response = await dio.post(
        AppConfig.bookingsEndpoint,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create booking: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create booking.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          // Validation error - extract detailed message
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            if (errorData['message'] is List) {
              errorMessage = (errorData['message'] as List).join(', ');
            } else {
              errorMessage = errorData['message'].toString();
            }
          } else {
            errorMessage = message ?? 'Invalid booking data. Please check your input.';
          }
        } else if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 409) {
          errorMessage = 'Room not available for selected dates. Please choose different dates.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  /// Create restaurant booking
  Future<Map<String, dynamic>> createRestaurantBooking({
    required String listingId,
    required DateTime bookingDate,
    required String bookingTime, // Format: "19:00" (24-hour) or "7:00 PM"
    required int partySize,
    String? tableId,
    String? timeSlotId,
    String? fullName,
    String? contactNumber,
    String? email,
    String? specialRequests,
    List<Map<String, dynamic>>? guests,
  }) async {
    try {
      final dio = await _getDio();
      
      // Convert time to 24-hour format if needed
      final time24Hour = _convertTo24HourFormat(bookingTime);
      
      final data = <String, dynamic>{
        'bookingType': 'restaurant',
        'listingId': listingId,
        'bookingDate': _formatDate(bookingDate),
        'bookingTime': time24Hour,
        'partySize': partySize,
        'guestCount': partySize,
      };

      if (tableId != null) data['tableId'] = tableId;
      if (timeSlotId != null) data['timeSlotId'] = timeSlotId;
      if (specialRequests != null && specialRequests.isNotEmpty) {
        data['specialRequests'] = specialRequests;
      }

      // Build guests array from contact info or provided guests
      final guestsList = <Map<String, dynamic>>[];
      if (guests != null && guests.isNotEmpty) {
        guestsList.addAll(guests);
      } else if (fullName != null && fullName.isNotEmpty) {
        guestsList.add({
          'fullName': fullName,
          if (email != null && email.isNotEmpty) 'email': email,
          if (contactNumber != null && contactNumber.isNotEmpty) 'phone': contactNumber,
          'isPrimary': true,
        });
      }
      
      if (guestsList.isNotEmpty) {
        data['guests'] = guestsList;
      }

      final response = await dio.post(
        AppConfig.bookingsEndpoint,
        data: data,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to create booking: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to create booking.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 400) {
          // Validation error - extract detailed message
          final errorData = e.response!.data;
          if (errorData is Map && errorData['message'] != null) {
            if (errorData['message'] is List) {
              errorMessage = (errorData['message'] as List).join(', ');
            } else {
              errorMessage = errorData['message'].toString();
            }
          } else {
            errorMessage = message ?? 'Invalid booking data. Please check your input.';
          }
        } else if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 409) {
          errorMessage = 'Time slot not available. Please choose a different time.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }

  /// Update booking
  Future<Map<String, dynamic>> updateBooking({
    required String id,
    String? specialRequests,
    int? guestCount,
  }) async {
    try {
      final dio = await _getDio();
      
      final data = <String, dynamic>{};
      if (specialRequests != null) data['specialRequests'] = specialRequests;
      if (guestCount != null) data['guestCount'] = guestCount;

      final response = await dio.put(
        '${AppConfig.bookingsEndpoint}/$id',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update booking: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to update booking.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Booking not found.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error updating booking: $e');
    }
  }

  /// Cancel booking
  Future<Map<String, dynamic>> cancelBooking({
    required String id,
    String? reason,
  }) async {
    try {
      final dio = await _getDio();
      
      final data = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        data['reason'] = reason;
      }

      final response = await dio.post(
        '${AppConfig.bookingsEndpoint}/$id/cancel',
        data: data,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to cancel booking: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to cancel booking.';
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['message'] ?? e.response!.statusMessage;
        
        if (statusCode == 401) {
          errorMessage = 'Unauthorized. Please login again.';
        } else if (statusCode == 404) {
          errorMessage = 'Booking not found.';
        } else if (statusCode == 400) {
          errorMessage = 'Booking cannot be cancelled. It may have already been cancelled or completed.';
        } else {
          errorMessage = message ?? errorMessage;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection. Please check your network.';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error cancelling booking: $e');
    }
  }

  /// Confirm payment (TODO: Implement when payment feature is ready)
  /// For now, this is a placeholder
  Future<Map<String, dynamic>> confirmPayment({
    required String id,
    required String paymentMethod,
    required String paymentReference,
  }) async {
    // TODO: Implement when payment feature is ready
    throw UnimplementedError('Payment confirmation will be implemented later');
  }

  /// Helper: Format DateTime to ISO date string (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Helper: Convert time from 12-hour format to 24-hour format
  /// Input: "12:00 PM", "1:30 PM", "11:00 AM", "7:00 PM"
  /// Output: "12:00", "13:30", "11:00", "19:00"
  String _convertTo24HourFormat(String time) {
    // If already in 24-hour format (contains no AM/PM), return as is
    if (!time.toUpperCase().contains('AM') && !time.toUpperCase().contains('PM')) {
      // Validate format (should be HH:MM)
      if (RegExp(r'^\d{1,2}:\d{2}$').hasMatch(time)) {
        return time;
      }
    }

    // Parse 12-hour format
    final upperTime = time.trim().toUpperCase();
    final isPM = upperTime.contains('PM');
    final isAM = upperTime.contains('AM');
    
    // Remove AM/PM
    final timeOnly = upperTime.replaceAll(RegExp(r'\s*(AM|PM)\s*'), '');
    
    // Split hours and minutes
    final parts = timeOnly.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid time format: $time');
    }
    
    int hours = int.tryParse(parts[0]) ?? 0;
    final minutes = parts[1].padLeft(2, '0');
    
    // Convert to 24-hour format
    if (isPM && hours != 12) {
      hours += 12;
    } else if (isAM && hours == 12) {
      hours = 0;
    }
    
    return '${hours.toString().padLeft(2, '0')}:$minutes';
  }
}

