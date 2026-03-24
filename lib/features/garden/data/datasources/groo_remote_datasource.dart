import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../models/groo_model.dart';

abstract interface class GrooRemoteDatasource {
  Future<List<GrooModel>> fetchAllGroos(String userId);
  Future<GrooModel>       fetchGrooById(String id);
  Future<GrooModel>       insertGroo(Map<String, dynamic> data);
  Future<GrooModel>       updateStage(String grooId, String stage);
  Future<GrooModel>       updateHealthScore(String grooId, int score);
  Future<void>            deleteGroo(String id);
}

class GrooRemoteDatasourceImpl implements GrooRemoteDatasource {
  final SupabaseClient _supabase;
  static const _table = SupabaseTables.ideas;
  const GrooRemoteDatasourceImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<List<GrooModel>> fetchAllGroos(String userId) async {
    final res = await _supabase.from(_table).select()
        .eq('user_id', userId).eq('is_archived', false).order('created_at');
    return (res as List).map((e) => GrooModel.fromJson(e)).toList();
  }

  @override
  Future<GrooModel> fetchGrooById(String id) async {
    final res = await _supabase.from(_table).select().eq('id', id).single();
    return GrooModel.fromJson(res);
  }

  @override
  Future<GrooModel> insertGroo(Map<String, dynamic> data) async {
    final res = await _supabase.from(_table).insert(data).select().single();
    return GrooModel.fromJson(res);
  }

  @override
  Future<GrooModel> updateStage(String grooId, String stage) async {
    final res = await _supabase.from(_table)
        .update(<String, dynamic>{
          'growth_stage': stage,
          'last_activity_at': DateTime.now().toIso8601String(),
        })
        .eq('id', grooId).select().single();
    return GrooModel.fromJson(res);
  }

  @override
  Future<GrooModel> updateHealthScore(String grooId, int score) async {
    final status = score >= 70 ? 'green' : score >= 40 ? 'orange' : 'red';
    final res = await _supabase.from(_table)
        .update({'health_score': score, 'health_status': status})
        .eq('id', grooId).select().single();
    return GrooModel.fromJson(res);
  }

  @override
  Future<void> deleteGroo(String id) async =>
      _supabase.from(_table).delete().eq('id', id);
}
