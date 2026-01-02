import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/country.dart';

class CountriesService {
  /// Get authenticated Dio instance for API calls
  Future<Dio> _getDio() async {
    return AppConfig.authenticatedDioInstance();
  }

  /// Get all active countries
  Future<List<Country>> getActiveCountries() async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/countries/active');
      
      final List<dynamic> data = response.data as List;
      return data.map((json) => Country.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get country by ID
  Future<Country> getCountryById(String id) async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/countries/$id');
      
      return Country.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Get country by code (2-letter ISO code like "RW", "KE")
  Future<Country?> getCountryByCode(String code) async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/countries/code/$code');
      
      return Country.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Get cities for a country
  Future<List<Map<String, dynamic>>> getCountryCities(String countryId) async {
    try {
      final dio = await _getDio();
      final response = await dio.get('/countries/$countryId/cities');
      
      return List<Map<String, dynamic>>.from(response.data as List);
    } catch (e) {
      rethrow;
    }
  }
}

