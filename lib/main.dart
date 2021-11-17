import 'package:flutter/material.dart';
import './Item.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(title: Text('Inventory Tracking System')),
            body: Center(child: ListSearch())));
  }
}

//class for handling item display and searches
class ListSearch extends StatefulWidget {
  ListSearchState createState() => ListSearchState();
}

class ListSearchState extends State<ListSearch> {
  //base variables and arrays needed to process data from file and the search functionality
  String _data = '';
  List<String> result = [];
  List<Item> Items = [];
  static List<String> mainDataList = [];
  Widget _body = CircularProgressIndicator();

  //tests whether data is still fetching. Initially set to true;
  bool loading = true;

  @override
  void initState() {
    _loadData().then((value) {
      print('Async done');
    });
    super.initState();
  }

  //Load data from file, if this is first run of program.
  Future<void> _loadData() async {
    if (mainDataList.length == 0) {
      final _loadedData = await rootBundle.loadString('assets/items.txt');
      _data = _loadedData;
      result = _data.split("\r\n");
      for (var i = 0; i < result.length; i++) {
        var splitResult = result[i].split(';');
        var item = new Item(
            int.parse(splitResult[0]),
            splitResult[1],
            int.parse(splitResult[2]),
            double.parse(splitResult[3]),
            int.parse(splitResult[4]));
        Items.add(item);
        mainDataList.add('${item.name.toString()};${item.id.toString()}');
      }
      //once data is loaded, set loading to false and initialize data, so inventory data can be shown on widget.
      setState(() {
        loading = false;
        onItemChanged('');
      });
    }
  }

  TextEditingController _textController = TextEditingController();
  // Copy Main List into New List. This is used to process the search functionality.
  List<String> newDataList = List.from(mainDataList);

  //Item changed in search. Tests id and name through the mainDataList items that have data stored
  //as 'name;ID', and if match is found returns newDataList in the name-only format required in list view.
  onItemChanged(String value) {
    setState(() {
      newDataList = mainDataList
          .where((string) => string.toLowerCase().contains(value.toLowerCase()))
          .toList();

      //used to account for search by id and name. Data is displayed on screen
      //by just name.
      int i = 0;
      newDataList.forEach((element) {
        newDataList[i] = element.split(';')[0];
        i++;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //Checks if async data is still loading; if so show circular loading screen
    //loading is set to false in state above.

    if (loading == true) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Search Here...',
                ),
                onChanged: onItemChanged,
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(12.0),
                children: newDataList.map(
                  (data) {
                    return ListTile(
                      title: Text(data),
                      //process detail view on click of item name.
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return new detailedView(data: data, items: Items);
                        }));
                      },
                    );
                  },
                ).toList(),
              ),
            ),
            Container(
              margin: EdgeInsets.all(25),
              child: FlatButton(
                child: Text(
                  'Add Item to Inventory',
                  style: TextStyle(fontSize: 20.0),
                ),
                //Process the adding of items on press of button.
                onPressed: () async {
                  //Navigator.push returns a future value so you need to await for it.
                  var updatedData = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddItem(data: _data, items: Items)),
                  );
                  //Returned items, after addition, requiring state change of processed data to reflect addition.
                  setState(() {
                    //If a new item was added, need to re-initialize the lists used for search functionality.
                    //and display of data.
                    if (updatedData.length > 0) {
                      mainDataList = [];
                      newDataList = [];
                      for (var i = 0; i < updatedData.length; i++) {
                        mainDataList.add(
                            '${updatedData[i].name.toString()};${updatedData[i].id.toString()}');
                        newDataList.add(updatedData[i].name.toString());
                      }
                    }
                  });
                },
              ),
            )
          ],
        ),
      );
    }
  }
}

// Search bar in app bar flutter
class SearchAppBar extends StatefulWidget {
  @override
  _SearchAppBarState createState() => new _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  Widget appBarTitle = new Text("AppBar Title");
  Icon actionIcon = new Icon(Icons.search);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar:
          new AppBar(centerTitle: true, title: appBarTitle, actions: <Widget>[
        new IconButton(
          icon: actionIcon,
          onPressed: () {
            setState(() {
              if (this.actionIcon.icon == Icons.search) {
                this.actionIcon = new Icon(Icons.close);
                this.appBarTitle = new TextField(
                  style: new TextStyle(
                    color: Colors.white,
                  ),
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(Icons.search, color: Colors.white),
                      hintText: "Search...",
                      hintStyle: new TextStyle(color: Colors.white)),
                );
              } else {
                this.actionIcon = new Icon(Icons.search);
                this.appBarTitle = new Text("AppBar Title");
              }
            });
          },
        ),
      ]),
    );
  }
}

