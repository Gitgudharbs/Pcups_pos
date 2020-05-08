import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirst/sqlite/db_helper.dart';
import 'package:flutterfirst/sqlite/transaction_product.dart';
import 'sqlite/product.dart';
import 'package:flutterfirst/sqlite/transaction.dart';
import 'package:intl/intl.dart';
import 'bloc/cartlistBloc.dart';
import 'bloc/listTileColorBloc.dart';
import 'const/themeColor.dart';
import 'constants.dart' as Constants;

class Cart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();
    List<Product> products;
    return SizedBox.expand(
      child: StreamBuilder(
        stream: bloc.listStream,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            products = snapshot.data;
            return new Scaffold(
                backgroundColor: Color(0xFF7A9BEE),
                body: Stack(alignment: Alignment.center, children: [
                  Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.transparent),
                  Positioned(
                      top: 100.0,
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(45.0),
                                topRight: Radius.circular(45.0),
                              ),
                              color: Colors.white),
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width)),
                  Container(
                      margin: EdgeInsets.only(bottom: 180),
                      child: CartBody(products)),
                  Positioned(
                    //top: 70.0,
                    bottom: 30,
                    child: bottomBar(products),
                  ),
                ]));
          } else {
            return Container(
              child: Text("Something returned null"),
            );
          }
        },
      ),
    );
  }
}

class bottomBar extends StatelessWidget {
  final List<Product> products;
  Future<List<Ts>> transactions;
  var dbHelper = DBHelper();

  bottomBar(this.products);

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: EdgeInsets.only(left: MediaQuery.of(context).size.width/4, bottom: 25),
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width:  MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              totalAmount(products),
              nextButtonBar(context),
            ],
          ),
            decoration: new BoxDecoration(
              border: Border(
                top: BorderSide(width: 1.0, color: Colors.grey),
                //left: BorderSide(width: 1.0, color: Colors.grey),
                //right: BorderSide(width: 1.0, color: Colors.grey),
                //bottom: BorderSide(width: 1.0, color: Colors.grey),
     ),
            )
        ),
      ),
    );
  }

  Container totalAmount(List<Product> products) {
    return Container(
      //margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.all(25),
      child: Text(
        "\₱ ${returnTotalAmount(products)}",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
      ),
    );
  }

  String returnTotalAmount(List<Product> products) {
    double totalAmount = 0.0;

    for (int i = 0; i < products.length; i++) {
      //print(products[i].discount);
      if (products[i].discount < 0) {
        totalAmount = totalAmount + products[i].price * products[i].quantity;
      } else {
        totalAmount = totalAmount +
            (products[i].price * (100 - products[i].discount) / 100) *
                products[i].quantity;
      }
      //totalAmount = totalAmount + (products[i].price * (100 - products[i].discount)/100) * products[i].quantity;
    }
    return totalAmount.toStringAsFixed(2);
  }

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Checkout Confirmation"),
          //content: new Text("Alert Dialog body"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Confirm"),
              onPressed: () async {
                if (products.length > 0) {
                  String date =
                      DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now());
                  int tall = 0;
                  int short = 0;
                  for (int i = 0; i < products.length; i++) {
                    if (products[i].size == 'Tall')
                      tall += products[i].quantity;
                    else if (products[i].size == 'Short')
                      short += products[i].quantity;
                  }

                  Ts e = Ts(null, double.parse(returnTotalAmount(products)),
                      tall, short, date);
                  Ts temp = await dbHelper.transactionCreate(e);

                  for (var i = 0; i < products.length; i++) {
                    Tp e = Tp(temp.id, products[i].id, products[i].quantity,
                        products[i].discount);
                    dbHelper.tpCreate(e);
                    products[i].quantity = 0;
                  }

                  products.clear();
                  Navigator.pop(context);
                }
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

  Container nextButtonBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(15)),
      child: FlatButton(
        padding: EdgeInsets.only(right: 125, left: 125),
        onPressed: () async {
          _showDialog(context);
        },
        child: Text("Checkout",
            style: TextStyle(
                color: Colors.white, fontFamily: 'Montserrat', fontSize: 18.0)),
      ),
    );
  }
}

class CartBody extends StatelessWidget {
  final List<Product> products;

