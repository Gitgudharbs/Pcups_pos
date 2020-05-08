class Tp {
  int transactionId;
  int productId;
  String name;
  int discount;
  double price;
  int quantity;

  Tp(this.transactionId, this.productId, this.quantity, this.discount);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'transactionId': transactionId,
      'productId': productId,
      'quantity': quantity,
      'discount': discount,
    };
    return map;
  }

  Tp.fromMap(Map<String, dynamic> map) {
    transactionId = map['transactionId'];
    name = map['name'];
    productId = map['productId'];
    quantity = map['quantity'];
    discount = map['discount'];
    price = map['price'];
  }
}
