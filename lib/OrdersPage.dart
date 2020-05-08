import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutterfirst/ProductsPage.dart';
import 'package:flutterfirst/splashScreen.dart';
import 'package:flutterfirst/sqlite/product.dart';
import 'bloc/listTileColorBloc.dart';
import 'bloc/cartlistBloc.dart';
import 'cart.dart';
import 'const/themeColor.dart';
import 'package:flutterfirst/sqlite/db_helper.dart';
import 'constants.dart' as Constants;

import 'constants.dart';

class OrdersPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Home();
  }
}

class Home extends State<OrdersPage> {
  Future<List<Product>> drinksTall;
  Future<List<Product>> drinksShort;
  Future<List<Product>> addons;
  Future<List<Product>> snacks;
  Future<List<Product>> others;
  TextEditingController controllerNote = TextEditingController();
  TextEditingController controllerDiscount = TextEditingController();
  TextEditingController controllerFilter = new TextEditingController();
  Future<List<Product>> filteredDrinksTall;
  final formKey = new GlobalKey<FormState>();
  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

  //search bar
  String _searchText = "";
  Icon _searchIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  Widget _appBarTitle;

  String note;
  String sugarLevel;
  int discount;
  var dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    note = "";
    sugarLevel = "100";
    discount = 0;
    refreshList();

