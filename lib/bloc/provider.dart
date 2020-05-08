import '../sqlite/product.dart';

class CartProvider {
  //couterProvider only consists of a counter and a method which is responsible for increasing the value of count
  List<Product> products = [];

  List<Product> addToList(Product product) {
    bool isPresent = false;

    if (products.length > 0) {
      for (int i = 0; i < products.length; i++) {
        if (products[i].id == product.id) {
          //increaseItemQuantity(product);
          isPresent = true;
          break;
        } else {
          isPresent = false;
        }
      }

      if (!isPresent) {
        products.add(product);
      }
    } else {
      products.add(product);
    }

    return products;
  }

  List<Product> removeFromList(Product product) {
    if (product.quantity > 1) {
      //only decrease the quantity
      decreaseItemQuantity(product);
    } else {
      //remove it from the list
      products.remove(product);
    }
    return products;
  }

  List<Product> clearList() {
    products.clear();
    return products;
  }

  void increaseItemQuantity(Product product) => product.incrementQuantity();
  void decreaseItemQuantity(Product product) => product.decrementQuantity();
}
