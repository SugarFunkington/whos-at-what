import 'package:app/data/repositories/members/members_repository.dart';
import 'package:app/domain/models/member.dart';
import 'package:app/utils/result.dart';

class FakeMembersRepository implements MembersRepository {
  FakeMembersRepository({this.result = const Result.ok([])});

  final Result<List<Member>> result;

  @override
  Future<Result<List<Member>>> fetchMembers() async => result;
}
