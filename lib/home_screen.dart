import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_ppicker/image_picker_handler.dart';
import 'package:flutter_image_ppicker/image_picker_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http ;

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin,ImagePickerListener{

  var controller0 = new TextEditingController();
  var controller1 = new TextEditingController();
  var controller2 = new TextEditingController();
  var controller3 = new TextEditingController();
  File _image;
  AnimationController _controller;
  ImagePickerHandler imagePicker;
  String printValue = "jahsdkjhaksjahskjh";
  double SIZE = 500.0;
  FirebaseAuth mAuth;
  DatabaseReference mDatabase;
  FirebaseStorage mStorage;
  IconData icon = Icons.camera;
  String _string = "Choose menu";
  String _string1 = "Choose location";
  FloatingActionButtonLocation floatingActionButtonLocation = FloatingActionButtonLocation.centerDocked;

  void returnFunction(){
      if(_image == null){
        imagePicker.showDialog(context);
      }
      else {
        _neverSatisfied();
//        print(showServerResult());
      }

  }
  

  @override
  void initState() {
    super.initState();

      _controller = new AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      );
      imagePicker = new ImagePickerHandler(this, _controller);
      imagePicker.init();
  }
  File getPicture(){
    return _image;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    mAuth = FirebaseAuth.instance;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title,
        style: new TextStyle(
          color: Colors.white
        ),
        ),
      ),
        floatingActionButton: FloatingActionButton(onPressed:  returnFunction,
        child: _image == null ? Icon(icon) : Icon(Icons.send),
        ),
        floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new IconButton(icon: new Icon(Icons.menu), onPressed:(){_neverSatisfied();}),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: 1,
          itemBuilder: (BuildContext context , int index){
            return Column(
              children: <Widget>[new GestureDetector(
                child: new Center(
                    child: _image == null
                        ? new Stack(
                      children: <Widget>[

                        new Center(

                        )
                      ],
                    )
                        : Column(
                        children :<Widget>[ new Container(
                          height:SIZE-150,
                          width: double.infinity,
                          decoration: new BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: new DecorationImage(
                              image: new ExactAssetImage(_image.path),
                              fit: BoxFit.cover,
                            ),
//                border:
//                Border.all(color: Colors.red, width: 5.0),
//                borderRadius:
//                new BorderRadius.all(const Radius.circular(80.0)),
                          ),
                        )

                        ]
                    )
                ),

              ),
              new DropdownButton<String>(
                items: <String>['Jobs', 'Scholarships', 'Tender', 'Private' , 'Announcements'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                hint: Text(_string),
                onChanged: (value){
                  this.setState((){
                    _string = value;

                  });
                },
              ),
              TextFormField(
                controller: controller1,
                decoration: InputDecoration(
                    labelText: 'Title'
                ),
              ),
              TextFormField(
                controller: controller0,
                decoration: InputDecoration(
                    labelText: 'Description'
                ),
              ),

              new DropdownButton<String>(
                items: <String>['Federal', 'Baluchistan', 'Sindh', 'KPK' , 'Punjab'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                hint: Text(_string1),
                onChanged: (value){
                  this.setState((){
                    _string1 = value;

                  });
                },
              ),
              ],
            );
          },
      )
      ,
    );
  }
  Future<void> _neverSatisfied() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rewind and remember'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure about uploading data?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                showServerResult();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            }),
          ],
        );
      },
    );
  }
  Widget dailogShow(){
    print("aksjdakjsdhakjh");
    return Dialog();
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
      floatingActionButtonLocation = FloatingActionButtonLocation.endDocked;
    });
  }
  returnModelName(String name){
    setState(() {
      this.printValue = name;
      SIZE = 300.0;
//      _image = null;
    });
  }

  Future<String> showServerResult() async{
    if(_image != null && controller0.text != "" && _string1 != "Choose location" && controller1.text != "" && _string != "Choose menu") {
      mDatabase = FirebaseDatabase.instance.reference().child(_string).push();
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref()
          .child(path.basename(_image.path));
      final StorageUploadTask task = firebaseStorageRef.putFile(_image);
      var dowurl = await (await task.onComplete).ref.getDownloadURL();
      String url = dowurl.toString();
      mDatabase.child("description").set(controller0.text);
      mDatabase.child("title").set(controller1.text);
      mDatabase.child("location").set(_string1);
      mDatabase.child("date").set(DateTime.now());
      mDatabase.child("imageLink").set(url);
      setState(() {
        floatingActionButtonLocation = FloatingActionButtonLocation.centerDocked;
        controller0.text = "";
        controller1.text = "";
        controller2.text = "";
        controller3.text = "";
        _string = "Choose menu";
        _string1 = "Choose location";
        _image = null;
      });
      print (url);
    }
    else if(_image == null && controller0.text != "" && _string1 != "Choose location" && controller1.text != "" && controller2.text != "" &&_string != "Choose menu"){
      mDatabase = FirebaseDatabase.instance.reference().child(_string).push();
      mDatabase.child("discription").set(controller0.text);
      mDatabase.child("title").set(controller1.text);
      mDatabase.child("location").set(_string1);
      mDatabase.child("date").set(DateTime.now());
      mDatabase.child("imageLink").set("");
      setState(() {
        floatingActionButtonLocation = FloatingActionButtonLocation.centerDocked;
        controller0.text = "";
        controller1.text = "";
        controller2.text = "";
        controller3.text = "";
        _string = "Choose menu";
        _string1 = "Choose location";
        _image = null;
      });
//      mDatabase = FirebaseDatabase.instance.reference().child(_string).push();
    }
//   Storage = FirebaseStorage.instance;
  }

}
//uploadImageThroughhttp