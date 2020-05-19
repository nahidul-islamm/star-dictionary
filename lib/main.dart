import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star Dictionary',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Star Dictionary',),
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
  String _url="https://owlbot.info/api/v4/dictionary/";
  String _token="6f20537dcda4dacb9606b83b30339d1f82700447";

  TextEditingController _controller=TextEditingController();

  StreamController _streamController;
  Stream _stream;
  Timer timer;

  _search() async{
    if(_controller.text==null || _controller.text.length==0){
      _streamController.add(null);
      return;
    }


    _streamController.add("waiting");
    Response response = await get(_url+_controller.text.trim(), headers: {"Authorization" : "Token "+ _token});
    if(response.statusCode==200){
    _streamController.add(json.decode(response.body));
    }
  }


  @override
  void initState() {
    super.initState();
    _streamController=StreamController();
    _stream= _streamController.stream;

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Star Dictionary",textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22.0,

        ),),

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(55.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left:12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),

                  ),

                  child: TextFormField(
                    onChanged: (String text){
                      if(timer ?.isActive ?? false) timer.cancel();
                      timer =Timer(const Duration(milliseconds: 1000),(){
                        _search();
                      });
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,

                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: (){
                  _search();
                },
              )
              
            ],
            
            
          ),
        ),
      ),
      body:Container(
        margin: const EdgeInsets.all(8.0),
        child: StreamBuilder(
          stream: _stream,
          builder: (BuildContext ctx,AsyncSnapshot snapshot){
            if(snapshot.data ==null){
              return Center(
                child: Text("Enter a search word"),
              );
            }
            if(snapshot.data=="waiting"){
              return Center(
                child: CircularProgressIndicator(),

              );
            }
            return ListView.builder(
                itemCount: snapshot.data["definitions"].length,
                itemBuilder: (context,int index){
                return ListBody(

                  children: <Widget>[

                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        leading: snapshot.data["definitions"][index]["image_url"]== null ? null:
                        CircleAvatar(
                          radius: 30.0,
                          backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"],),
                        ),

                        title: snapshot.data["definitions"][index]["type"]== null ? null:Text(_controller.text.trim()+"("+snapshot.data["definitions"][index]["type"]+")\n",
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),),
                         subtitle: snapshot.data["definitions"][index]["example"] ==null ? null:Text(
                         (snapshot.data["definitions"][index]["definition"]+"\n \nExample: "+snapshot.data["definitions"][index]["example"]),style: TextStyle(
                           fontSize: 15.0,
                           color: Colors.black,
                         ),),
                        onTap: (){},


                      ),
                    ),

                    Divider(
                      color: Colors.teal,
                      height: 25.0,
                      thickness: 1.0,
                    ),
//                    Padding(
//                      padding: const EdgeInsets.only(top:5.0,bottom: 5.0),
//
//                      child: Text(""),
//                    )
                  ],
                );
            });
          },
        ),
      )

    );
  }
}
