# flutter_kushki

[Kushki](https://www.kushkipagos.com/) frontend payment gateway integration for Flutter

## Installing

1. Add dependency to `pubspec.yaml`

    *Get the latest version in the 'Installing' tab on pub.dartlang.org*
    
```dart
dependencies:
    flutter_kushki: ^0.0.2
```

2. Import the package
```dart
import 'package:flutter_credit_card/flutter_credit_card.dart';
```

## Usage

#### Instantiate the class

```dart

    try {
      kushki = new Kushki(
          publicMerchantId: '<your_merchant_id>',
          currency: 'USD',
          environment: KushkiEnvironment.TESTING,
          regional: false
      );

      await kushki.init;
    } on PlatformException {
      print('Failied to instantiate class');
    }
```

#### Create the card data

```dart

    final _card = KushkiCard();
    _card.name = 'Kushki Test';
    _card.number = '4381082002222866';
    _card.cvv = '633';
    _card.expiryMonth = '07';
    _card.expiryYear = '21';
    _card.totalAmount = 30.52;
```

#### Get the card token

```dart

    try {
      final transaction = await kushki.requestToken(_card);
      print(transaction);
    } on PlatformException catch (e) {
      print(e.toString());
    }
```

## TODO:

* [x] requestToken()
* [ ] getBinInfo()
* [ ] requestSubscriptionToken()
* [ ] requestCardAsyncToken()
* [ ] getBankList()
* [ ] requestTransferSubscriptionToken()
* [ ] requestSecureValidation()
* [ ] requestCashToken()
* [ ] requestCashOutToken()
* [ ] requestTransferToken()
