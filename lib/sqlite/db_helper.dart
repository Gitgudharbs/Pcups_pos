import 'dart:async';
import 'dart:io' as io;
import 'package:flutterfirst/sqlite/report.dart';
import 'package:flutterfirst/sqlite/transaction.dart';
import 'package:flutterfirst/sqlite/transaction_product.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'product.dart';
import 'transaction.dart';

class DBHelper {
  static Database _db;
  static const String DB_NAME = 'POS.db';

  static const String PRODUCT_TABLE = 'product';
  static const String PRODUCT_ID = 'id';
  static const String PRODUCT_NAME = 'name';
  static const String PRODUCT_SIZE = 'size';
  static const String PRODUCT_CATEGORY = 'category';
  static const String PRODUCT_PRICE = 'price';
  static const String PRODUCT_ISACTIVE = 'isActive';

  static const String TRANSACTION_TABLE = 'ts';
  static const String TRANSACTION_ID = 'id';
  static const String TRANSACTION_TOTAL = 'total';
  static const String TRANSACTION_TALL = 'tall';
  static const String TRANSACTION_SHORT = 'short';
  static const String TRANSACTION_DATE = 'date';

  static const String TP_TABLE = 'transactionProduct';
  static const String TP_TRANSACTION_ID = 'transactionId';
  static const String TP_PRODUCT_ID = 'productId';
  static const String TP_QUANTITY = 'quantity';
  static const String TP_DISCOUNT = 'discount';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
/*    await deleteDatabase(path);
    await db
        .execute("drop table TRANSACTION_TABLE");*/
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $PRODUCT_TABLE ($PRODUCT_ID "
        "INTEGER PRIMARY KEY, $PRODUCT_NAME TEXT, $PRODUCT_SIZE TEXT, $PRODUCT_CATEGORY TEXT, $PRODUCT_PRICE REAL, $PRODUCT_ISACTIVE INTEGER)");

    await db.execute("CREATE TABLE $TRANSACTION_TABLE ($TRANSACTION_ID "
        "INTEGER PRIMARY KEY, $TRANSACTION_TOTAL REAL, $TRANSACTION_TALL INTEGER, $TRANSACTION_SHORT INTEGER, $TRANSACTION_DATE TEXT)");

