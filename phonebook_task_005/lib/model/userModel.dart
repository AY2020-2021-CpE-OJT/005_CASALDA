class LoginResponseModel {
  String authToken;
  String error;
  String message;

  LoginResponseModel(
      {required this.authToken, required this.error, required this.message});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      authToken: json['auth-token'] != null ? json['auth-token'] : '',
      error: json['error'] != null ? json['error'] : '',
      message: json['message'] != null ? json['message'] : '',
    );
  }
}

class LoginRequestModel {
  String email;
  String password;

  LoginRequestModel({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'email': email == null ? null : email.trim(),
      'password': password == null ? null : password.trim(),
    };
    return map;
  }
}

class RegisterRequestModel {
  String name;
  String email;
  String password;

  RegisterRequestModel(
      {required this.name, required this.email, required this.password});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'name': email == null ? null : email.trim(),
      'email': email == null ? null : email.trim(),
      'password': password == null ? null : password.trim(),
    };
    return map;
  }
}
