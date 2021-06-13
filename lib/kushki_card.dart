/// Card model representing Kushki's card structure
class KushkiCard {
  String? name;
  String? number;
  String? cvv;
  String? expiryMonth;
  String? expiryYear;

  /// Transform private properties into a Map to be sent through a request
  Map<String, dynamic> toMap() => {
        'name': name,
        'number': number,
        'cvv': cvv,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
      };
}
