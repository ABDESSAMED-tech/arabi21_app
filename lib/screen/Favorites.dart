import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_share/social_share.dart';
import 'package:html/parser.dart';

class FavoriteScrenne extends StatefulWidget {
  @override
  final id;

  const FavoriteScrenne({this.id});

  _FavoriteScrenneState createState() => _FavoriteScrenneState(this.id);
}

class _FavoriteScrenneState extends State<FavoriteScrenne> {
  var user_id;
  int id_post;
  int post;
  int item;
  final id;

  _FavoriteScrenneState(this.id);
  Future getPostsFav() async {
    var resp =
        await http.get("http://192.168.43.22:8000/api/my_favourites/$user_id");
    if (resp.statusCode == 200) {
      //200=succés
      var obj = json.decode(resp.body);
      return obj;
    }
  }

  _unFavoritpost(post) async {
    var resp = await http.post(
        "http://192.168.43.22:8000/api/unfavourite?post_id=$post&user_id=$user_id");
    var respe =
        await http.get("http://192.168.43.22:8000/api/CountData/$user_id");
    Map jsonData = json.decode(respe.body) as Map;
    item = jsonData['data'];
    print("$id_post ,$user_id");
    if (resp.statusCode == 200) {
      //200=succés
      var obj = json.decode(resp.body);
      return obj;
    }
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
    getPostsFav();

    _checkIfLoggedIn();
  }

  bool isAuth = false;
  void _checkIfLoggedIn() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var token = localStorage.getString('token');
    if (token != null) {
      setState(() {
        isAuth = true;
      });
    }
  }

  int i = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "                  الاخبار المفضلة  ",
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
        future: getPostsFav(),
        builder: (ctx, snapshot) {
          //snapshot=obj
          if (snapshot.data == null ||
              snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Text("لم تقم بإضافة اخبار مفضلة "));
          } else {
            return ListView.builder(
              itemCount: this.id == 0 ? 1 : this.id,
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
                          image = snapshot.data['data'][index]['img'];

                          print("post id =$id_post");
                          if (excerpt == null || content == null) {
                            print("excerpt==null");
                          } else {
                            _showDialog(title, excerpt, content, author, image,
                                id_post, user_id);
                          }
                        },
                        child: Image.network(
                          '${snapshot.data['data'][index]['img']}',
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
                      Center(
                        child: Row(
                          textDirection: TextDirection.ltr,
                          children: [
                            FlatButton(
                              onPressed: () {
                                _unFavoritpost(
                                    snapshot.data['data'][index]['id']);
                              },
                              child: Text(
                                "حذف كمفضلة",
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
                                )),
                          ],
                        ),
                      ),
                    ],
                  )),
                );
              },
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
            // new FlatButton(
            //   child: fav ? Icon(Icons.star_border) : Icon(Icons.star),
            //   onPressed: () {
            //     if (isAuth) {
            //       _Favritpost(user_id, id_post);
            //       print("id de post =$id_post,id de user =$user_id");
            //     } else {
            //       Navigator.push(
            //           context,
            //           new MaterialPageRoute(
            //               builder: (context) => ProfilNoCnt()));
            //     }
            //   },
            // ),
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