    controllerFilter.addListener(() {
      setState(() {
        _searchText = controllerFilter.text;
      });
    });
  }

  @override
  void dispose() {
    controllerFilter.dispose();
    super.dispose();
  }

  void clearText() {
    controllerNote.text = "";
    controllerDiscount.text = "0";
  }

  refreshList() {
    setState(() {
      drinksTall = dbHelper.getProductsList("Drinks", "Tall", _searchText);
      drinksShort = dbHelper.getProductsList("Drinks", "Short", _searchText);
      addons = dbHelper.getProductsList("Addons", "", _searchText);
      snacks = dbHelper.getProductsList("Snacks", "", _searchText);
      others = dbHelper.getProductsList("Others", "", _searchText);
      filteredDrinksTall = drinksTall;
      _appBarTitle = new Text('Search...',
          style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15.0));
      //products = dbHelper.getActiveProducts();
      bloc.clearList();
    });
  }

  refreshAppbar() {
    setState(() {
      filteredDrinksTall = drinksTall;

      _appBarTitle = new Text('Search...',
          style: TextStyle(
              fontFamily: 'Montserrat',
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15.0));
      //products = dbHelper.getActiveProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Container(
        child: DefaultTabController(
          length: 5,
          child: Scaffold(
            backgroundColor: Constants.bgColor,
            body: Column(
              children: <Widget>[
                SizedBox(height: 13),
                Padding(
                  padding: const EdgeInsets.fromLTRB(35, 15, 0, 0),
                  child: Column(
                    children: <Widget>[
                      CustomAppBar(),
                      //you could also use the spacer widget to give uneven distances, i just decided to go with a sizebox
                      //SizedBox(height: 30),
                      //SizedBox(height: 30),
                      //searchBar(),
                      //SizedBox(height: 45),
                      //categories(),
                    ],
                  ),
                ),
                //FirstHalf(),
                Container(
                  child: TabBar(
                    //indicatorColor: Colors.blue,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.white,
                    tabs: <Widget>[
                      Tab(
                        text: "Tall",
                        // icon: Icon(Icons.local_drink),
                      ),
                      Tab(
                        text: "Short",
                        // icon: Icon(Icons.local_drink),
                      ),
                      Tab(
                        text: "Addons",
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
                //SizedBox(height: 20.0),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height - 185.0,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: TabBarView(
                      children: <Widget>[
                        orderBody(context, filteredDrinksTall),
                        orderBody(context, drinksShort),
                        orderBody(context, addons),
                        orderBody(context, snacks),
                        orderBody(context, others),
                      ],
                    ),
                  ),
                )
              ],
            ),

            //debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }

  orderBody(BuildContext context, Future<List<Product>> products) {
    return FutureBuilder(
      future: products,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return listProducts(snapshot.data);
        }

        if (null == snapshot.data || snapshot.data.length == 0) {
          return SplashScreen();
          return Text("No Data Found");
        }

        return Text("Error");
      },
    );
  }

  StreamBuilder<List<Product>> listProducts(List<Product> products) {
    return StreamBuilder(
      stream: null,
      builder: (context, AsyncSnapshot<List<Product>> snapshot) {
        //final tasks = snapshot.data ?? List();
        return Padding(
          padding: EdgeInsets.only(top: 15.0),
          child: Container(
              height: MediaQuery.of(context).size.height - 300.0,
              child: RefreshIndicator(
                child: buildList(products, context),
                onRefresh: _getData,
              )),
        );
      },
    );
  }

  ListView buildList(List<Product> products, BuildContext context) {

    if (_searchText.isNotEmpty) {
      List<Product>  tempList = new List();
      for (int i = 0; i < products.length; i++) {
        if (products[i].name.toLowerCase().contains(_searchText.toLowerCase())) {
          tempList.add(products[i]);
        }
      }
      products = tempList;
    }

    return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                primary: false,
                padding: EdgeInsets.only(left: 20.0, right: 20.0),
                itemCount:  products.length,
                itemBuilder: (_, index) {
                  final itemTask = products[index];
                  if (products[index]
                      .name
                      .toLowerCase()
                      .contains(_searchText.toLowerCase()))
                    return _buildListItem(itemTask, context);
                  else
                    return null;
                },
                  separatorBuilder: (context, index) {
                  return Divider();
                },
              );
  }

  Future<void> _getData() async {
    setState(() {
      _searchText = "";
      refreshList();
      bloc.clearList();
    });
  }

  Widget _buildListItem(Product product, BuildContext context) {
    final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

    addToCart(Product product) {
      setState(() {
        bloc.addToList(product);
      });
    }

    removeFromList(Product product) {
      setState(() {
        bloc.removeFromList(product);
      });
    }

    return Padding(
      padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0, bottom: 5),
      child: InkWell(
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                onTap: () {
                  controllerNote.text = product.note;
                  controllerDiscount.text = product.discount.toString();

                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (BuildContext context) => form(product),
                        fullscreenDialog: true,
                      ));
                },
                child: Container(
                    child: Row(children: [
                  Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage('assets/milktea.png')))),
/*                  Image(
                      image: AssetImage('assets/tea.png'),
                      fit: BoxFit.cover,
                      height: 75.0,
                      width: 75.0),*/
                  SizedBox(width: 10.0),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 350,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(product.name,
                                  //overflow: TextOverflow.fade,
                                  // maxLines: 4,
                                  //softWrap: false,
                                  style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        Text("₱ " + product.price.toStringAsFixed(2),
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15.0,
                                color: Colors.grey)),
/*                    Text(product.sugarLevel ,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15.0,
                            color: Colors.grey)),
                    Text(product.discount.toString() ,
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15.0,
                            color: Colors.grey)),
                    Text(product.note +"note",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 15.0,
                            color: Colors.grey)),*/
                      ])
                ])),
              ),
              Container(
                width: 125.0,
                height: 50.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17.0),
                    color: Constants.bgColor),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (product.quantity == 0) removeFromList(product);
                          if (product.quantity > 0) {
                            product.decrementQuantity();
                            if (product.quantity == 0) removeFromList(product);
                          }
                        });
                      },
                      child: Container(
                        height: 35.0,
                        width: 35.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Constants.bgColor),
                        child: Center(
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      ),
                    ),
                    Text(product.quantity.toString(),
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Montserrat',
                            fontSize: 15.0)),
                    InkWell(
                      onTap: () {
                        setState(() {
                          product.incrementQuantity();
                          addToCart(product);
/*                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to Cart'),
                              duration: Duration(milliseconds: 550),
                            ),
                          );*/
                        });
                      },
                      child: Container(
                        height: 35.0,
                        width: 35.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.white),
                        child: Center(
                          child: Icon(
                            Icons.add,
                            color: Constants.bgColor,
                            size: 30.0,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          )),
    );
  }

  form(Product product) {
    var _sugarLevel = ["100", "75", "50", "25", "0"];
    var _categories = ["Drinks", "Addons", "Snacks"];

    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.bgColor,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text('Product Additional Info',
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
                  controller: controllerNote,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(labelText: 'Note'),
                  //validator: (val) => val.length == 0 ? 'Enter Note' : null,
                  onSaved: (val) => note = val,
                ),
                TextFormField(
                  controller: controllerDiscount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Discount'),
                  validator: (val) => int.parse(val) > 100 ? 'Enter Discount' : null,
                  onSaved: (val) => discount = int.parse(val),
                ),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  // Align however you like (i.e .centerRight, centerLeft)
                  child: Text("Sugar Level"),
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
                            value: sugarLevel ?? "100",
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                sugarLevel = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _sugarLevel.map((String value) {
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
                      onPressed: () {
                        setState(() {
                          //isUpdating = false;

                          validate();
                          product.note = note;
                          product.sugarLevel = sugarLevel;
                          product.discount = discount;
                        });
                        clearText();
                      },
                      child: Text("Add"),
                    ),
                    FlatButton(
                      onPressed: () {
                        setState(() {
                          //isUpdating = false;
                        });
                        //clearText();
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

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      //refreshList();
      setState(() {
        // isUpdating = false;
      });
      clearText();
      Navigator.pop(context);
    }
  }

  GestureDetector buildGestureDetector(
      int length, BuildContext context, List<Product> foodItems) {
    return GestureDetector(
      onTap: () {
        if (length > 0) {
          Navigator.push(
              context,
              new MaterialPageRoute(
                builder: (BuildContext context) => Cart(),
                fullscreenDialog: true,
              ));
        } else {
          return;
        }
      },
      child: Container(
        //height: 42.0,
        width: 42.0,
        margin: EdgeInsets.only(right: 30),
        child: Text(length.toString(),
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15.0,
                fontWeight: FontWeight.bold)),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  CustomAppBar() {
    final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

    search() {
      if (_searchIcon.icon == Icons.search) {
        _searchIcon = new Icon(Icons.check);
        _appBarTitle = new TextField(
          style: new TextStyle(color: Colors.white),
          controller: controllerFilter,
          decoration: new InputDecoration(
              labelStyle: TextStyle(color: Colors.red),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              prefixIcon: new Icon(
                Icons.search,
                color: Colors.white,
              ),
              hintStyle: TextStyle(color: Colors.white),
              hintText: 'Search...'),
        );
      } else {
        _searchIcon = new Icon(
          Icons.search,
          color: Colors.white,
        );
        //filteredNames = names;
        //_searchText = controllerFilter.text;
        //filteredDrinksTall=drinksTall;
        refreshAppbar();
        //refreshList();

        controllerFilter.clear();
      }
    }

    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: _searchIcon,
            color: Colors.white,
            onPressed: () {
              setState(() {
                search();
              });
            },
          ),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      search();
                    });
                  },
                  child: _appBarTitle)),
          StreamBuilder(
            stream: bloc.listStream,
            builder: (context, snapshot) {
              List<Product> foodItems = snapshot.data;
              int length = foodItems != null ? foodItems.length : 0;

              return buildGestureDetector(length, context, foodItems);
            },
          )
        ],
      ),
    );
  }
}

