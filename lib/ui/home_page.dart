import 'dart:convert';
import 'package:buscador_de_gifs/ui/GifPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

const trendingRequest =
    "https://api.giphy.com/v1/gifs/trending?api_key=Bi0HczEb4LmNnD0qwjqfz8obwk0CGgsg&limit=20&rating=g";

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _search;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _offset = 0;
  }

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null || _search.isEmpty)
      response = await http.get(trendingRequest);
    else {
      String searchRequest =
          "https://api.giphy.com/v1/gifs/search?api_key=Bi0HczEb4LmNnD0qwjqfz8obwk0CGgsg&q=$_search&limit=25&offset=$_offset&rating=g&lang=en";
      response = await http.get(searchRequest);
    }
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: "Pesquisar gifs...",
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              onSubmitted: (value) {
                setState(() {
                  _search = value;
                  _offset = 0;
                });
              },
            ),
          ),
          Expanded(
              child: FutureBuilder(
            future: _getGifs(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container(
                    width: 200.0,
                    height: 200.0,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 5.0,
                    ),
                  );
                default:
                  if (snapshot.hasError)
                    return Container(
                      color: Colors.blueAccent,
                    );
                  else {
                    print(snapshot.data["data"][0]["images"]["fixed_height"]
                        ["url"]);
                    return _createGifsGrid(context, snapshot);
                  }
              }
            },
          ))
        ],
      ),
    );
  }

  int _getGridSize(List data) {
    if (_search == null)
      return data.length;
    else
      return data.length + 1;
  }

  Widget _createGifsGrid(context, snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0),
        itemCount: _getGridSize(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]
                      ["url"]),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 70.0,
                    ),
                    Text("Carregar mais...",
                        style: TextStyle(color: Colors.white, fontSize: 22.0))
                  ],
                ),
                onTap: () {
                  setState(() {
                    _offset += 24;
                  });
                },
              ),
            );
        });
  }
}
