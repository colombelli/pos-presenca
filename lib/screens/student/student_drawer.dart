import 'package:flutter/material.dart';
import 'package:pg_check/app_localizations.dart';
import 'package:pg_check/services/auth.dart';
import 'package:pg_check/screens/student/student_home.dart';
import 'package:pg_check/models/user.dart';
import 'package:pg_check/screens/student/temp_history.dart';

class StudentDrawer extends StatelessWidget {
  StudentDrawer(this.userInfo);
  final User userInfo;
  

  @override
  Widget build(BuildContext context) {

    final translation = (String s) => AppLocalizations.of(context).translate(s);
    final AuthService _auth = AuthService();

    Widget _createDrawerItem(
    {IconData icon, String text, Widget goToWidget}) {
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
          Navigator.popUntil(context, ModalRoute.withName('/')),
          Navigator.push(context, MaterialPageRoute(builder: (context) => goToWidget))
        }
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
            await _auth.signOut();
            Navigator.popUntil(context, ModalRoute.withName('/'));
        },
      );
    }


    return Drawer(
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
                goToWidget: StudentHome(userInfo:userInfo)),
              _createDrawerItem(
                icon: Icons.history,
                text: 'History',
                goToWidget: StudentHistoryTemp(userInfo)),
                Divider(),
              _createLogoutDrawerItem()
          ],
        ),
      );
  }
}