/*class FirstHalf extends StatelessWidget {
  const FirstHalf({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(35, 15, 0, 0),
      child: Column(
        children: <Widget>[
          CustomAppBar(),
          //you could also use the spacer widget to give uneven distances, i just decided to go with a sizebox
          //SizedBox(height: 30),
          //SizedBox(height: 30),
          //searchBar(),
          //SizedBox(height: 45),
          //categories(),
        ],
      ),
    );
  }
}*/

Widget categories() {
  return Container(
    height: 185,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        CategoryListItem(
          categoryIcon: Icons.bug_report,
          categoryName: "Burgers",
          availability: 12,
          selected: true,
        ),
        CategoryListItem(
          categoryIcon: Icons.bug_report,
          categoryName: "Pizza",
          availability: 12,
          selected: false,
        ),
        CategoryListItem(
          categoryIcon: Icons.bug_report,
          categoryName: "Rolls",
          availability: 12,
          selected: false,
        ),
        CategoryListItem(
          categoryIcon: Icons.bug_report,
          categoryName: "Burgers",
          availability: 12,
          selected: false,
        ),
        CategoryListItem(
          categoryIcon: Icons.bug_report,
          categoryName: "Burgers",
          availability: 12,
          selected: false,
        ),
      ],
    ),
  );
}

class Items extends StatelessWidget {
  Items({
    @required this.leftAligned,
    @required this.imgUrl,
    @required this.itemName,
    @required this.itemPrice,
    @required this.hotel,
  });

  final bool leftAligned;
  final String imgUrl;
  final String itemName;
  final double itemPrice;
  final String hotel;

  @override
  Widget build(BuildContext context) {
    double containerPadding = 45;
    double containerBorderRadius = 10;

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          child: Column(
            children: <Widget>[
/*              Container(
                width: double.infinity,
                height: 200,
                decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.horizontal(
                    left: leftAligned
                        ? Radius.circular(0)
                        : Radius.circular(containerBorderRadius),
                    right: leftAligned
                        ? Radius.circular(containerBorderRadius)
                        : Radius.circular(0),
                  ),
                  child: Image.network(
                    imgUrl,
                    fit: BoxFit.fill,
                  ),
                ),
              ),*/
              SizedBox(height: 10),
              Container(
                  padding: EdgeInsets.only(
                    left: 10,
                    right: 10,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(itemName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  )),
                            ),
                            Text("\₱$itemPrice",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                )),
                          ],
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(
                                    color: Colors.black45, fontSize: 15),
                                children: [
                                  TextSpan(text: "by "),
                                  TextSpan(
                                      text: hotel,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700))
                                ]),
                          ),
                        ),
                        SizedBox(height: 10),
                      ])),
            ],
          ),
        )
      ],
    );
  }
}

class CategoryListItem extends StatelessWidget {
  const CategoryListItem({
    Key key,
    @required this.categoryIcon,
    @required this.categoryName,
    @required this.availability,
    @required this.selected,
  }) : super(key: key);

  final IconData categoryIcon;
  final String categoryName;
  final int availability;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20),
      padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: selected ? Themes.color : Colors.white,
        border: Border.all(
            color: selected ? Colors.transparent : Colors.grey[200],
            width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100],
            blurRadius: 15,
            offset: Offset(15, 0),
            spreadRadius: 5,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: selected ? Colors.transparent : Colors.grey[200],
                    width: 1.5)),
            child: Icon(
              categoryIcon,
              color: Colors.black,
              size: 30,
            ),
          ),
          SizedBox(height: 10),
          Text(
            categoryName,
            style: TextStyle(
                fontWeight: FontWeight.w700, color: Colors.black, fontSize: 15),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(0, 6, 0, 10),
            width: 1.5,
            height: 15,
            color: Colors.black26,
          ),
          Text(
            availability.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          )
        ],
      ),
    );
  }
}
