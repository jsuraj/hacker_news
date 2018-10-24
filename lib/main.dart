import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

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
      'https://hn.algolia.com/api/v1/search_by_date?tags=front_page&page=';
  List newsItems =[];
  bool isLoading = true;
  int currentPage = 0;



  Widget get _getPageToDisplay {
    if (isLoading) {
      return _loadingView;
    } else {
      return _homeWithLoadMore;
    }
  }

  Widget get _loadingView {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget get _homeWithLoadMore {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 500.0,
            child: _homeView
          ),
          FlatButton(
            color: Colors.amber,
            child: Text("Load More"),
            onPressed: (){
              this.loadNextPage();
            },
          )

        ]
      )
    );
  }

  Widget get _homeView {
    return ListView.builder(
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
                                    this.getDomainUrl(newsItems[index]['url']) +
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
        });
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  Future<String> getData() async {
    String urlWithPageNumber = url+currentPage.toString(); 
    print(urlWithPageNumber);
    var response = await http
        .get(Uri.encodeFull(urlWithPageNumber), headers: {"Accept": "application/json"});
    print(response);
    setState(() {
      newsItems.addAll(json.decode(response.body)['hits']);
      isLoading = false;
    });
    print("Success");
    print("Length after get Data :"+newsItems.length.toString());
    return "Success";
  }
  void loadNextPage(){
  // setState(() {
  //     currentPage = currentPage+1;
  //   });
  print("current page:"+currentPage.toString());
  getData();    
  }

  void handleTap(url) async {
    // print(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String getDomainUrl(url) {
    // var domainUrl = url.split(RegExp(r"^https?://([^/?#]+)(?:[/?#]|$)"));
    // print(domainUrl);
    RegExp exp = RegExp(r"^https?://([^/?#]+)(?:[/?#]|$)");
    Iterable<Match> matches = exp.allMatches(url);
    for (Match m in matches) {
      String match = m.group(0);
      // print(match);
      return match.substring(0, match.length - 1);
    }
    // return domainUrl ?? '';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    Widget body = _getPageToDisplay;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: body);
  }
}
