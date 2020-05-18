# flutter_kushki

[Kushki](https://www.kushkipagos.com/) frontend payment gateway integration for Flutter

## Installing

1. Add dependency to `pubspec.yaml`

    *Get the latest version in the 'Installing' tab on pub.dartlang.org*
    
```dart
dependencies:
    flutter_kushki: ^0.0.5
```

2. Import the package
```dart
import 'package:flutter_kushki/kushki.dart'; // Main class
import 'package:flutter_kushki/kushki_environment.dart'; // Environments
import 'package:flutter_kushki/kushki_card.dart'; // Card model
```

## Usage

#### Instantiate the class

```dart
    kushki = new Kushki(
      '<your_public_merchant_id>',
      currency: 'USD',
      environment: KushkiEnvironment.TESTING,
    );
```

#### Create the card data

```dart
    final _card = KushkiCard();
    _card.name = 'Kushki Test';
    _card.number = '4381082002222866';
    _card.cvv = '633';
    _card.expiryMonth = '07';
    _card.expiryYear = '21';
```

#### Get the card token

```dart
    try {
      final String token = await kushki.requestToken(_card, 30.52);
      print(token);
    } catch (e) {
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
