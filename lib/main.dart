import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=5ddc7d2e";

void main() async => runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
    ));

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  

  var dollar = 0.0;
  var euro = 0.0;
  var btc = 0.0;

  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  final btcController = TextEditingController();

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    var real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    btcController.text = (real / btc).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    var dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
    btcController.text = (dollar * this.dollar / btc).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    var euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
    btcController.text = (euro * this.euro / btc).toStringAsFixed(2);
  }

  void _btcChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    var btc = double.parse(text);
    realController.text = (btc * this.btc).toStringAsFixed(2);
    dollarController.text = (btc * this.btc / dollar).toStringAsFixed(2);
    euroController.text = (btc * this.btc / euro).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
    btcController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('\$ Converssor de Moedas'),
          backgroundColor: Colors.amber,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _clearAll,
            )
          ],
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    'Carregando Dados',
                    style: TextStyle(color: Colors.amber, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar os Dados',
                      style: TextStyle(color: Colors.amber, fontSize: 25),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dollar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];
                  btc = snapshot.data['results']['currencies']['BTC']['buy'];

                  return SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Form(                      
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Icon(
                                Icons.monetization_on,
                                size: 150,
                                color: Colors.amber,
                              ),
                              buildTextField('Reais', 'R\$ ', realController,
                                  _realChanged),
                              buildTextField('Dólares', 'USD ',
                                  dollarController, _dollarChanged),
                              buildTextField(
                                  'Euros', '€ ', euroController, _euroChanged),
                              buildTextField('Bitcoins', 'BTC ', btcController,
                                  _btcChanged),
                            ]),
                      ));
                }
            }
          },
        ));
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function onChanged) {
  return Column(
    children: <Widget>[
      Divider(),
      TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: numberValidator,
        decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Colors.amber,
            ),
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            prefixText: prefix),
        style: TextStyle(color: Colors.amber, fontSize: 25),
        onChanged: onChanged,
      )
    ],
  );
}

String numberValidator(String value) {
  if (value == null) {
    return null;
  }
  final n = double.tryParse(value);
  if (n == null) {
    return '"$value" is not a valid number';
  }
  return null;
}
