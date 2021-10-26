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
            appBar: AppBar(
                title: Text('Inventory Tracking System')
            ),
            body: Center(
                child: ListSearch()
            )
        )
    );
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
    _loadData().then((value){
      print('Async done');
    });
    super.initState();
  }

  // This function is triggered when the user presses the floating button
  Future<void> _loadData() async {
    final _loadedData = await rootBundle.loadString('assets/items.txt');
    log("dasdsa");
    _data = _loadedData;
    result = _data.split("\r\n");
    for (var i = 0; i < result.length; i++) {
      var splitResult = result[i].split(';');
      var item = new Item (
          int.parse(splitResult[0]), splitResult[1], int.parse(splitResult[2]),
          double.parse(splitResult[3]), int.parse(splitResult[4]));
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
            .where((string) =>
            string.toLowerCase().contains(value.toLowerCase()))
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
              children: newDataList.map((data) {
                return ListTile(
                  title: Text(data),
                  onTap: ()=> showDetails(data),);
              }).toList(),
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
      appBar: new AppBar(
          centerTitle: true,
          title:appBarTitle,
          actions: <Widget>[
            new IconButton(icon: actionIcon,onPressed:(){
              setState(() {
                if ( this.actionIcon.icon == Icons.search){
                  this.actionIcon = new Icon(Icons.close);
                  this.appBarTitle = new TextField(
                    style: new TextStyle(
                      color: Colors.white,

                    ),
                    decoration: new InputDecoration(
                        prefixIcon: new Icon(Icons.search,color: Colors.white),
                        hintText: "Search...",
                        hintStyle: new TextStyle(color: Colors.white)
                    ),
                  );}
                else {
                  this.actionIcon = new Icon(Icons.search);
                  this.appBarTitle = new Text("AppBar Title");
                }


              });
            } ,),]
      ),
    );
  }
}