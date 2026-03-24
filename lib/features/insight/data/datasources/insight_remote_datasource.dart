import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../../domain/entities/trend_log_entity.dart';
import '../models/trend_log_model.dart';

abstract interface class InsightRemoteDatasource {
  Future<List<TrendLogModel>> fetchTrendLogs({InsightCategory? category});
  Future<Set<String>> fetchBookmarkedTrendIds(String userId);
  Future<void> addBookmark(String userId, String trendLogId);
  Future<void> removeBookmark(String userId, String trendLogId);
}

class InsightRemoteDatasourceImpl implements InsightRemoteDatasource {
  final SupabaseClient _supabase;

  const InsightRemoteDatasourceImpl({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<List<TrendLogModel>> fetchTrendLogs({InsightCategory? category}) async {
    final base = _supabase.from(SupabaseTables.trendLogs).select();
    final filtered =
        category != null ? base.eq('category', category.name) : base;
    final rows = await filtered
        .order('published_at', ascending: false)
        .limit(80);
    final list = rows as List<dynamic>;
    return list
        .map((e) => TrendLogModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<Set<String>> fetchBookmarkedTrendIds(String userId) async {
    final rows = await _supabase
        .from(SupabaseTables.bookmarks)
        .select('trend_log_id')
        .eq('user_id', userId);
    final list = rows as List<dynamic>;
    return list
        .map((e) => (e as Map)['trend_log_id'] as String)
        .toSet();
  }

  @override
  Future<void> addBookmark(String userId, String trendLogId) async {
    await _supabase.from(SupabaseTables.bookmarks).insert(<String, dynamic>{
      'user_id': userId,
      'trend_log_id': trendLogId,
    });
  }

  @override
  Future<void> removeBookmark(String userId, String trendLogId) async {
    await _supabase
        .from(SupabaseTables.bookmarks)
        .delete()
        .eq('user_id', userId)
        .eq('trend_log_id', trendLogId);
  }
}
