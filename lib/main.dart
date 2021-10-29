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

class ListSearch extends StatefulWidget {
  ListSearchState createState() => ListSearchState();
}

class ListSearchState extends State<ListSearch> {
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

  Future<void> _loadData() async {
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

  TextEditingController _textController = TextEditingController();

  // Copy Main List into New List.
  List<String> newDataList = List.from(mainDataList);

  onItemChanged(String value) {
    setState(() {
      newDataList = mainDataList
          .where((string) => string.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

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
              children: newDataList.map(
                (data) {
                  return ListTile(
                    title: Text(data),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddItemPage()),
                );
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

class AddItemPage extends StatelessWidget {
  const AddItemPage({Key? key}) : super(key: key);

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
                  print(_itemID.text +
                      " " +
                      _itemName.text +
                      " " +
                      _itemQuantity.text +
                      " " +
                      _itemPrice.text +
                      " " +
                      _supplierID.text);

                  // todo: add item to array
                  var item = new Item(
                      int.parse(_itemID.text),
                      _itemName.text,
                      int.parse(_itemQuantity.text),
                      double.parse(_itemPrice.text),
                      int.parse(_supplierID.text));

                  // Items.add(item);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListSearch(),
                      ));

                  // Return to main menu
                  // Navigator.pop(context);
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
