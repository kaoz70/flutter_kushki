import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'dart:async';

import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_kushki/kushki.dart';
import 'package:flutter_kushki/Card.dart';
import 'package:flutter_kushki/environments.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Kushki kushki;
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      kushki = new Kushki(
          publicMerchantId: '',
          currency: 'USD',
          environment: KushkiEnvironment.TESTING,
          regional: false
      );

      await kushki.init;
      platformVersion = await kushki.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Running on: $_platformVersion\n'),
            Expanded(child: Form(kushki: kushki,)),
          ],
        ),
        //body: Form(kushki: kushki,),
      ),
    );
  }
}

class Form extends StatefulWidget {
  final Kushki kushki;

  const Form({Key key, this.kushki}) : super(key: key);

  @override
  _FormState createState() => _FormState(kushki);
}

class _FormState extends State<Form> {
  final Kushki kushki;

  final _card = KushkiCard();
  _FormState(this.kushki);

  bool isCvvFocused = false;

  @override
  void initState() {
    super.initState();

    _card.name = 'Kushki Test';
    _card.number = '4381082002222866';
    _card.cvv = '633';
    _card.expiryMonth = '07';
    _card.expiryYear = '21';
    _card.totalAmount = 30.52;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        kushki.isInitialized ? Text('Kushki is initialized') : Text('Kushki is not initialized'),
        CreditCardWidget(
          cardNumber: _card.number,
          expiryDate: '${_card.expiryMonth}/${_card.expiryYear}',
          cardHolderName: _card.name,
          cvvCode: _card.cvv,
          showBackView: isCvvFocused, //true when you want to show cvv(back) view
        ),
        Expanded(
          child: SingleChildScrollView(
            child: CreditCardForm(
              onCreditCardModelChange: onCreditCardModelChange,
            ),
          ),
        ),
        MaterialButton(
          color: Colors.blueAccent,
          child: Text('Submit'),
          onPressed: () async {
            try {
              final transaction = await kushki.requestToken(_card);
              print(transaction);
            } on PlatformException catch (e) {
              print(e.toString());
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    final String date = creditCardModel.expiryDate;
    final dates = date.split('/');

    setState(() {
      _card.number = creditCardModel.cardNumber;

      if (dates.length == 2) {
        _card.expiryMonth = dates[0];
        _card.expiryYear = dates[1];
      }
      _card.name = creditCardModel.cardHolderName;
      _card.cvv = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }
}