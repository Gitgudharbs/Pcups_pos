import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterfirst/splashScreen.dart';
import 'sqlite/product.dart';
import 'dart:async';
import 'sqlite/db_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'constants.dart' as Constants;

class ProductsPage extends StatefulWidget {
  final String title;

  ProductsPage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage> {
  //
  Future<List<Product>> products;
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();

  String name;
  String size;
  String category;
  double price;
  int curUserId;

  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;
    size = "None";
    category = "Drinks";
    refreshList();
  }

  refreshList() {
    setState(() {
      //products = dbHelper.getProducts();
      products = dbHelper.getProductsCategory("Drinks");
    });
  }

  getList(String category) {
    setState(() {
      products = dbHelper.getProductsCategory(category);
    });
  }

  clearText() {
    controllerName.text = '';
    controllerPrice.text = '';
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Product e = Product(curUserId, name, size, category, price, 1);
        dbHelper.productUpdate(e);
        setState(() {
          isUpdating = false;
        });
      } else {
        Product e;
        if (category == "Others")
          e = Product(null, name, size, category, price * -1, 1);
        else
          e = Product(null, name, size, category, price, 1);
        dbHelper.productCreate(e);
      }
      clearText();
      refreshList();
      isUpdating = false;
      Navigator.pop(context);
    }
  }

  form() {
    var _sizes = ["None", "Short", "Tall"];
    var _categories = ["Drinks", "Addons", "Snacks", "Others"];

    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Product',
            style: TextStyle(
                fontFamily: 'Montserrat',
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15.0)),
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                TextFormField(
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(30),
                  ],
                  controller: controllerName,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (val) => val.length == 0 ? 'Enter Name' : null,
                  onSaved: (val) => name = val,
                ),
                TextFormField(
                  controller: controllerPrice,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                  validator: (val) => val.length == 0 ? 'Enter Price' : null,
                  onSaved: (val) => price = double.parse(val),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  // Align however you like (i.e .centerRight, centerLeft)
                  child: Text("Category"),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            //labelStyle: textStyle,
                            errorStyle: TextStyle(
                                color: Colors.redAccent, fontSize: 16.0),
                            //hintText: 'Please select expense',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        //isEmpty: category == 'Drinks',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: category,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                category = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _categories.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  // Align however you like (i.e .centerRight, centerLeft)
                  child: Text("Size"),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                            //labelStyle: textStyle,
                            errorStyle: TextStyle(
                                color: Colors.redAccent, fontSize: 16.0),
                            //hintText: 'Please select expense',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        //isEmpty: size == 'None',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: size ?? "None",
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                size = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _sizes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FlatButton(
                      onPressed: validate,
                      child: Text(isUpdating ? 'UPDATE' : 'ADD'),
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
      ),
    );
  }

  StreamBuilder<List<Product>> Products(List<Product> products) {
    return StreamBuilder(
      stream: null,
      builder: (context, AsyncSnapshot<List<Product>> snapshot) {
        final tasks = snapshot.data ?? List();
        return ListView.separated(
          itemCount: products.length,
          itemBuilder: (_, index) {
            final itemTask = products[index];
            return _buildListItem(itemTask);
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        );
      },
    );
  }

  Widget _buildListItem(Product product) {
    String _setImage() {
      switch (product.size) {
        case "Tall":
          return 'assets/tall.png';
        case "Short":
          return 'assets/short.png';
        default:
          return 'assets/milktea.png';
      }
    }

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => {dbHelper.productDelete(product.id), refreshList()},
        )
      ],
      child: ListTile(
        leading: Container(
            width: 60.0,
            height: 60.0,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                    fit: BoxFit.fill, image: AssetImage(_setImage())))),
        /* Image(
            image: AssetImage('assets/tea.png'),
            fit: BoxFit.cover,
            height: 75.0,
            width: 75.0),*/
        title: Text(product.name,
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 17.0,
                fontWeight: FontWeight.bold)),
        subtitle: Text("₱ " + product.price.toStringAsFixed(2),
            style: TextStyle(
                fontFamily: 'Montserrat', fontSize: 15.0, color: Colors.grey)),

        /*Column(
          children: <Widget>[
            Text("₱ " + product.price.toStringAsFixed(2),
                style: TextStyle(
                    fontFamily: 'Montserrat', fontSize: 15.0, color: Colors.grey)),
            Text(product.size,
                style: TextStyle(
                    fontFamily: 'Montserrat', fontSize: 15.0, color: Colors.grey)),
            Text(product.category,
                style: TextStyle(
                    fontFamily: 'Montserrat', fontSize: 15.0, color: Colors.grey)),

          ],
        ),*/
        trailing: Checkbox(
          activeColor: Constants.bgColor,
          value: (product.isActive == 1),
          onChanged: (bool newValue) {
            setState(() {
              //_value=newValue;
              if (newValue) {
                dbHelper.productUpdate(Product(product.id, product.name,
                    product.size, product.category, product.price, 1));
                refreshList();
              } else {
                dbHelper.productUpdate(Product(product.id, product.name,
                    product.size, product.category, product.price, 0));
                refreshList();
              }
            });
          },
        ),
        onTap: () {
          setState(() {
            isUpdating = true;
            curUserId = product.id;
            controllerName.text = product.name;
            controllerPrice.text = product.price.toStringAsFixed(2);
            size = product.size;
            category = product.category;
          });

          Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => form(),
                fullscreenDialog: true,
              ));
        },
      ),
    );
  }

  list(String category) {
    getList(category);

    return Expanded(
      child: FutureBuilder(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Products(snapshot.data);
            //return dataTable(snapshot.data);
          }

          if (null == snapshot.data || snapshot.data.length == 0) {
            return SplashScreen();
          }

          return CircularProgressIndicator();
        },
      ),
    );
  }

  listAll() {
    return Expanded(
      child: FutureBuilder(
        future: products,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Products(snapshot.data);
            //return dataTable(snapshot.data);
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
    return DefaultTabController(
      length: 4,
      child: new Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Constants.bgColor,
          title: Text('Products',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15.0)),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                clearText();
                refreshList();
                isUpdating = false;
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (BuildContext context) => form(),
                      fullscreenDialog: true,
                    ));
              },
            )
          ],
          bottom: TabBar(
            //indicatorColor: Colors.blue,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white,
            tabs: <Widget>[
              Tab(
                text: "Drinks",
                // icon: Icon(Icons.local_drink),
              ),
              Tab(
                text: "Add-ons",
                //icon: Icon(Icons.beach_access),
              ),
              Tab(
                text: "Snacks",
                //icon: Icon(Icons.fastfood),
              ),
              Tab(
                text: "Others",
                //icon: Icon(Icons.fastfood),
              )
            ],
          ),
        ),
/*      floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
        ),*/
        body: TabBarView(
          children: <Widget>[
            buildCategories("Drinks"),
            buildCategories("Addons"),
            buildCategories("Snacks"),
            buildCategories("Others"),
          ],
        ),
      ),
    );
  }

  Center buildCategories(String category) {
    return Center(
      child: Container(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            list(category),
          ],
        ),
      ),
    );
  }
}
