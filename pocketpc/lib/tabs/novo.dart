import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NovoTab extends StatelessWidget {

  static String ip;

  TabController _tabController; 
  NovoTab(TabController controller){
    _tabController = controller;
  }
  
  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Center(
          child: Column(
            // center the children
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "ADICIONAR",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Text(
                    "Execute o programa no computador de destino e espere até a mensagem de 'Pronto para uso' ser exibida",
                    style: TextStyle(color: Colors.grey[500], fontSize: 17.5),
                    textAlign: TextAlign.center,
                  )),
              Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Text(
                    "Insira então o IP do computador abaixo",
                    style: TextStyle(color: Colors.grey[500], fontSize: 17.5),
                    textAlign: TextAlign.center,
                  )),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Insira o IP do computador',
                      ),
                      validator: (value) {
                        String pattern = r'\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b';
                        RegExp regExp = new RegExp(pattern);
                        if (value.isEmpty || !regExp.hasMatch(value)) {
                          return 'Insira algum IP válido';
                        }
                        ip = value;
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: RaisedButton(
                        color: Color.fromRGBO(99, 0, 245, 1),
                        textColor: Colors.white,
                        onPressed: () {
                          // Validate will return true if the form is valid, or false if the form is invalid.
                          if (_formKey.currentState.validate()) {
                            _tabController.index = 0;
                            _tabController.animateTo(0);
                            FocusScope.of(context).unfocus();
                          }
                        },
                        child: Text('Conectar'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
