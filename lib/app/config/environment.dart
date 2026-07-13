import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get baseUrl => dotenv.get('SUFFA_BASE_URL');

  static String get razorPayTestKey => dotenv.get('RAZORPAY_TEST_KEY');

  static String get razorPaySecretKey => dotenv.get('RAZORPAY_SECRET_KEY');

  // Add more environment variables here as needed
}
