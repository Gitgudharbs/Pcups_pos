import 'package:flutter/material.dart';
import 'package:flutterfirst/splashScreen.dart';
import 'package:flutterfirst/sqlite/transaction_product.dart';
import 'package:sqflite/sqlite_api.dart';
import 'sqlite/transaction.dart';
import 'dart:async';
import 'sqlite/db_helper.dart';
import 'package:intl/intl.dart';
import 'constants.dart' as Constants;

class TransactionsPage extends StatefulWidget {
  final String date;

  TransactionsPage(this.date);

  //TransactionsPage({Key key, this.date}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TransactionsPageState();
  }
}

class _TransactionsPageState extends State<TransactionsPage> {
  //
  Future<List<Ts>> transactions;
  Future<List<Tp>> transactionsProduct;
  Future<double> daily;
  TextEditingController controllerTotal = TextEditingController();
  TextEditingController controllerTall = TextEditingController();
  TextEditingController controllerShort = TextEditingController();
  double total;
  String curDate;
  String date;
  int tall;
  int short;
  int curUserId;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;
  double s;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
  }

  refreshList() {
    setState(() {
      DateTime now = DateTime.now();
      //curDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);
      curDate = widget.date;
      transactions = dbHelper.getTransactions(curDate);
      daily = dbHelper.getDailySales(curDate);
    });
  }

  clearText() {
    controllerTotal.text = '';
    controllerShort.text = '';
    controllerTall.text = '';
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();

      if (isUpdating) {
        print(curUserId.toString() + " " + total.toString());
        Ts e = Ts(curUserId, total, tall, short, date);

        dbHelper.transactionUpdate(e);
      } else {
        Ts e = Ts(null, total, tall, short, date);
        dbHelper.transactionCreate(e);
      }
      clearText();
      refreshList();
      Navigator.pop(context);
    }
  }

  updateForm() {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Update Transaction Details',
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.0)),
        actions: <Widget>[],
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              TextFormField(
                controller: controllerTall,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Tall cups'),
                validator: (val) => val.length == 0 ? 'Enter Number' : null,
                onSaved: (val) => tall = int.parse(val),
              ),
              TextFormField(
                controller: controllerShort,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Short cups'),
                validator: (val) => val.length == 0 ? 'Enter Number' : null,
                onSaved: (val) => short = int.parse(val),
              ),
              TextFormField(
                controller: controllerTotal,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Total'),
                validator: (val) => val.length == 0 ? 'Enter Number' : null,
                onSaved: (val) => total = double.parse(val),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FlatButton(
                    onPressed: validate,
                    child: Text('UPDATE'),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        isUpdating = false;
                      });
                      clearText();
                    },
                    child: Text('CLEAR'),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  transactionDetail(List<Tp> tp) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Transaction Details',
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.0)),
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: DataTable(
            columnSpacing: 50,
            //sortColumnIndex:0,
            //sortAscending: true,
            columns: [
              DataColumn(
                label: Text("PRODUCT", style: Constants.textStyle),
              ),
              DataColumn(
                numeric: true,
                label: Text('QUANTITY', style: Constants.textStyle),
              ),
              DataColumn(
                label: Text('PRICE', style: Constants.textStyle),
                numeric: true,
              ),
              DataColumn(
                label: Text('TOTAL', style: Constants.textStyle),
              ),
            ],
            rows: tp
                .map(
                  (tp) => DataRow(cells: [
                    DataCell(
                      Text(tp.name),
                    ),
                    DataCell(
                      Text(tp.quantity.toString()),
                    ),
                    DataCell(
                      Column(
                        children: <Widget>[
                          if (tp.discount == 0)
                            SizedBox(
                              height: 15,
                            )
                          else
                            SizedBox(
                              height: 7,
                            ),
                          if (tp.discount > 0)
                            Text("₱ " + tp.price.toStringAsFixed(2),
                                style: TextStyle(
                                    decoration: tp.discount > 0
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          Text(
                            "₱ " +
                                (tp.price * (100 - tp.discount) / 100)
                                    .toStringAsFixed(2),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Column(
                        children: <Widget>[
                          if (tp.discount == 0)
                            SizedBox(
                              height: 15,
                            )
                          else
                            SizedBox(
                              height: 7,
                            ),
                          if (tp.discount > 0)
                            Text(
                                "₱ " +
                                    (tp.price * tp.quantity).toStringAsFixed(2),
                                style: TextStyle(
                                    decoration: tp.discount > 0
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400)),
                          Text(
                            "₱ " +
                                ((tp.price * (100 - tp.discount) / 100) *
                                        tp.quantity)
                                    .toStringAsFixed(2),
                          ),
                        ],
                      ),
                    ),
                  ]),
                )
                .toList(),
          ),
        ),

/*          Text(
              "\₱ 100",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
            ),*/
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height / 8,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              " ${returnTotalAmount(tp)}",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 23),
            ),
          ),
        ),
        elevation: 0,
      ),
    );
  }

  String returnTotalAmount(List<Tp> tp) {
    double total = 0;
    for (int i = 0; i < tp.length; i++) {
      total += tp[i].quantity * (tp[i].price * (100 - tp[i].discount) / 100);
    }
    return "Total :  " + "₱ " + total.toStringAsFixed(2);
  }

  SingleChildScrollView dataTable(List<Ts> transactions) {
    int id = transactions.length + 1;
    getDetail(Ts transaction) {
      transactionsProduct = dbHelper.getTp(transaction.id);
      Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => FutureBuilder(
              future: transactionsProduct,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return transactionDetail(snapshot.data);
                }

                if (null == snapshot.data || snapshot.data.length == 0) {
                  return SplashScreen();
                }

                return CircularProgressIndicator();
              },
            ),
            fullscreenDialog: false,
          ));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: FittedBox(
        child: DataTable(
          //columnSpacing: 10,
          columns: [
            DataColumn(
              label: Text("ID",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text("TIME",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              numeric: true,
              label: Text("TALL",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              numeric: true,
              label: Text("SHORT",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              numeric: true,
              label: Text("TOTAL",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              numeric: true,
              label: Text("EDIT",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              numeric: true,
              label: Text("DELETE",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
          ],
          rows: transactions
              .map(
                (transaction) => DataRow(cells: [
                  DataCell(
                    Text(() {
                      id--;
                      return id.toString();
                      // your code here
                    }()),
                    onTap: () {
                      getDetail(transaction);
                    },
                  ),
                  DataCell(
                    Text(transaction.date.toString().substring(13)),
                    onTap: () {
                      getDetail(transaction);
                    },
                  ),
                  DataCell(
                    Text(transaction.tall.toString()),
                    onTap: () {
                      getDetail(transaction);
                    },
                  ),
                  DataCell(
                    Text(transaction.short.toString()),
                    onTap: () {
                      getDetail(transaction);
                    },
                  ),
                  DataCell(Text("₱ " + transaction.total.toStringAsFixed(2)),
                      onTap: () {
                    getDetail(transaction);
                  }),
                  DataCell(Icon(Icons.edit), onTap: () {
                    setState(() {
                      isUpdating = true;
                      curUserId = transaction.id;
                      date=transaction.date;
                      controllerTotal.text = transaction.total.toStringAsFixed(2);
                      controllerTall.text = transaction.tall.toString();
                      controllerShort.text = transaction.short.toString();
                    });

                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                          builder: (BuildContext context) => updateForm(),
                          fullscreenDialog: true,
                        ));
                  }),
                  DataCell(Icon(Icons.delete), onTap: () {
                    _showDialog(context, transaction.id);
                  }),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, int id) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Delete Confirmation"),
          //content: new Text("Alert Dialog body"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Confirm"),
              onPressed: () async {
                dbHelper.transactionDelete(id);
                refreshList();
                Navigator.of(context).pop();
                 },
            ),
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: transactions,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }

          if (null == snapshot.data || snapshot.data.length == 0) {
            return CircularProgressIndicator();
           // return SplashScreen();
          }
          //return Text("No Transactions found");
          return CircularProgressIndicator();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Transactions',
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.0)),
        actions: <Widget>[],
      ),
      body: Center(
        child: Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              list(),
              //Bottom total
              //dailyTotal(),
/*              Text((() {
                refreshList();
                  return date;


              })())*/
            ],
          ),
        ),
      ),
/*      floatingActionButton: FloatingActionButton(
        onPressed: () {
          clearText();
          refreshList();
          isUpdating = false;
          Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => form(),
            fullscreenDialog: true,
          ));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),*/
    );
  }

  Container dailyTotal() {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(25),
      child: FutureBuilder(
        future: daily,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
              "Total : ₱ " + snapshot.data.toStringAsFixed(2),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 23),
            );
          }

          return Text("");
        },
      ),
    );
  }
}
