import 'package:flutter/material.dart';
import './Item.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:developer';

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
// final itemsAdded;
// ListSearch({Key? key, this.itemsAdded}) : super(key: key);
}

class ListSearchState extends State<ListSearch> {

  //base variables and arrays needed to process data from file and the search functionality
  String _data = '';
  List<String> result = [];
  List<Item> Items = [];
  static List<String> mainDataList = [];

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
        mainDataList.add(item.name.toString());
      }
    }
  }

  TextEditingController _textController = TextEditingController();

  // Copy Main List into New List. This is used to process the search functionality.
  List<String> newDataList = List.from(mainDataList);

  //Item changed in search
  onItemChanged(String value) {

    setState(() {
      newDataList = mainDataList
          .where((string) => string.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  //showDetails - for troubleshooting/not used - can be removed after).
  showDetails(String Name) {
    for (int i = 0; i < Items.length; i++) {
      if (Items[i].name == Name) {
        print(Items[i]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

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
              children:
              newDataList.map(
                    (data) {
                  return ListTile(
                    title: Text(data),
                    //process detail view
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
              //Process the adding of items on press of button
              onPressed: () async {
                // Navigator.push returns a future value so you need to await for it
                var data2 = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddItem(data: _data, items: Items)),
                );
              //returned items, after addition, requiring state change of processed data to reflect addition.
                setState(() {
                  mainDataList = [];
                  newDataList = [];
                  for (var i = 0; i < data2.length; i++) {
                    mainDataList.add(data2[i].name.toString());
                    newDataList.add(data2[i].name.toString());

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

//upon clicking an item - shows detailed view.
class detailedView extends StatelessWidget {
  final data;
  final items;
  detailedView({Key? key, this.data, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
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
                          style:
                          TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
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
                ]))));
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
                onPressed: () {
                  // Create new item object and add it to list
                  var item = new Item(
                      int.parse(_itemID.text),
                      _itemName.text,
                      int.parse(_itemQuantity.text),
                      double.parse(_itemPrice.text),
                      int.parse(_supplierID.text));
                      widget.items.add(item);

                  //return to the list search page with the newly added item (widget.items list)
                  Navigator.pop(
                      context,
                      widget.items);
                },
                color: Color(0xffFF1744),
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: const Text('Add Item to Inventory')),
                ElevatedButton(
                onPressed: () {

                Navigator.pop(context);
                },
              child: const Text('Return to Main Menu'),
            )
          ],
        ),
      ),
    );
  }
}