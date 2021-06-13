import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'dart:async';

import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_kushki/kushki.dart';
import 'package:flutter_kushki/kushki_environment.dart';
import 'package:flutter_kushki/kushki_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Kushki _kushki;
  TextEditingController _merchantIdController;

  @override
  void initState() {
    super.initState();
    _merchantIdController = TextEditingController();
  }

  // Create the Kushki class instance
  Future<void> initKushki(BuildContext context) async {
    setState(() {
      _kushki = new Kushki(
        _merchantIdController.text,
        currency: 'USD',
        environment: KushkiEnvironment.TESTING,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Kushki example app'),
        ),
        body: SingleChildScrollView(
          child: Column(
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
              _kushki != null
                  ? Form(
                      kushki: _kushki,
                    )
                  : Container(),
            ],
          ),
        ),
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
  final KushkiCard _card = KushkiCard();
  final totalAmount = 30.52;
  _FormState();
  String _cardToken;

  bool isCvvFocused = false;

  @override
  void initState() {
    super.initState();

    _card.name = 'Kushki Test';
    _card.number = '4381082002222866';
    _card.cvv = '633';
    _card.expiryMonth = '07';
    _card.expiryYear = '21';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CreditCardWidget(
          cardNumber: _card.number,
          expiryDate: '${_card.expiryMonth}/${_card.expiryYear}',
          cardHolderName: _card.name,
          cvvCode: _card.cvv,
          showBackView:
              isCvvFocused, //true when you want to show cvv(back) view
        ),
        CreditCardForm(
          onCreditCardModelChange: onCreditCardModelChange,
        ),
        MaterialButton(
          color: Colors.blueAccent,
          child: Text('Get the card token'),
          onPressed: () async {
            try {
              final String token =
                  await widget.kushki.requestToken(_card, totalAmount);
              setState(() {
                _cardToken = token;
              });
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text("Token: $token"),
                  backgroundColor: Colors.blue,
                ),
              );
            } catch (e) {
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_cardToken ?? 'Card token result from API'),
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
