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
    return '    ID: ${this.id} \n    Name: ${this.name} \n    Quantity: ${this.quantity} \n    Price: ${this.price} \n    Supplier ID: ${this.supplierID}';
  }



}