import 'dart:async';

import 'dart:convert' as convert;
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'kushki_card.dart';
import 'kushki_environment.dart';

class Kushki {
  final String publicMerchantId;
  final String currency;
  final KushkiEnvironment environment;
  final productionUrl = 'https://api.kushkipagos.com/';
  final testingUrl = 'https://api-uat.kushkipagos.com/';

  String get url => environment == KushkiEnvironment.PRODUCTION
          ? productionUrl
          : testingUrl;

  Kushki(this.publicMerchantId, {this.currency, this.environment})
      : assert(publicMerchantId != null), assert(environment != null);

  Future<String> requestToken(KushkiCard card, double amount) async {
    final response = await http.post('${url}card/v1/tokens',
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
      final jsonResponse = convert.jsonDecode(response.body);
      return jsonResponse['token'];
    } else {
      throw Exception('${response.body}');
    }
  }
}
