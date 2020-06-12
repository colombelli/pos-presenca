import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/shared/loading.dart';



class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}





class StudentHome extends StatefulWidget {

  final User userInfo;
  const StudentHome ({ Key key, this.userInfo}): super(key: key);

  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final AuthService _auth = AuthService();



  Widget bodyWidget;
  @override
    void initState() { 
      super.initState();
      bodyWidget = Text("some home content here");
    }

  @override
  Widget build(BuildContext context) {
    

    final translation = (String s) => AppLocalizations.of(context).translate(s);
    

    Widget _createDrawerItem(
    {IconData icon, String text, Widget newBodyWidget}) {
      return ListTile(
        title: Row(
          children: <Widget>[
            Icon(icon),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(text),
            )
          ],
        ),
        onTap: () => {
          setState(() {
            bodyWidget = newBodyWidget;
          })
        },
      );
    }
    
    Widget _createLogoutDrawerItem() {
      return ListTile(
        title: Row(
          children: <Widget>[
            Icon(Icons.exit_to_app),
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(translation('logout_button')),
            )
          ],
        ),
        onTap:
          () async{
            setState(() {
              bodyWidget = Loading();
            });
            await _auth.signOut();
        },
      );
    }


    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.blue[50],
      endDrawer: new Drawer(
        child: ListView(
        padding: EdgeInsets.zero,
        children: [
              DrawerHeader(
                  child: Text(""),
                  decoration: BoxDecoration(
                    color: Colors.blue[400]
                    )
                 ),
              _createDrawerItem(
                icon: Icons.home,
                text: 'Home',
                newBodyWidget: new Text("some home content here")),
              _createDrawerItem(
                icon: Icons.history,
                text: 'History',
                newBodyWidget: new Text("history here")),
                Divider(),
              _createLogoutDrawerItem()
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(translation('home_title')),
        backgroundColor: Colors.blue[400],
        elevation: 0.0,

        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState.openEndDrawer()
          )
        ]
      ),
      body: bodyWidget,
    );
  }
}
