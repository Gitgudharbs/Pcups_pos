class Product {
  int id;
  String name;
  String size;
  String category;
  String note="";
  String sugarLevel ="100";
  int discount = 0;
  double price;
  int isActive;
  int quantity = 0;

  Product(this.id, this.name, this.size, this.category, this.price, this.isActive);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'size': size,
      'category': category,
      'price': price,
      'isActive': isActive,
    };
    return map;
  }

  Product.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    size = map['size'];
    category = map['category'];
    price = map['price'];
    isActive = map['isActive'];
  }

/*  Product.fromMapList(Map<String, dynamic> map) {
    name = map['name'];
    category = map['category'];
  }*/


  void incrementQuantity() {
    this.quantity = this.quantity + 1;
  }

  void decrementQuantity() {
    this.quantity = this.quantity - 1;
  }
}
