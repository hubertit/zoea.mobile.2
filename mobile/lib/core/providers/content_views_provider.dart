import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_data_collection_provider.dart';

/// Parameters for content views query
class ContentViewsParams {
  final int? page;
  final int? limit;
  final String? contentType; // 'listing' or 'event'

  const ContentViewsParams({
    this.page,
    this.limit,
    this.contentType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentViewsParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          contentType == other.contentType;

  @override
  int get hashCode => page.hashCode ^ limit.hashCode ^ contentType.hashCode;
}

/// Provider for user's content views (places visited)
final myContentViewsProvider = FutureProvider.family<Map<String, dynamic>, ContentViewsParams>((ref, params) async {
  final analyticsService = ref.watch(analyticsServiceProvider);
  return await analyticsService.getMyContentViews(
    page: params.page,
    limit: params.limit,
    contentType: params.contentType,
  );
});

