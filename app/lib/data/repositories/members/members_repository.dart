import 'package:app/domain/models/member.dart';
import 'package:app/utils/result.dart';

abstract class MembersRepository {
  Future<Result<List<Member>>> fetchMembers();
}
