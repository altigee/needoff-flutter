import 'package:flutter/material.dart';
import 'package:needoff/parts/app_scaffold.dart';
// import 'package:scoped_model/scoped_model.dart';

// import 'package:needoff/app_state.dart' as appState;

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  // appState.AppStateModel _state;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   _state = ScopedModel.of<appState.AppStateModel>(context);
  // }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'command center',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/profile');
              },
              child: Text('Profile'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/leaves');
              },
              child: Text('Leaves'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/workspaces');
              },
              child: Text('Workspaces'),
            ),
            RaisedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/team_calendar');
              },
              child: Text('Team calendar'),
            ),
          ],
        ),
      ),
    );
  }
}
