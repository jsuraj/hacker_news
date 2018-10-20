import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacker News',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: MyHomePage(title: 'Hacker News'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String url =
      'https://hn.algolia.com/api/v1/search_by_date?tags=front_page';
  List newsItems;

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  Future<String> getData() async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    // print(response.body);
    setState(() {
      newsItems = json.decode(response.body)['hits'];
    });
    return "Success";
  }

  void handleTap(url) {
    print(url);
  }

  String getDomainUrl(url) {
    var domainUrl = url.split(RegExp(r"^https?:\/\/([^\/?#]+)(?:[\/?#]|$)"));
    print(domainUrl);
    // return domainUrl ?? '';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: newsItems == null ? 0 : newsItems.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
                child: Center(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      this.handleTap(newsItems[index]['url']);
                    },
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          RichText(
                              text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.black,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: (index + 1).toString() +
                                    '. ' +
                                    newsItems[index]['title'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                  text: ' (' +
                                      this.getDomainUrl(
                                          newsItems[index]['url']) +
                                      ')')
                            ],
                          )),
                          Text(
                            (newsItems[index]['points'] ?? 0).toString() +
                                ' points by ' +
                                newsItems[index]['author'] +
                                ' | ' +
                                (newsItems[index]['num_comments'] ?? 0)
                                    .toString() +
                                ' comments',
                            style: DefaultTextStyle.of(context)
                                .style
                                .apply(fontSizeFactor: 0.8),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(10.0),
                    ),
                  ),
                ])));
          }),
    );
  }
}
