import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:needoff/config.dart' show appConfig;

import 'package:needoff/app_state.dart' as appState;
import 'package:needoff/parts/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  var _state;

  TextEditingController _loginCtrl = TextEditingController(text: 'nmarchuk@altigee.com');
  TextEditingController _pwdCtrl = TextEditingController(text: 'ssssss');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = ScopedModel.of<appState.AppStateModel>(context);
  }

  void _loading(bool val) {
    setState(() {
      _isLoading = val;
    });
  }

  void _snack(String text) {
    Scaffold.of(_formKey.currentContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future _handleLogin() async {
    if (_formKey.currentState.validate()) {
      _loading(true);
      _state.profile =
          await appState.auth.signIn(_loginCtrl.text, _pwdCtrl.text);
      if (_state.profile == null) {
        _snack('Failed to load user :(');
      }
      _loading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      'login(${appConfig.get('env')})',
      body: Center(
        child: SingleChildScrollView(
                  child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              // autofocus: true,
                              decoration: InputDecoration(labelText: 'Email'),
                              controller: _loginCtrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your email.";
                                }
                              },
                            ),
                            TextFormField(
                              obscureText: true,
                              decoration: InputDecoration(labelText: 'Password'),
                              controller: _pwdCtrl,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Please enter your password.";
                                }
                              },
                            ),
                          ],
                        )),
                  ),
                  RaisedButton(
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    onPressed: _isLoading ? null : _handleLogin,
                    child: Text('Login'),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: Row(
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context)
                                .textTheme
                                .overline
                                .apply(fontFamily: 'Orbitron'),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/forgot-pwd');
                          },
                        ),
                        FlatButton(
                          child: Text(
                            'Create Account',
                            style: Theme.of(context)
                                .textTheme
                                .overline
                                .apply(fontFamily: 'Orbitron'),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/registration');
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}