import 'dart:math';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { SignUp, Login }
enum PasswordView { InView, Hidden }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                    Color.fromRGBO(255, 118, 117, 1).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 1]),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                      ),
                      width: deviceSize.width - 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      child: Text(
                        'My Shop',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(
                      deviceSize: deviceSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  final Size deviceSize;
  const AuthCard({
    Key key,
    @required this.deviceSize,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  AuthMode _authMode = AuthMode.Login;
  bool _isLoading = false;
  bool _passwordHasValue = false;
  PasswordView _passwordView = PasswordView.Hidden;
  final _passwordController = TextEditingController();
  Map<String, String> _authData = {'email': '', 'password': ''};
  final GlobalKey<FormState> _formKey = GlobalKey();

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  void _togglePasswordView() {
    if (_passwordView == PasswordView.Hidden) {
      setState(() {
        _passwordView = PasswordView.InView;
      });
    } else {
      setState(() {
        _passwordView = PasswordView.Hidden;
      });
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occured!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Okay'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isLoading = true;
      });
      try {
        if (_authMode == AuthMode.Login) {
          await Provider.of<Auth>(context, listen: false)
              .login(_authData['email'], _authData['password']);
        } else {
          await Provider.of<Auth>(context, listen: false)
              .signup(_authData['email'], _authData['password']);
        }
      } on HttpException catch (error) {
        var errorMessage = 'An error occured, please try again later';
        if (error.toString().contains('EMAIL_EXISTS')) {
          errorMessage = 'User with the email provided already exists.';
        } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
          errorMessage =
              'Couldn\'t login, User with email address does\'nt exist!';
        } else if (error.toString().contains('INVALID_PASSWORD')) {
          errorMessage = 'Invalid Password! Please try again';
        } else if (error.toString().contains('WEAK_PASSWORD')) {
          errorMessage = 'This password is too weak';
        } else if (error.toString().contains('INVALID_EMAIL')) {
          errorMessage = 'Please enter a valid email address';
        }
        showErrorMessage(errorMessage);
      } catch (error) {
        const errorMessage =
            'Couldn\'t connect to server, please try again later!';
        showErrorMessage(errorMessage);
      }
      setState(() {
        _isLoading = false;
      });
    } else
      return;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 320 : 260),
        width: widget.deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  //for the email
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'E-mail'),
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid e-mail address';
                    }
                    return null;
                  },
                  onSaved: (value) => _authData['email'] = value,
                ),
                Stack(
                  alignment: Alignment.centerRight,
                  children: <Widget>[
                    TextFormField(
                      onChanged: (_) {
                        setState(() {
                          _passwordHasValue = true;
                        });
                      },
                      //for the password
                      controller: _passwordController,
                      obscureText:
                          _passwordView == PasswordView.Hidden ? true : false,
                      decoration: InputDecoration(labelText: 'Password'),
                      validator: (value) {
                        if (value.isEmpty || value.length <= 5) {
                          return 'Password is too short';
                        }
                        return null;
                      },
                      onSaved: (value) => _authData['password'] = value,
                    ),
                    IconButton(
                      icon: Icon(_passwordView == PasswordView.Hidden
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: _passwordHasValue ? _togglePasswordView : null,
                    )
                  ],
                ),
                if (_authMode == AuthMode.SignUp)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    //enabled: _authMode == AuthMode.SignUp,
                    obscureText: true,
                    validator: _authMode == AuthMode.SignUp
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                            return null;
                          }
                        : null,
                  ),
                SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    onPressed: _submit, //back for _submit
                    child: Text(
                        _authMode == AuthMode.SignUp ? 'SIGN UP' : 'LOGIN'),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Theme.of(context).primaryColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGN UP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode, //switch authmode
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 30),
                  textColor: Theme.of(context).primaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
