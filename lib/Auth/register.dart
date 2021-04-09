import "package:flutter/material.dart";
import "package:urmy_dev_client_v2/Auth/login.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urmy_dev_client_v2/providers/providers.dart';
import "package:urmy_dev_client_v2/Auth/register_additional.dart";
import 'package:image_picker/image_picker.dart';
import 'dart:io';

enum Gender {MAN, WOMEN}

class UrMyRegisterPage extends StatefulWidget {
  static const String routeName = '/urmyregister';
  //const UrMyRegisterPage({Key key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<UrMyRegisterPage> {
  final GlobalKey<FormState> _registerformKey = GlobalKey<FormState>();
  String email;
  String password;
  String nickname;
  String name;
  String phoneNo;
  Gender gender = Gender.MAN;
  bool _agreedToTOS = true;

  Widget buildBody(RegisterState registerState) {
    return SingleChildScrollView(
      child: new Container(
          child: Form(
              key: _registerformKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  imageProfile(),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (String value){
                      if (value.trim().isEmpty) {
                        return 'Email is required';
                      }
                    },
                    onSaved: (value) => email = value,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'NickName',
                    ),
                    validator: (String value){
                      if (value.trim().isEmpty) {
                        return 'Nickname is required';
                      }
                    },
                    onSaved: (value) => nickname = value,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                    validator: (String value){
                      if (value.trim().isEmpty) {
                        return 'Name is required';
                      }
                    },
                    onSaved: (value) => name = value,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    validator: (String value) {
                      if(value.trim().isEmpty) {
                        return 'Full name is required';
                      }
                    },
                    onSaved: (value) => password = value,
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    validator: (String value) {
                    //  if (password != value) {
                    //    return "Password is different";
                    //  }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    validator: (String value) {
                      if(value.trim().isEmpty) {
                        return 'Phone Number is required';
                      }
                    },
                    onSaved: (value) => phoneNo = value,
                  ),
                  const SizedBox(height: 16.0),
                  ListTile(
                    title: Text('Male'),
                    leading: Radio(
                      value: Gender.MAN,
                      groupValue: gender,
                      onChanged: (value){
                        setState((){
                          gender = value;
                        });
                      },
                    )
                  ),
                  ListTile(
                      title: Text('Female'),
                      leading: Radio(
                        value: Gender.WOMEN,
                        groupValue: gender,
                        onChanged: (value){
                          setState((){
                            gender = value;
                          });
                        },
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                          children: <Widget>[
                            Checkbox(
                                value: _agreedToTOS,
                                onChanged: _setAgreedToTOS
                            ),
                            GestureDetector(
                                onTap: () => _setAgreedToTOS(!_agreedToTOS),
                                child: const Text(
                                    'I agreed to the Terms of Service and Privacy Policy'
                                )
                            )
                          ]
                      )
                  ),
                  Row (
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new RaisedButton(
                        child: new Text(
                          'Confirm',
                          style: new TextStyle(fontSize: 20.0),
                        ),
                        onPressed: (){
                          _registersubmit();
                              Navigator.pushNamed(context, UrMyRegisterAdditionalPage.routeName);
                        },
                        // onPressed: UrMyRegister(),
                      ),
                      new RaisedButton(
                        child: new Text(
                          'Cancel',
                          style: new TextStyle(fontSize: 20.0),
                        ),
                        onPressed: (){
                          Navigator.popAndPushNamed(context, UrMyLoginPage.routeName);
                        },
                        // onPressed: UrMyRegister(),
                      ),
                    ],
                  )
                ],
              )
          )
      ),
    );
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 80,
            backgroundImage: context.read(registerProvider).state.imageFile == null ? AssetImage('assets/images/native_profile.png') : FileImage(File(context.read(registerProvider).state.imageFile.path)),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: InkWell(
              onTap: () {
                showModalBottomSheet(context: context, builder: ((builder) => bottomSheet()));
              },
              child: Icon(
                Icons.camera_alt,
                color: Colors.redAccent.withOpacity(0.3),
                size: 40,
              )
            )
          )
        ],
      )
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20
      ),
      child: Column(
        children: <Widget>[
          Text(
              'Choose Profile photo',
              style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(height: 20, ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.camera, size: 50,),
                  onPressed: (){
                    context.read(registerProvider).takePhoto(ImageSource.camera);
                  },
                  label: Text('Camera', style: TextStyle(fontSize:20),),
                ),
              FlatButton.icon(
                  icon: Icon(Icons.photo_library, size:50,),
                  onPressed: (){
                    context.read(registerProvider).takePhoto(ImageSource.gallery);
                  },
                  label: Text('Gallery', style: TextStyle(fontSize: 20),),
              )
            ],
          )
        ]
      )
    );
  }



  @override
  Widget build(BuildContext context) {
      return new Scaffold(
          appBar: new AppBar(
            title: new Text('Register demo'),
          ),
          body: ProviderListener<RegisterState>(
            provider: registerStateProvider,
            onChange: (context, state) {
              //         if (context.read(appConfigProvider).state.buildFlavor == 'dev') {
              print('---- state ----');
              print('registeredIn: ${state.registeredIn}');
              print('error: ${state.error}');
              //         }

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
                  watch(registerStateProvider),
                );
              },
            ),
          ),
      );
  }

  bool _submittable() {
    return _agreedToTOS;
  }

  void _registersubmit() {
    //setState(() => _autovalidateMode = AutovalidateMode.always);
    final form = _registerformKey.currentState;
    if (!form.validate()) return;

    form.save();
    print('email: $email, password: $password');
    context.read(registerProvider).setPersonalData(email, password, nickname, name, phoneNo, gender);
  }

  void _setAgreedToTOS(bool newValue){
    setState((){
      _agreedToTOS = newValue;
    });
  }
}