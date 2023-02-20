import 'package:flutter/material.dart';

class ValidateToken {
  isValidToken({@required String? token}) {
    print("Token------->>>>>>>>>>>>>>>>>>>>>>> $token");
    if (token == "1234") {
      return true;
    }
    return false;
  }
}
