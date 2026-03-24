import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_tables.dart';
import '../../../../core/utils/user_id_guard.dart';
import '../../../garden/data/models/groo_model.dart';

abstract interface class InputRemoteDatasource {
  Future<GrooModel> plantSeed({
    required String userId, required String title, String? category});
}

class InputRemoteDatasourceImpl implements InputRemoteDatasource {
  final SupabaseClient _supabase;
  const InputRemoteDatasourceImpl({required SupabaseClient supabase}) : _supabase = supabase;

  @override
  Future<GrooModel> plantSeed({
    required String userId, required String title, String? category}) async {
    final uidError = UserIdGuard.validationMessage(userId);
    if (uidError != null) {
      throw ArgumentError(uidError);
    }
    final uid = userId.trim();
    // RLS: auth.uid() 와 insert 의 user_id 가 반드시 같아야 함 → JWT 기준 id 로만 넣음
    final sessionUser = _supabase.auth.currentUser;
    if (sessionUser == null) {
      throw StateError('로그인 세션이 없습니다. 다시 로그인해 주세요.');
    }
    if (sessionUser.id != uid) {
      throw StateError('세션 유저와 요청 유저가 일치하지 않습니다. 앱을 다시 시작해 주세요.');
    }
    final row = <String, dynamic>{
      'user_id': sessionUser.id,
      'title': title,
      'category': category,
      'growth_stage': 'seed',
      'health_status': 'red',
      'health_score': 30,
    };
    final res = await _supabase.from(SupabaseTables.ideas).insert(row).select().single();
    return GrooModel.fromJson(res);
  }
}
