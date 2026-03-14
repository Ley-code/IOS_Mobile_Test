
import '../../domain/entities/login_entity.dart';

class LogInModel extends LoginEntity {
  const LogInModel({
    required super.email,
    required super.password,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}
