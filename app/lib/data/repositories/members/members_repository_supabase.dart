import 'package:app/data/repositories/members/members_repository.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MembersRepositorySupabase implements MembersRepository {
  MembersRepositorySupabase(this._client);

  final SupabaseClient _client;

  /// The family's members. RLS returns only the logged-in user's family.
  @override
  Future<Result<List<Member>>> fetchMembers() async {
    try {
      final rows = await _client
          .from('members')
          .select('id, display_name, colour')
          .order('created_at', ascending: true);

      return Result.ok(rows.map(Member.fromJson).toList());
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
