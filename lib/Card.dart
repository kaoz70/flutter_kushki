class KushkiCard {
  String name;
  String number;
  String cvv;
  String expiryMonth;
  String expiryYear;
  double totalAmount;

  Map<String, dynamic> toMap() => {
    'name': name,
    'number': number,
    'cvv': cvv,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'totalAmount': totalAmount,
  };
}