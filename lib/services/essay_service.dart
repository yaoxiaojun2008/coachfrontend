import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/essay_model.dart';

class EssayService {
  final SupabaseClient _supabase;

  EssayService(this._supabase);

  Future<List<EssayModel>> getAllEssays() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('essays')
        .select('*')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    
    // response is List<dynamic>
    return (response as List).map((e) => EssayModel.fromJson(e)).toList();
  }

  Future<EssayModel> createEssay(Map<String, dynamic> essayData) async {
    final response = await _supabase
        .from('essays')
        .insert(essayData)
        .select()
        .single();
    
    return EssayModel.fromJson(response);
  }

  Future<EssayModel> getEssayById(String id) async {
    final response = await _supabase
        .from('essays')
        .select()
        .eq('id', id)
        .single();
    return EssayModel.fromJson(response);
  }

  Future<EssayModel> updateEssay(String id, Map<String, dynamic> essayData) async {
    final response = await _supabase
        .from('essays')
        .update(essayData)
        .eq('id', id)
        .select()
        .single();
    return EssayModel.fromJson(response);
  }

  Future<void> deleteEssay(String id) async {
     await _supabase
        .from('essays')
        .delete()
        .eq('id', id);
  }
}