//Upon clicking an item - shows detailed view.
class detailedView extends StatelessWidget {
  final data;
  final items;
  detailedView({Key? key, this.data, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Inventory Tracking System')),
        body: new Center(
            child: Column(children: <Widget>[
          Container(
              alignment: Alignment.center,
              child: Text("${data} Details",
                  style: TextStyle(fontSize: 25, color: Colors.white)),
              margin: const EdgeInsets.only(top: 60.0),
              height: 80,
              width: 300,
              color: Colors.blue),
          Container(
              alignment: Alignment.center,
              child: Text(
                  //fix toString() return of parenthesis surrounding values
                  items
                      .where((i) => i.name == data)
                      .toString()
                      .replaceAll('(', '')
                      .replaceAll(')', ''),
                  style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
              height: 200,
              width: 350),
          Container(
            alignment: Alignment.center,
            child: FlatButton(
              child: Text('Back'),
              color: Colors.blue,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ])));
  }
}

//Add an item to the list
class AddItem extends StatefulWidget {
  final data;
  final items;
  AddItem({Key? key, this.data, this.items}) : super(key: key);

  @override
  AddItemState createState() => AddItemState();
}

class AddItemState extends State<AddItem> {
  @override
  Widget build(BuildContext context) {
    final _itemID = TextEditingController();
    final _itemName = TextEditingController();
    final _itemQuantity = TextEditingController();
    final _itemPrice = TextEditingController();
    final _supplierID = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item to Inventory"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
                width: 280,
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _itemID,
                  autocorrect: true,
                  decoration: InputDecoration(hintText: 'Enter Item ID'),
                )),
            Container(
                width: 280,
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _itemName,
                  autocorrect: true,
                  decoration: InputDecoration(hintText: 'Enter Item Name'),
                )),
            Container(
                width: 280,
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _itemQuantity,
                  autocorrect: true,
                  decoration: InputDecoration(hintText: 'Enter Item Quantity'),
                )),
            Container(
                width: 280,
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _itemPrice,
                  autocorrect: true,
                  decoration: InputDecoration(hintText: 'Enter Item Price'),
                )),
            Container(
                width: 280,
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _supplierID,
                  autocorrect: true,
                  decoration: InputDecoration(hintText: 'Enter Supplier ID'),
                )),
            RaisedButton(
                // Add item to list and returns to list search page
                onPressed: () {
                  // Create new item object and add it to list
                  bool inputCheck = inputItemCheck(_itemID, _itemName,
                      _itemQuantity, _itemPrice, _supplierID);

                  if (inputCheck == true) {
                    Item newItem = new Item(
                        int.parse(_itemID.text),
                        _itemName.text,
                        int.parse(_itemQuantity.text),
                        double.parse(_itemPrice.text),
                        int.parse(_supplierID.text));
                    widget.items.add(newItem);
                    Navigator.pop(context, widget.items);
                  } else {
                    return;
                  }
                  /*var item = new Item(
                      int.parse(_itemID.text),
                      _itemName.text,
                      int.parse(_itemQuantity.text),
                      double.parse(_itemPrice.text),
                      int.parse(_supplierID.text));
                  widget.items.add(item);*/
                  /*bool addItem = widget.items.add(item);
                  print("Was the item added to list?: " + addItem.toString());*/
                  //Return to the list search page with the newly added item (widget.items list)
                  // Navigator.pop(context, widget.items);
                },
                color: Color(0xffFF1744),
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: const Text('Add Item to Inventory')),
            ElevatedButton(
              // Return to the list search page without adding an item
              onPressed: () {
                showToast(
                    "Returning to Main Menu. No item not added to inventory.");
                Navigator.pop(context, widget.items);
              },
              child: const Text('Return to Main Menu'),
            )
          ],
        ),
      ),
    );
  }

  /**
   * Validates if the input is valid.
   */
  bool inputItemCheck(
      _itemID, _itemName, _itemQuantity, _itemPrice, _supplierID) {
    // Checks if all fields are empty
    if (_itemID.text == "" ||
        _itemName.text == "" ||
        _itemQuantity.text == "" ||
        _itemPrice.text == "" ||
        _supplierID.text == "") {
      if (_itemID.text == "") {
        print("itemID field is empty...");
        showToast("itemID field is empty...");
      } else if (_itemName.text == "") {
        print("itemName field is empty...");
        showToast("itemName field is empty...");
      } else if (_itemQuantity.text == "") {
        print("itemQuantity field is empty...");
        showToast("itemQuantity field is empty...");
      } else if (_itemPrice.text == "") {
        print("itemPrice field is empty...");
        showToast("itemPrice field is empty...");
      } else if (_supplierID.text == "") {
        print("supplierID field is empty...");
        showToast("supplierID field is empty...");
      }
      // All fields are empty
      else {
        print(
            "itemID, itemName, itemQuantity, and itemPrice, and supplierID field are empty...");
        showToast(
            "ItemID, itemName, itemQuantity, and itemPrice, and supplierID fields are empty...");
      }

      return false;
    }
    // Checks if numeric field contains non-numeric values
    else if (_isNumeric(_itemID.text) == false ||
        _isNumeric(_itemQuantity.text) == false ||
        _isNumeric(_itemPrice.text) == false ||
        _isNumeric(_supplierID.text) == false) {
      if (_isNumeric(_itemID.text) == false) {
        print("itemID is an invalid value...");
        showToast("itemID is an invalid value...");
      } else if (_isNumeric(_itemQuantity.text) == false) {
        print("itemQuantity is an invalid value...");
        showToast("itemQuantity is an invalid value...");
      } else if (_isNumeric(_itemPrice.text) == false) {
        print("itemPrice is an invalid value...");
        showToast("itemPrice is an invalid value...");
      } else if (_isNumeric(_supplierID.text) == false) {
        print("supplierID is an invalid value...");
        showToast("supplierID is an invalid value...");
      }
      // All fields contain non-numeric values
      else {
        print(
            "itemID, itemQuantity, itemPrice, and supplierID are not numeric values...");
        showToast(
            "itemID, itemQuantity, itemPrice, and supplierID are not numeric values...");
      }

      return false;
    }
    // Confirms item is added into inventory list
    else {
      print("Item added to inventory...");
      showToast("Item added to inventory");

      return true;
    }
  }

  /**
   * Checks if the input is numeric
   */
  bool _isNumeric(String s) {
    // If string is a number, return false
    if (s == null) {
      return false;
    }
    // DEFAULT; If string is not a number, return true
    return double.tryParse(s) != null;
  }

  /**
   * Generates a toast message
   */
  void showToast(String message) => Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
}
