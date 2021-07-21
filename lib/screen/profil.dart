import 'dart:convert';

import 'package:Arabi21Login/network_utils/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Favorites.dart';
import 'login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Profil extends StatefulWidget {
  @override
  final user_id;

  const Profil({this.user_id});
  int get _user_id {
    return this.user_id;
  }

  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  @override
  int item;
  _getdDataCount() async {
    var respe = await http.get("http://192.168.43.22:8000/api/CountData/$id");
    Map jsonData = json.decode(respe.body) as Map;
    this.item = jsonData['data'];
    print("la valeur de item =$item");
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.grey, Colors.pinkAccent])),
              child: Container(
                width: double.infinity,
                height: 722.0364,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          "https://cdn.dribbble.com/users/29574/screenshots/4826855/avatar_-_og_-_dribbble.png",
                        ),
                        radius: 100.0,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "$name $lname ",
                        style: TextStyle(
                          fontSize: 22.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 70.0,
                      ),
                      RaisedButton(
                          onPressed: () {
                            _getdDataCount();
                            print("la vae de item$item");

                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => FavoriteScrenne(
                                          id: item,
                                        )));
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)),
                          elevation: 0.0,
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [Colors.pink, Colors.pinkAccent]),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: 300.0, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Row(children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "الأخبـــار المفضلة",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.0,
                                      fontFamily: 'jalah',
                                      fontWeight: FontWeight.w300),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                ),
                              ]),
                            ),
                          )),
                      SizedBox(
                        height: 70,
                      ),
                      RaisedButton(
                          onPressed: () {
                            logout();
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0)),
                          elevation: 0.0,
                          padding: EdgeInsets.all(0.0),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [Colors.pink, Colors.pinkAccent]),
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: 300.0, minHeight: 50.0),
                              alignment: Alignment.center,
                              child: Container(
                                child: Text(
                                  "تسجيل الخروج",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26.0,
                                      fontFamily: 'jalah',
                                      fontWeight: FontWeight.w300),
                                ),
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  _loadUserData() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var user = jsonDecode(localStorage.getString('user'));

    if (user != null) {
      setState(() {
        name = user['name'];
        mail = user['email'];
        lname = user['last_name'];
        id = user['id'];
      });
    }
  }

  String name, mail, lname, avatar;
  int id;
  @override
  void initState() {
    _loadUserData();
    super.initState();
  }

  void logout() async {
    var res = await Network().getData('/logout');
    var body = json.decode(res.body);
    if (body['success']) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.remove('user');
      localStorage.remove('token');
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
    }
  }
}
