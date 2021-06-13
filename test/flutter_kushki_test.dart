import 'package:flutter/services.dart';
// import 'package:flutter_kushki/kushki.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_kushki');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // TODO: create test methods
  // test('getPlatformVersion', () async {
  //   expect(await Kushki.platformVersion, '42');
  // });
}
