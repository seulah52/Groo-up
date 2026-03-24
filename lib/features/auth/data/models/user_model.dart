import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String? email;
  final String? username;
  final String? avatarUrl;

  const UserModel({required this.id, this.email, this.username, this.avatarUrl});

  factory UserModel.fromSupabaseUser(dynamic user) => UserModel(
    id: user.id as String,
    email: user.email as String?,
    username: (user.userMetadata?['username']) as String?,
  );

  UserEntity toEntity() => UserEntity(
    id: id, email: email, username: username, avatarUrl: avatarUrl);
}
