import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:needoff/app_state.dart' as appState;
import 'package:needoff/screens/leaves_screen.dart';
import 'package:needoff/screens/sick_leaves_screen.dart';
import 'package:needoff/screens/vac_leaves_screen.dart';
import 'package:needoff/screens/wfh_leaves_screen.dart';
import 'package:needoff/screens/start_screen.dart';
import 'package:needoff/screens/login_screen.dart';
import 'package:needoff/screens/registration_screen.dart';
import 'package:needoff/screens/forgot_password_screen.dart';
import 'package:needoff/screens/profile_screen.dart';
import 'package:needoff/screens/profile_edit_screen.dart';
import 'package:needoff/screens/workspaces_screen.dart';
import 'package:needoff/screens/workspace_edit_screen.dart';

final Model appStateModel = appState.AppStateModel();
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<appState.AppStateModel>(
      model: appStateModel,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: Theme.of(context).copyWith(
          primaryColor: Color(0xff030322),
          accentColor: Color(0xffff0033),
          textTheme:
              Theme.of(context).textTheme.apply(fontFamily: 'Montserrat'),
        ),
        routes: {
          '/': (BuildContext context) => Root(),
          '/profile': (BuildContext context) => ProfileScreen(),
          '/profile/edit': (BuildContext context) => ProfileEditScreen(),
          '/leaves': (BuildContext context) => LeavesScreen(),
          '/leaves/sick': (BuildContext context) => SickLeavesScreen(),
          '/leaves/vac': (BuildContext context) => VacLeavesScreen(),
          '/leaves/wfh': (BuildContext context) => WfhLeavesScreen(),
          '/registration': (BuildContext context) => RegistrationScreen(),
          '/forgot-pwd': (BuildContext context) => ForgotPasswordScreen(),
          '/workspaces': (BuildContext context) => WorkspacesScreen(),
          '/workspace-edit': (BuildContext context) => WorkspaceEditScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}

class Root extends StatefulWidget {
  Root({Key key}) : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  var _state, _profileFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = ScopedModel.of<appState.AppStateModel>(context);
    _profileFuture = _state.fetchProfile();
    // _state.addListener((){
    //   setState(() {

    //   });
    // });
  }

  get _body {
    Widget body;
    if (_state.profile == null) {
      body = LoginScreen();
    } else {
      print('***HAS PROFILE***');
      print(_state.profile.name);
      body = StartScreen();
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _profileFuture,
        builder: (context, snapshot) {
          return ScopedModelDescendant<appState.AppStateModel>(
            builder: (ctx, child, state) {
              return _body;
            },
          );
        });
  }
}