  CartBody(this.products);

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: MediaQuery.of(context).size.height - 182.0,
      //width: MediaQuery.of(context).size.width,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(15, 35, 15, 0),
      child: Column(
        children: <Widget>[
          CustomAppBar(),
          SizedBox(height: 40.0),
          title(context),
          Divider(
            height: 1,
            color: Colors.grey[700],
          ),
          Expanded(
            child: products.length > 0 ? foodItemList() : noItemContainer(),
          )
        ],
      ),
    );
  }

  Container noItemContainer() {
    return Container(
      child: Center(
        child: Text(
          "No More Items Left In The Cart",
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              fontSize: 20),
        ),
      ),
    );
  }

  CupertinoScrollbar foodItemList() {
    return CupertinoScrollbar(
      child: ListView.builder(
        padding: EdgeInsets.only(top: 10),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              CartListItem(foodItem: products[index]),
              Divider(
                height: 1,
                //color: Colors.grey[700],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget title(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 2.8,
            //color: Colors.blue,
            child: Text(
              "PRODUCT NAME",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 9,
            // color: Colors.red,
            child: Text(
              "QTY",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 7,
            //color: Colors.red,
            child: Text(
              "PRICE",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 10,
            child: Text(
              "TOTAL",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CartListItem extends StatelessWidget {
  final Product foodItem;

  CartListItem({@required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      //hapticFeedbackOnStart: false,
      maxSimultaneousDrags: 1,
      data: foodItem,
      feedback: DraggableChildFeedback(product: foodItem),
      child: Container(
          //height: 50,
          //margin: EdgeInsets.only(bottom: 25),
          color: Colors.white70,
          alignment: Alignment.center,
          child: DraggableChild(foodItem: foodItem)),
      childWhenDragging: foodItem.quantity > 1
          ? DraggableChild(foodItem: foodItem)
          : Container(),
    );
  }
}

class DraggableChild extends StatelessWidget {
  const DraggableChild({
    Key key,
    @required this.foodItem,
  }) : super(key: key);

  final Product foodItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15, top: 15, left: 10, right: 10),
      child: ItemContent(
        foodItem: foodItem,
      ),
    );
  }
}

class DraggableChildFeedback extends StatelessWidget {
  const DraggableChildFeedback({
    Key key,
    @required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ColorBloc colorBloc = BlocProvider.getBloc<ColorBloc>();

    return Opacity(
      opacity: 0.7,
      child: StreamBuilder(
        stream: colorBloc.colorStream,
        builder: (context, snapshot) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: snapshot.data != null ? snapshot.data : Colors.white,
            ),
            padding: EdgeInsets.only(bottom: 15, top: 15, left: 10),
            width: MediaQuery.of(context).size.width * 0.95,
            child: ItemContent(foodItem: product),
          );
        },
      ),
    );
  }
}

class ItemContent extends StatelessWidget {
  const ItemContent({
    Key key,
    @required this.foodItem,
  }) : super(key: key);

  final Product foodItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            //crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width / 3,
                margin: EdgeInsets.only(bottom: 10),
                //color: Colors.red,
                child: RichText(
                  text: TextSpan(
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                      children: [
                        TextSpan(
                            text: foodItem.name,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 13,
                //color: Colors.green,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    foodItem.quantity.toString(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 5,
                //color: Colors.orangeAccent,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "₱" + foodItem.price.toStringAsFixed(2),
                    style: TextStyle(
                        decoration: foodItem.discount > 0
                            ? TextDecoration.lineThrough
                            : null,
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 5,
                //color: Colors.yellow,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "₱ ${(foodItem.quantity * foodItem.price).toStringAsFixed(2)}",
                    style: TextStyle(
                        fontSize: 15,
                        decoration: foodItem.discount > 0
                            ? TextDecoration.lineThrough
                            : null,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
          if (foodItem.sugarLevel != "100")
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Sugar: " + foodItem.sugarLevel + "%",
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          if (foodItem.note != "")
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
/*         ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  'assets/milktea.png',
                  fit: BoxFit.fitHeight,
                  height: 55,
                  width: 80,
                ),
              ),*/

                Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: Text(
                    "Note: " + foodItem.note,
                    //overflow: TextOverflow.fade,
                    maxLines: 4,
                    //softWrap: false,
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          if (foodItem.discount != 0)
            Row(
              //crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width / 2.3,
                  //color: Colors.red,
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: "Discount : " +
                                foodItem.discount.toString() +
                                "%",
                          ),
                        ]),
                  ),
                ),
/*                Container(
                  width: MediaQuery.of(context).size.width / 13,
                  //color: Colors.green,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                    ),
                  ),
                ),*/
                Container(
                  width: MediaQuery.of(context).size.width / 5,
                  //color: Colors.orangeAccent,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "₱" +
                          (foodItem.price * (100 - foodItem.discount) / 100)
                              .toStringAsFixed(2),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 5,
                  //color: Colors.yellow,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      "₱ ${(foodItem.quantity * (foodItem.price * (100 - foodItem.discount) / 100)).toStringAsFixed(2)}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  final CartListBloc bloc = BlocProvider.getBloc<CartListBloc>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            child: Icon(
              CupertinoIcons.back,
              color: Colors.white,
              size: 40,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 20.0, top: 10.0),
          child: Row(
            children: <Widget>[
              Text('Cart',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0)),
              SizedBox(width: 10.0),
            ],
          ),
        ),
        DragTargetWidget(bloc),
      ],
    );
  }
}

class DragTargetWidget extends StatefulWidget {
  final CartListBloc bloc;

  DragTargetWidget(this.bloc);

  @override
  _DragTargetWidgetState createState() => _DragTargetWidgetState();
}

class _DragTargetWidgetState extends State<DragTargetWidget> {
  @override
  Widget build(BuildContext context) {
    Product currentProduct;
    final ColorBloc colorBloc = BlocProvider.getBloc<ColorBloc>();

    return DragTarget<Product>(
      onAccept: (Product product) {
        currentProduct = product;
        colorBloc.setColor(Colors.white);
        currentProduct.quantity = 0;
        widget.bloc.removeFromList(currentProduct);
      },
      onWillAccept: (Product product) {
        colorBloc.setColor(Colors.red);
        return true;
      },
      onLeave: (Product product) {
        colorBloc.setColor(Colors.white);
      },
      builder: (BuildContext context, List incoming, List rejected) {
        return Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Icon(
            CupertinoIcons.delete,
            color: Colors.white,
            size: 35,
          ),
        );
      },
    );
  }
}
