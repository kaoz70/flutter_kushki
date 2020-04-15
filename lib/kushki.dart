import 'dart:async';

import 'package:flutter/services.dart';

import 'Card.dart';
import 'environments.dart';

class Kushki {
  static const MethodChannel _channel = const MethodChannel('flutter_kushki');
  final String publicMerchantId;
  final String currency;
  final KushkiEnvironment environment;
  final bool regional;
  bool isInitialized = false;

  Kushki({
    this.publicMerchantId,
    this.currency,
    this.environment,
    this.regional
  }) :
        assert(publicMerchantId != null),
        assert(currency != null),
        assert(environment != null),
        assert(regional != null);

  Future<bool> get init async {
    final bool initialized = await _channel.invokeMethod('init', <String, dynamic>{
      'publicMerchantId': publicMerchantId,
      'currency': currency,
      'environment': environment.toString().substring(environment.toString().indexOf('.')+1),
      'regional': regional,
    });

    isInitialized = initialized;
    return isInitialized;
  }

  Future<Map<String, dynamic>> requestToken(KushkiCard card) async {
    return await _channel.invokeMethod('requestToken', card.toMap());
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
