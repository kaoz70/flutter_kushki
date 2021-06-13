import 'dart:async';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'kushki_card.dart';
import 'kushki_environment.dart';

/// Main Kushki class for gateway transactions
class Kushki {
  final String publicMerchantId;
  final String? currency;
  final KushkiEnvironment environment;
  final productionUrl = 'https://api.kushkipagos.com/';
  final testingUrl = 'https://api-uat.kushkipagos.com/';

  String get url =>
      environment == KushkiEnvironment.PRODUCTION ? productionUrl : testingUrl;

  Kushki(this.publicMerchantId, {this.currency, required this.environment})
      : assert(publicMerchantId != null),
        assert(environment != null);

  /// Get the card's token, use this to make charges via some backend
  /// using your private merchant id
  Future<String?> requestToken(KushkiCard card, double amount) async {
    final response = await http.post(
      Uri.parse('${url}card/v1/tokens'),
      headers: {
        'Public-Merchant-Id': publicMerchantId,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'card': card.toMap(),
        'totalAmount': amount,
        'currency': currency,
      }),
    );

    if (response.statusCode < 400) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['token'];
    } else {
      throw Exception('${response.body}');
    }
  }
}
