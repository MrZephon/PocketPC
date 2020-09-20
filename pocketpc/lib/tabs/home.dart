import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketpc/tabs/novo.dart';
import 'package:control_pad/control_pad.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  @override
  HomePage createState() => HomePage();
}

class HomePage extends State<HomeTab> {
  // obtain shared preferences
  var children = <Widget>[];
  FocusNode _textNode = new FocusNode();
  bool _connected = false;
  bool _erro = false;
  bool _disconnected = false;
  int _sens; // sensibilidade
  int _interval =
      10; // intervalo de tempo em milliseconds que os dados são enviados ao pc

  var timer = Container();
  Timer _timer;
  int _initialStart = 5;
  int _start = 5;
  Socket _socket;

  @override
  void initState() {
    load_init_var();
    super.initState();
  }

  @override
  void dispose() {
    SharedPreferences.getInstance().then((prefs) {
      bool _autoconectar = prefs.getBool("_autoconectar") ?? false;
      if(!_autoconectar){
        NovoTab.ip = null;
        _connected = false;
        _disconnected = false;
        prefs.remove("ip");
      }
    });
    _textNode.dispose();
    if (_socket != null) {
      _socket.destroy();
    }
    children = new List<Widget>();
    super.dispose();
  }

  void desconecta() {
    if (_socket != null) {
      _socket.destroy();
    }
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _connected = false;
        _disconnected = false;
      });
    });
  }

  listAdd(List<String> list, item) {
    if (list != null) {
      if (!list.contains(item)) {
        list.insert(0, item);
      } else {
        list.remove(item);
        list.insert(0, item);
      }
    }
    return list;
  }

  Future<bool> saveList(List<String> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList("list", list);
  }

  Future<List<String>> getList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("list");
  }

  void foiDesconectado() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _connected = false;
        _disconnected = true;
        NovoTab.ip = null;
      });
    });
  }

  load_init_var() async {
    if (NovoTab.ip == null && _sens == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        NovoTab.ip = prefs.getString('ip') ?? null;
        _sens = prefs.getInt("_sens") ?? 10;
      });
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _sens = prefs.getInt("_sens") ?? 10;
    }
  }

  void connect(ip) async {
    await Socket.connect(ip, 3000).then((Socket sock) {
      // Se conseguiu conectar
      _socket = sock;
      _socket.handleError((onError) {
        foiDesconectado();
      });
      SharedPreferences.getInstance().then((prefs) {
        List<String> listlastsIp;
        getList().then((value) {
          if (value != null) {
            listlastsIp = value;
          } else {
            listlastsIp = new List<String>();
          }
          listlastsIp = listAdd(listlastsIp, ip);
          saveList(listlastsIp);
        });

        prefs.setString("ip", ip);
        prefs.setInt("_sens", 10);
        setState(() {
          _socket = sock;
          _connected = true;
        });
      });
    }).catchError((Object e) {
      setState(() {
        _erro = true;
        desconecta();
      });
    });

    try {
      // Se conectou e terminou normalmente
      await _socket.done;
      _socket.destroy();
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove("ip");
      });
      setState(() {
        _connected = false;
        NovoTab.ip = null;
      });
      print('Socket done');
    } on SocketException catch (error) {
      // Se conectou e foi desconectado
      foiDesconectado();
      print('Socket done with error $error');
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_erro) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            child: new Center(
                child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                new Text("Não foi possivel conectar ao IP"),
                new RaisedButton(
                  color: Color.fromRGBO(99, 0, 245, 1),
                  textColor: Colors.white,
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if the form is invalid.
                    setState(() {
                      _erro = false;
                      desconecta();
                    });
                  },
                  child: Text('Voltar'),
                ),
              ],
            )),
          ));
    }

    SharedPreferences.getInstance().then((prefs) {
      bool _autoconectar = prefs.getBool("_autoconectar") ?? false;

      if (NovoTab.ip != null && _connected == false && _autoconectar == false || NovoTab.ip != null && _connected == false && _autoconectar == true) {
        connect(NovoTab.ip);
        // Conecta aqui

        if (!_erro) {
          return Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                  child: new Center(
                child: new SizedBox(
                  height: 50.0,
                  width: 50.0,
                  child: new CircularProgressIndicator(
                    value: null,
                    strokeWidth: 7.0,
                  ),
                ),
              )));
        }
      }
    });

    if (!_connected && !_disconnected) {
      // Se não tá conectado e ainda n conectou

      List<String> listlastsIp;
      SharedPreferences.getInstance().then((prefs) {
        bool _salvar = prefs.getBool("_salvar") ?? false;

        if (_salvar) {
          getList().then((value) {
            if (value != null) {
              listlastsIp = value;
            } else {
              listlastsIp = new List<String>();
            }

            var localChildren = new List<Widget>();
            for (var i = 0; i < listlastsIp.length; i++) {
              localChildren.add(
                new InkWell(
                  onTap: () {
                    connect(listlastsIp[i]);
                  },
                  child: new Container(
                    padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.devices,
                                size: 50.0,
                                color: Colors.black,
                              ),
                            ),
                            new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new Text(
                                  "TEST-PC",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                                new Text(
                                  listlastsIp[i],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(
                          Icons.arrow_right,
                          size: 50.0,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            setState(() {
              children = localChildren;
            });
          });
        } else {
          children = List<Widget>();
          children.add(
            new Container(
              height: 200,
              alignment: Alignment.center,
              child: new Center(
                child: new Text(
                  "Você não está exibindo as ultimas conexões",
                  textScaleFactor: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
      });
      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 50.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Conecte-se a um computador",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 40),
                    child: Icon(
                      Icons.add_circle_outline,
                      size: 160.0,
                      color: Colors.black,
                    ),
                  ),
                  Divider(color: Colors.black),
                  Column(
                    children: children,
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else if (_connected && !_disconnected) {
      // Se tá conectado
      JoystickDirectionCallback onDirectionChanged(
          double degrees, double distance) {
        if (distance == 0) {
          var json = jsonEncode({"distance": "stop"});
          _socket.write(json);
        } else {
          var json = jsonEncode({
            "distance": (distance * _sens).toStringAsFixed(2),
            "degree": (degrees - 90).toStringAsFixed(2)
          });
          _socket.write(json);
        }
      }

      final keyboard = TextEditingController();
      String lastValue = "";
      return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                            color: Color.fromRGBO(99, 0, 245, 1),
                            textColor: Colors.white,
                            onPressed: () {
                              desconecta();
                            },
                            child: Text('Desconectar'))
                      ],
                    )),
                Center(
                  child: Column(
                    children: [
                      JoystickView(
                          size: 300,
                          onDirectionChanged: onDirectionChanged,
                          interval: new Duration(milliseconds: _interval),
                          showArrows: false),
                      Padding(
                          padding: EdgeInsets.only(top: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                  color: Color.fromRGBO(99, 0, 245, 1),
                                  textColor: Colors.white,
                                  onPressed: () {
                                    // Validate will return true if the form is valid, or false if the form is invalid.
                                    var json = jsonEncode({"click": true});
                                    _socket.write(json);
                                  },
                                  child: Text('Click')),
                            ],
                          )),
                      Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: RawKeyboardListener(
                          child: TextField(
                            controller: keyboard,
                            keyboardType: TextInputType.text,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Abrir teclado',
                            ),
                            onSubmitted: (value) {
                              keyboard.clear();
                              // Envia enter
                              var json = jsonEncode({"text": "enter"});
                              _socket.write(json);
                            },
                            onChanged: (value) {
                              if (value.length < lastValue.length) {
                                // envia backspace
                                var json = jsonEncode({"text": "backspace"});
                                _socket.write(json);
                              } else {
                                // envia ultima letra
                                var letter = value.substring(
                                    value.length - 1, value.length);
                                var json = jsonEncode({"text": letter});
                                _socket.write(json);
                              }
                              lastValue = value;
                              // Envia enter
                            },
                          ),
                          focusNode: FocusNode(),
                          onKey: (RawKeyEvent event) {
                            print(event.data.logicalKey.keyId);
                          },
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
    } else if (_disconnected) {
      // Se estava conectado e foi desconectado

      SharedPreferences.getInstance().then((prefs) {
        bool _reconectar = prefs.getBool("_reconectar") ?? false;
        if (_reconectar) {
          const oneSec = const Duration(seconds: 1);
          _timer = new Timer.periodic(
            oneSec,
            (Timer timer) => setState(
              () {
                if (_start < 1) {
                  _start = _initialStart;
                  timer.cancel();
                  _timer.cancel();
                  connect(prefs.getString("ip"));
                } else {
                  _start = _start - 1;
                }
              },
            ),
          );
          timer = Container(child: new Text("Tentando reconectar novamente"));
        } else {
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove("ip");
          });
        }
      });

      return Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            child: new Center(
                child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                new Text(
                  "Você foi desconectado...",
                  textScaleFactor: 2,
                ),
                timer,
                new RaisedButton(
                  color: Color.fromRGBO(99, 0, 245, 1),
                  textColor: Colors.white,
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if the form is invalid.
                    setState(() {
                      _disconnected = false;
                      _connected = false;
                    });
                  },
                  child: Text('Voltar'),
                ),
              ],
            )),
          ));
    }
  }
}