    await db.execute("CREATE TABLE $TP_TABLE ($TP_TRANSACTION_ID "
        "INTEGER, $TP_PRODUCT_ID INTEGER, $TP_QUANTITY INTEGER , $TP_DISCOUNT INTEGER)");
  }

  Future<Product> productCreate(Product product) async {
    var dbClient = await db;
    product.id = await dbClient.insert(PRODUCT_TABLE, product.toMap());
    return product;
    /*
    await dbClient.transaction((txn) async {
      var query = "INSERT INTO $TABLE ($NAME) VALUES ('" + product.name + "')";
      return await txn.rawInsert(query);
    });
    */
  }

  Future<List<Product>> getProducts() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(PRODUCT_TABLE,
        columns: [PRODUCT_ID, PRODUCT_NAME, PRODUCT_SIZE, PRODUCT_CATEGORY, PRODUCT_PRICE, PRODUCT_ISACTIVE]);
    List<Product> products = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        products.add(Product.fromMap(maps[i]));
      }
    }
    return products;
  }

  Future<List<Product>> getProductsCategory(String category) async {
    var dbClient = await db;
/*    List<Map> maps = await dbClient.query(PRODUCT_TABLE,
        columns: [PRODUCT_ID, PRODUCT_NAME, PRODUCT_SIZE, PRODUCT_CATEGORY, PRODUCT_PRICE, PRODUCT_ISACTIVE]);*/
    String query="SELECT * FROM $PRODUCT_TABLE WHERE $PRODUCT_CATEGORY = '$category' ";

    //print(query);
    List<Map> maps = await dbClient.rawQuery(query);

    List<Product> products = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        products.add(Product.fromMap(maps[i]));
      }
    }
    return products;
  }

  Future<List<Product>> getProductsList(String category, String size, String name) async {
    var dbClient = await db;
/*    String query="SELECT DISTINCT $PRODUCT_NAME, $PRODUCT_CATEGORY FROM $PRODUCT_TABLE WHERE $PRODUCT_CATEGORY = '$category' "
        "AND $PRODUCT_ISACTIVE=1" ;*/
    String query="SELECT * FROM $PRODUCT_TABLE WHERE $PRODUCT_CATEGORY = '$category' AND $PRODUCT_ISACTIVE=1 ";
        if(size=="Tall")
      query+=" AND $PRODUCT_SIZE='Tall'";
        else if(size=="Short")
          query+=" AND $PRODUCT_SIZE='Short'";

      query+=" AND $PRODUCT_NAME LIKE '%$name%'";

    //print(query);
    List<Map> maps = await dbClient.rawQuery(query);

    List<Product> products = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        products.add(Product.fromMap(maps[i]));
      }
    }
    return products;
  }

  Future<List<Product>> getActiveProducts() async {
    var dbClient = await db;
    //List<Map> maps = await dbClient.query(PRODUCT_TABLE, columns: [PRODUCT_ID, PRODUCT_NAME, PRODUCT_PRICE, PRODUCT_ISACTIVE]);
    List<Map> maps = await dbClient.rawQuery("SELECT * FROM $PRODUCT_TABLE "
        "WHERE $PRODUCT_ISACTIVE=1");
    List<Product> products = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        products.add(Product.fromMap(maps[i]));
      }
    }
    return products;
  }

  Future<int> productUpdate(Product product) async {
    var dbClient = await db;
    return await dbClient.update(PRODUCT_TABLE, product.toMap(),
        where: '$PRODUCT_ID = ?', whereArgs: [product.id]);
  }

  Future<int> productDelete(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(PRODUCT_TABLE, where: '$PRODUCT_ID = ?', whereArgs: [id]);
  }

  //Transactions CRUD

  Future<Ts> transactionCreate(Ts transaction) async {
    var dbClient = await db;
    transaction.id =
        await dbClient.insert(TRANSACTION_TABLE, transaction.toMap());

    return transaction;
  }

  Future<int> transactionUpdate(Ts transaction) async {
    var dbClient = await db;
    return await dbClient.update(TRANSACTION_TABLE, transaction.toMap(),
        where: '$TRANSACTION_ID = ?', whereArgs: [transaction.id]);
  }

  Future<int> transactionDelete(int id) async {
    var dbClient = await db;
    return await dbClient
        .delete(TRANSACTION_TABLE, where: '$TRANSACTION_ID = ?', whereArgs: [id]);
  }

  Future<List<Report>> getReport(String date) async {
    var dbClient = await db;
    //List<Map> maps = await dbClient.query(TRANSACTION_TABLE, columns: [TRANSACTION_ID, TRANSACTION_TOTAL, TRANSACTION_DATE], orderBy: TRANSACTION_ID);
    date =date.substring(0,7);
    String query ="SELECT substr($TRANSACTION_DATE,0,11) as day, COUNT(1) as transactions, SUM($TRANSACTION_TOTAL) as total "
        ", SUM($TRANSACTION_TALL) as tall, SUM($TRANSACTION_SHORT)  as short"
        " FROM $TRANSACTION_TABLE t "
        " GROUP BY substr($TRANSACTION_DATE,9,2)"
        " HAVING $TRANSACTION_DATE LIKE '%$date%' ";

    List<Map> maps = await dbClient.rawQuery(query);
    List<Report> reports = [];
    //print(query);
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        reports.add(Report.fromMap(maps[i]));
      }
    }
    return reports;
  }

  Future<List<Ts>> getTransactions(String date) async {
    var dbClient = await db;
    //List<Map> maps = await dbClient.query(TRANSACTION_TABLE, columns: [TRANSACTION_ID, TRANSACTION_TOTAL, TRANSACTION_DATE], orderBy: TRANSACTION_ID);
    date =date.substring(0,10);
    String query ="SELECT $TRANSACTION_ID, $TRANSACTION_TOTAL, $TRANSACTION_TALL , $TRANSACTION_SHORT , $TRANSACTION_DATE  "
        " FROM $TRANSACTION_TABLE t "
        " WHERE $TRANSACTION_DATE LIKE '%$date%' "
        "order by $TRANSACTION_ID desc";

    List<Map> maps = await dbClient.rawQuery(query);
    List<Ts> transactions = [];
    print (query);
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        transactions.add(Ts.fromMap(maps[i]));
      }
    }
    return transactions;
  }

  Future<double> getDailySales(String date) async {
    var dbClient = await db;
   // var total = ( await dbClient.rawQuery("SELECT SUM(total) as daily FROM $TRANSACTION_TABLE"))[0]['daily'];
    date =date.substring(0,10);
    var total = ( await dbClient.rawQuery("SELECT SUM(total) as daily FROM $TRANSACTION_TABLE "
        "WHERE $TRANSACTION_DATE LIKE '%$date%' "))[0]['daily'];
    return Future.value(total);
  }

  Future<double> getMonthlySales(String date) async {
    var dbClient = await db;
    // var total = ( await dbClient.rawQuery("SELECT SUM(total) as daily FROM $TRANSACTION_TABLE"))[0]['daily'];
    print(date);
    date =date.substring(0,7);
    var total = ( await dbClient.rawQuery("SELECT SUM(total) as daily FROM $TRANSACTION_TABLE "
        "WHERE $TRANSACTION_DATE LIKE '%$date%' "))[0]['daily'];
    return Future.value(total);
  }

  Future<int> transactionsUpdate(Ts transactions) async {
    var dbClient = await db;
    return await dbClient.update(TRANSACTION_TABLE, transactions.toMap(),
        where: '$TRANSACTION_ID = ?', whereArgs: [transactions.id]);
  }

  Future<int> transactionsDelete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TRANSACTION_TABLE,
        where: '$TRANSACTION_ID = ?', whereArgs: [id]);
  }

  //TP CRUD

  Future<Tp> tpCreate(Tp tp) async {
    var dbClient = await db;
    await dbClient
        .execute("CREATE TABLE IF NOT EXISTS $TP_TABLE ($TP_TRANSACTION_ID "
            "INTEGER, $TP_PRODUCT_ID INTEGER, $TP_QUANTITY INTEGER , $TP_DISCOUNT INTEGER)");
    tp.transactionId = await dbClient.insert(TP_TABLE, tp.toMap());

    return tp;
  }

  Future<List<Tp>> getTp(int id) async {
    var dbClient = await db;
    //List<Map> maps = await dbClient.query(TP_TABLE, columns: [TP_TRANSACTION_ID, TP_PRODUCT_ID, TP_QUANTITY]);
    List<Map> maps = await dbClient.rawQuery(
        "SELECT $TP_TRANSACTION_ID, name, $TP_PRODUCT_ID, $TP_QUANTITY, $TP_DISCOUNT, $PRODUCT_PRICE "
        " FROM $TP_TABLE tp Inner join $PRODUCT_TABLE p on tp.productId=p.id"
        " WHERE $id=$TP_TRANSACTION_ID");
    List<Tp> tp = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        tp.add(Tp.fromMap(maps[i]));
      }
    }
    return tp;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
