import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpcoesTab extends StatefulWidget {
  @override
  _CheckBoxState createState() => new _CheckBoxState();
}

class _CheckBoxState extends State<OpcoesTab> {
  bool _reconectar = false;
  bool _salvar = false;
  bool _autoconectar = false;

  @override
  void initState() {
    load_init_var();
    super.initState();
  }

  load_init_var() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _reconectar   = prefs.getBool('_reconectar') ?? false;
        _salvar       = prefs.getBool('_salvar') ?? false;
        _autoconectar = prefs.getBool("_autoconectar") ?? false;
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: 10.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: Row(
                children: [
                  Text(
                    "Configurações",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            CheckboxListTile(
              title: Text(
                "Reconectar automaticamente",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600),
              ),
              activeColor: Color.fromRGBO(99, 0, 245, 1),
              onChanged: (bool resp) {
                setState(() {
                  _reconectar = resp;
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool("_reconectar", _reconectar);
                  });
                });
              },
              value: _reconectar,
            ),
            CheckboxListTile(
              title: Text(
                "Exibir ultimas conexões",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600),
              ),
              activeColor: Color.fromRGBO(99, 0, 245, 1),
              onChanged: (bool resp) {
                setState(() {
                  _salvar = resp;
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool("_salvar", _salvar);
                  });
                });
              },
              value: _salvar,
            ),
            CheckboxListTile(
              title: Text(
                "Manter sessão",
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600),
              ),
              activeColor: Color.fromRGBO(99, 0, 245, 1),
              onChanged: (bool resp) {
                setState(() {
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool("_autoconectar", _autoconectar);
                  });
                  _autoconectar = resp;
                });
              },
              value: _autoconectar,
            ),
          ],
        ),
      ),
    );
  }
}
