import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_kushki/flutter_kushki.dart';
import 'package:flutter_kushki/Card.dart';
import 'package:flutter_kushki/environments.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FlutterKushki kushki;
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
      kushki = new FlutterKushki(
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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Form(kushki: kushki,),
            ],
          ),
        ),
      ),
    );
  }
}

class Form extends StatefulWidget {
  final FlutterKushki kushki;

  const Form({Key key, this.kushki}) : super(key: key);

  @override
  _FormState createState() => _FormState(kushki);
}

class _FormState extends State<Form> {
  final FlutterKushki kushki;

  final _card = KushkiCard();
  TextEditingController _nameController;
  TextEditingController _numberController;
  TextEditingController _cvvController;
  TextEditingController _monthController;
  TextEditingController _yearController;
  TextEditingController _totalAmountController;
  _FormState(this.kushki);

  @override
  void initState() {
    super.initState();

    _card.name = 'Kushki Test';
    _card.number = '4381082002222866';
    _card.cvv = '633';
    _card.expiryMonth = '07';
    _card.expiryYear = '21';
    _card.totalAmount = 30.52;

    _nameController = TextEditingController(text: _card.name);
    _numberController = TextEditingController(text: _card.number);
    _cvvController = TextEditingController(text: _card.cvv);
    _monthController = TextEditingController(text: _card.expiryMonth);
    _yearController = TextEditingController(text: _card.expiryYear);
    _totalAmountController = TextEditingController(text: _card.totalAmount.toString());

    _nameController.addListener(() => _card.name = _nameController.text.trim());
    _numberController.addListener(() => _card.number = _numberController.text.trim());
    _cvvController.addListener(() => _card.cvv = _cvvController.text.trim());
    _monthController.addListener(() => _card.expiryMonth = _monthController.text.trim());
    _yearController.addListener(() => _card.expiryYear = _yearController.text.trim());
    _totalAmountController.addListener(() => _card.totalAmount = double.parse(_totalAmountController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        kushki.isInitialized ? Text('Kushki is initialized') : Text('Kushki is not initialized'),
        TextFormField(
          decoration: InputDecoration(labelText: 'Name'),
          controller: _nameController,
          validator: (value) {
            if (value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Number'),
          controller: _numberController,
          validator: (value) {
            if (value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'CVV'),
          controller: _cvvController,
          obscureText: true,
          validator: (value) {
            if (value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Month'),
          controller: _monthController,
          validator: (value) {
            if (value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Year'),
          controller: _yearController,
          validator: (value) {
            if (value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        TextFormField(
          decoration: InputDecoration(labelText: 'Ammount'),
          controller: _totalAmountController,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
        MaterialButton(
          child: Text('Submit'),
          onPressed: () async {
            try {
              final transaction = await kushki.requestToken(_card);
              print(transaction);
            } catch (e) {
              print(e.toString());
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        )
      ],
    );
  }
}