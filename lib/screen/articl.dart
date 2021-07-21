import 'package:Arabi21Login/screen/profil.dart';
import 'package:Arabi21Login/screen/profileNocnt.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_share/social_share.dart';
import 'package:html/parser.dart';

class Articl extends StatefulWidget {
  @override
  _ArticlState createState() => _ArticlState();
}

class _ArticlState extends State<Articl> {
  bool isAuth = false;
  int user_id;
  var id_post;
  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      setState(() {
        isAuth = true;
      });
    }
  }

  Future getPosts() async {
    var resp = await http.get("http://192.168.43.22:8000/api/posts");
    if (resp.statusCode == 200) {
      //200=succés
      var obj = json.decode(resp.body);
      return obj;
    }
  }

  void _Favritpost(user, post) async {
    var resp = await http.post(
        "http://192.168.43.22:8000/api/favourite?post_id=$post&user_id=$user");
    print("$post,$user");
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));

    if (user != null) {
      setState(() {
        user_id = user['id'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkIfLoggedIn();
    getPosts();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "                                           الرئيسية ",
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: "advertisingbold",
            fontSize: 21,
          ),
        ),
        backgroundColor: Color(0xffa257ba),
        automaticallyImplyLeading: false,
      ),
      body: Center(
          child: FutureBuilder(
        future: getPosts(),
        builder: (ctx, snapshot) {
          //snapshot=obj
          if (snapshot.data == null) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            )));
          } else {
            return ListView.builder(
              itemBuilder: (_, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xff7c94b6),
                    border: Border.all(
                      color: Colors.black,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Card(
                      child: Column(
                    children: [
                      FlatButton(
                        onPressed: () {
                          title = snapshot.data['data'][index]['title'];
                          excerpt = snapshot.data['data'][index]['excerpt'];
                          content = snapshot.data['data'][index]['content'];
                          author = snapshot.data['data'][index]['author'];
                          image = snapshot.data['data'][index]['image'];
                          id_post = snapshot.data['data'][index]['id'];
                          if (excerpt == null || content == null) {
                            print("excerpt==null");
                          } else {
                            _showDialog(title, excerpt, content, author, image,
                                id_post, user_id);
                            print('user id=$user_id \n post_id=$id_post');
                          }
                        },
                        child: Image.network(
                          '${snapshot.data['data'][index]['image']}',
                          width: double.infinity,
                        ),
                      ),
                      Text(
                        snapshot.data['data'][index]['title'],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontFamily: 'advertisingbold',
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        snapshot.data['data'][index]['category']['name'],
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontFamily: 'jalah',
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                      Center(
                        child: Row(
                          textDirection: TextDirection.ltr,
                          children: [
                            FlatButton(
                              onPressed: () {
                                if (isAuth) {
                                  _Favritpost(user_id,
                                      snapshot.data['data'][index]['id']);
                                } else {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) => ProfilNoCnt()));
                                }
                              },
                              child: Text(
                                "اضافة كمفضلة",
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontFamily: 'jalah',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            FlatButton(
                                onPressed: () async {
                                  SocialShare.shareOptions(_parseHtmlString(
                                      "$title \n $excerpt \n $content"));
                                },
                                child: Text(
                                  "مشاركة ",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontFamily: 'jalah',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ))
                          ],
                        ),
                      ),
                    ],
                  )),
                );
              },
              itemCount: 20,
            );
          }
        },
      )),
    );
  }

  bool click = false;
  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  var title, excerpt, content, author, image;
  void _showDialog(title, excerpt, content, author, image, id_post, user_id) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          scrollable: true,
          title: new Text(
            title,
            style: TextStyle(
                color: Colors.blueAccent,
                fontFamily: 'advertisingbold',
                fontSize: 14,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          content: new Column(
            children: [
              Image.network(image),
              Html(data: excerpt),
              Html(data: content),
              Text(
                author,
                style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'advertisingbold',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ],
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Icon(
                Icons.exit_to_app,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            new FlatButton(
              onPressed: () async {
                SocialShare.shareOptions(
                    _parseHtmlString("$title \n $excerpt \n $content"));
              },
              child: new Icon(
                Icons.share,
              ),
            )
          ],
        );
      },
    );
  }
}
