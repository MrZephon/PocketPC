import 'package:flutter/material.dart';
import 'package:pocketpc/tabs/home.dart';
import 'package:pocketpc/tabs/novo.dart';
import 'package:pocketpc/tabs/opcoes.dart';

void main() {
  runApp(MaterialApp(
      title: "PocketPC",
      home: MyHome()));
}

class MyHome extends StatefulWidget {
  @override
  MyHomeState createState() => MyHomeState();
}

class MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Container(
                margin: const EdgeInsets.only(right: 5.0),
                child: new Icon(Icons.desktop_windows)),
            Text('PocketPC')
          ],
        ),
        backgroundColor: Color.fromRGBO(99, 0, 245, 1),
      ),


      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[HomeTab(), NovoTab(controller), OpcoesTab()],
        controller: controller,
      ),


      bottomNavigationBar: Material(
        color: Color.fromRGBO(99, 0, 245, 1),
        child: TabBar(
          tabs: <Tab>[
            Tab(
              // set icon to the tab
              icon: Icon(Icons.home),
              text: ("Home"),
            ),
            Tab(
              icon: Icon(Icons.add),
              text: ("Novo"),
            ),
            Tab(
              icon: Icon(Icons.settings),
              text: ("Opções"),
            )
          ],
          controller: controller,
        ),
      ),

      
    );
  }
}
