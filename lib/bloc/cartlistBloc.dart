import 'dart:async';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'provider.dart';
import 'package:rxdart/rxdart.dart';
import '../sqlite/product.dart';

class CartListBloc extends BlocBase {
  CartListBloc();

  var _listController = BehaviorSubject<List<Product>>.seeded([]);

//provider class
  CartProvider provider = CartProvider();

//output
  Stream<List<Product>> get listStream => _listController.stream;

//input
  Sink<List<Product>> get listSink => _listController.sink;

  addToList(Product product) {
    listSink.add(provider.addToList(product));
  }

  removeFromList(Product product) {
    listSink.add(provider.removeFromList(product));
    
  }

  clearList() {
    listSink.add(provider.clearList());
  }

//dispose will be called automatically by closing its streams
  @override
  void dispose() {
    _listController.close();
    super.dispose();
  }
}
