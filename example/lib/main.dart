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
  Kushki _kushki;
  String _platformVersion = 'Unknown';
  String _errorMessage;
  TextEditingController _merchantIdController;


  @override
  void initState() {
    super.initState();
    _merchantIdController = TextEditingController();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initKushki(BuildContext context) async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      _errorMessage = null;
      _kushki = new Kushki(
          publicMerchantId: _merchantIdController.text,
          currency: 'USD',
          environment: KushkiEnvironment.TESTING,
          regional: false
      );

      await _kushki.init;
      platformVersion = await _kushki.platformVersion;
    } on PlatformException catch (e) {
      print(e);
      _kushki = null;
      _errorMessage = e.message;
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
          title: const Text('Kushki example app'),
        ),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: TextFormField(
                decoration: InputDecoration(labelText: 'Merchant ID'),
                controller: _merchantIdController,
                validator: (value) {
                  if (value.isEmpty) {
                    return "Please input your Kushki's Merchant ID";
                  }
                  return null;
                },
              ),
            ),
            MaterialButton(
              color: Colors.blueAccent,
              child: Text('Set ID'),
              onPressed: () async {
                initKushki(context);
              },
            ),
            _errorMessage != null ? Text(_errorMessage) : Container(),
            _kushki != null ? Text('Running on: $_platformVersion\n') : Container(),
            _kushki != null ? Expanded(child: Form(kushki: _kushki,)) : Container(),
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
  _FormState createState() => _FormState();
}

class _FormState extends State<Form> {
  final _card = KushkiCard();
  _FormState();

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
        widget.kushki.isInitialized ? Text('Kushki is initialized') : Text('Kushki is not initialized'),
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
              final String token = await widget.kushki.requestToken(_card);
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Token: $token"),
                  backgroundColor: Colors.blue,
                ),
              );
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