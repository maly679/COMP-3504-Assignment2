class Item {

  int? id;
  String? name;
  int? quantity;
  double? price;
  int? supplierID;

  // Constructor
  Item(int id, String name, int quantity, double price, int supplierID) {
    this.id = id;
    this.name = name;
    this.quantity = quantity;
    this.price = price;
    this.supplierID = supplierID;
  }

  String toString() {
    return '${this.id} ${this.name} ${this.quantity} ${this.price} ${this.supplierID}';
  }



}