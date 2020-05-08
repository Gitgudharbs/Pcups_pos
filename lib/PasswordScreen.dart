import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirst/ProductsPage.dart';
import 'package:flutterfirst/ReportsPage.dart';
import 'package:flutterfirst/TransactionsPage.dart';
import 'package:flutterfirst/sqlite/db_helper.dart';
import 'package:flutterfirst/sqlite/transaction_product.dart';
import 'sqlite/product.dart';
import 'package:flutterfirst/sqlite/transaction.dart';
import 'package:intl/intl.dart';
import 'bloc/cartlistBloc.dart';
import 'bloc/listTileColorBloc.dart';
import 'const/themeColor.dart';
import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:flutkart/utils/flutkart.dart';

class PasswordScreen extends StatefulWidget {
  final String page;

  PasswordScreen(this.page);

  //PasswordScreen({Key key, @required this.page}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Timer(Duration(seconds: 5), () => MyNavigator.goToIntro(context));
  }

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final pwController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordField = TextField(
      controller: pwController,
      obscureText: true,
      style: style,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "Password",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Colors.black87,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: () {
          var day = DateFormat('EEEE').format(DateTime.now());
          if (pwController.text == day) {
            //print(widget.page);
            print("adadad");
            pwController.text = "";
            FocusScope.of(context).unfocus();
            DateTime now = DateTime.now();
            String date = DateFormat('yyyy-MM-dd – kk:mm').format(now);
            if (widget.page == "Transactions")
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => TransactionsPage(date)));
            else
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ReportsPage()));
          } else {
            FocusScope.of(context).unfocus();
            pwController.text = "";
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  // Retrieve the text the user has entered by using the
                  // TextEditingController.
                  // content: Text(pwController.text),
                  title: Text("Wrong Password"),
                );
              },
            );
          }
        },
        child: Text("Login",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: ListView(
              reverse: true,
              //crossAxisAlignment: CrossAxisAlignment.center,
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  child: Image.asset(
                    "assets/pcups.jpeg",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: 25.0),
                passwordField,
                SizedBox(
                  height: 35.0,
                ),
                loginButon,
                SizedBox(
                  height: 15.0,
                ),
              ].reversed.toList(),
            ),
          ),
        ),
      ),
    );
  }
}
