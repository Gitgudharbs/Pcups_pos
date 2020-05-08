import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirst/ProductsPage.dart';
import 'package:flutterfirst/TransactionsPage.dart';
import 'package:flutterfirst/splashScreen.dart';
import 'package:flutterfirst/sqlite/report.dart';
import 'package:flutterfirst/sqlite/transaction_product.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqlite_api.dart';
import 'sqlite/transaction.dart';
import 'dart:async';
import 'sqlite/db_helper.dart';
import 'package:intl/intl.dart';
import 'constants.dart' as Constants;

class ReportsPage extends StatefulWidget {
  final String title;

  ReportsPage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReportsPageState();
  }
}

class _ReportsPageState extends State<ReportsPage> {
  //
  Future<List<Report>> report;
  Future<double> monthly;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  double total;
  String date;
  String month;
  int curUserId;
  DateTime now;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;
  double s;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    var lastDayDateTime = (now.month < 12) ? new DateTime(now.year, now.month + 1, 0) : new DateTime(now.year + 1, 1, 0);
    dbHelper = DBHelper();
    isUpdating = false;
    refreshList();
    if(now.day==lastDayDateTime.day)
      generateCSV(context);

  }

  refreshList() {
    setState(() {
      now = DateTime.now();
      date = DateFormat('yyyy-MM-dd').format(now);
      month = DateFormat('yMMMM').format(now);
      report = dbHelper.getReport(date);
      monthly = dbHelper.getMonthlySales(date);
    });
  }

  clearText() {
    controllerName.text = '';
    controllerPrice.text = '';
  }

  String returnTotalAmount(List<Tp> tp) {
    double total = 0;
    for (int i = 0; i < tp.length; i++) {
      total += tp[i].quantity * (tp[i].price * (100 - tp[i].discount) / 100);
    }
    return "Total :  " + "₱ " + total.toStringAsFixed(2);
  }

  SingleChildScrollView dataTable(List<Report> reports) {
    int id = 0;

    transactionList(Report report) {
      Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => TransactionsPage(report.day),
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
              label: Text("DAY",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text("#",
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
          ],
          rows: reports
              .map(
                (report) => DataRow(cells: [
                  DataCell(
                    Text(report.day.substring(8, 10)),
                    onTap: () {
                      transactionList(report);
                    },
                  ),
                  DataCell(
                    Text(report.transactions.toString()),
                    onTap: () {
                      transactionList(report);
                    },
                  ),
                  DataCell(
                    Text(report.tall.toString()),
                    onTap: () {
                      transactionList(report);
                    },
                  ),
                  DataCell(
                    Text(report.short.toString()),
                    onTap: () {
                      transactionList(report);
                    },
                  ),
                  DataCell(Text("₱ " + report.total.toStringAsFixed(2)),
                      onTap: () {
                    transactionList(report);
                  }),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: report,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }

          if (null == snapshot.data || snapshot.data.length == 0) {
            return SplashScreen();
          }

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
        title: Text(month + ' Reports',
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.0)),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              generateCSV(context);
              _showDialog();
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              list(),
              monthlyTotal(),
/*              Text((() {
                refreshList();
                  return date;


              })())*/
            ],
          ),
        ),
      ),
    );
  }
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Successfully Exported"),
          content: new Text('Report_'+date+'.csv'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> generateCSV(context) async {

    List<Report> reportData = await dbHelper.getReport(date);
    List<List<String>> csvData = [
      // headers
      <String>['day', 'total', 'tall', 'short', 'transaction'],
      // data
      ...reportData.map((item) => [item.day, item.total.toString(),
        item.tall.toString(), item.short.toString(), item.transactions.toString()]),
    ];


    String csv = const ListToCsvConverter().convert(csvData);

    //final String dir = (await getApplicationDocumentsDirectory()).path;
    final String dir = (await getExternalStorageDirectory()).path;


    final String path = '$dir/Report_'+date+'.csv';

    print(path);
    // create file
    final File file = File(path);

    await file.writeAsString(csv);
  }


  Container monthlyTotal() {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(25),
      child: FutureBuilder(
        future: monthly,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(
              "₱ " + snapshot.data.toStringAsFixed(2),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            );
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }
}
