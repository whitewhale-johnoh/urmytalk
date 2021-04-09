import "package:flutter/material.dart";
import 'package:urmy_dev_client_v2/Auth/register.dart';
import 'package:urmy_dev_client_v2/urmybook/urmybook.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';

import 'package:urmy_dev_client_v2/Controller/notificationControllers.dart';

class UrMyLoginPage extends StatefulWidget {
  static const String routeName = '/login';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<UrMyLoginPage> {
  final formKey = new GlobalKey<FormState>();

  //AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String _email;
  String _password;

  //var logindata = Map<String, String>();

  void initState() {
    super.initState();
    _checkPermissions();
    NotificationController.instance.takeFCMTokenWhenAppLaunch();
    NotificationController.instance.initLocalNotification();
    _checkAutoLogin();
  }

  _checkPermissions() async {
    //Map<Permission, PermissionStatus> statuses =
    await [Permission.contacts].request();
    //print(statuses[Permission.contacts]);
    if (await Permission.contacts.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  _checkAutoLogin() async {
    await context.read(authProvider).checkAutoLogin(await context.read(authProvider).tryAutoLogin());
  }

  void submit() {
    //setState(() => _autovalidateMode = AutovalidateMode.always);
    final form = formKey.currentState;
    if (!form.validate()) return;
    form.save();
    /*if (context.read(appConfigProvider).state.buildFlavor == 'dev') {
    print('email: $_email, password: $_password');
    }*/
    context.read(authProvider).login(_email, _password);
  }

  Widget buildBody(AuthState authState) {
    if (authState.autoLogin) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (authState.authenticated) {
      return Center(
        child: Text(
          'Splash Screen',
          style: TextStyle(fontSize: 20.0),
        ),
      );
    }


    return Padding(
      //padding: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: EdgeInsets.all(16),
      child: new Form(
        key: formKey,
        child: new ListView(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new TextFormField(
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
              //  initialValue: authState.registered ? logindata['loginId'] : "",
              validator: (value) {
                if (value.isEmpty) {
                  return 'Password can\'t be empty';
                }
                if (!value.contains('@')) {
                  return 'Invalid email';
                }
                return null;
              },
              onSaved: (value) => _email = value,
            ),
            new TextFormField(
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              //  initialValue: authState.registered ? logindata['password'] : "",
              validator: (value) {
                value = value.trim();
                if (value.isEmpty) {
                  return 'Password required';
                }
                if (value.length < 8) {
                  return 'Password must be longer than 8';
                }
                return null;
              },
              onSaved: (value) => _password = value,
            ),
            new RaisedButton(
              onPressed: () {
                submit();
                Future.delayed(Duration(seconds: 2), () {
                  if (context.read(authProvider).state.authenticated) {
                    Navigator.popAndPushNamed(context, UrMyBookPage.routeName);
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text("Login Failed"),
                        );
                      },
                    );
                  }
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: authState.loggingIn
                    ? SizedBox(
                        width: 25,
                        height: 25,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'LOGIN',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            new RaisedButton(
              child: new Text(
                'Register',
                style: new TextStyle(fontSize: 20.0),
              ),
              onPressed: () {
                Navigator.pushNamed(context, UrMyRegisterPage.routeName);
              }, // onPressed: UrMyRegister(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('login demo'),
      ),
      body: ProviderListener<AuthState>(
        provider: authStateProvider,
        onChange: (context, state) {
          if (state.authenticated == true) {
            Navigator.popAndPushNamed(context, UrMyBookPage.routeName);
          }
          if (state.error != null && state.error.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(state.error),
                );
              },
            );
          }
        },
        child: Consumer(
          builder: (context, watch, child) {
            return buildBody(
              watch(authStateProvider),
            );
          },
        ),
      ),
    );
  }
}
