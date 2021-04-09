import "package:flutter/material.dart";
import "package:urmy_dev_client_v2/Auth/login.dart";
import 'package:urmy_dev_client_v2/Auth/register.dart';
import "package:urmy_dev_client_v2/providers/providers.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UrMyRegisterAdditionalPage extends StatefulWidget {
  //const UrMyRegisterAdditionalPage({Key key}) : super(key: key);
  static const String routeName = '/urmyregisterbirthdate';

  @override
  _RegisterAdditionalPageState createState() => _RegisterAdditionalPageState();
}

class _RegisterAdditionalPageState extends State<UrMyRegisterAdditionalPage> {
  //final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var _currentStep = 0;
  List<Step> steps;
  String sessionId='';
  String email = 'tgja1075@naver.com';
  String yearMonthDay = '', timeBirth = '', birthdate='';
  TextEditingController ymdController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  final formKeys = List<GlobalKey<FormState>>.generate(4, (index) => GlobalKey<FormState>());

  StepperType stepperType = StepperType.vertical;
  bool autovalidate = false;

  yearMonthDayPicker() async {
    final year = 1950;

    final DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(year),
      lastDate: DateTime(DateTime.now().year+1),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (dateTime != null) {
      ymdController.text = dateTime.toString().split(' ')[0];
    }
  }

  timePicker() async {
    String hour, min;
    final TimeOfDay pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 0, minute: 0),
    );

    if (pickedTime != null) {
      if (pickedTime.hour < 10) {
        hour = '0' + pickedTime.hour.toString();
      } else {
        hour = pickedTime.hour.toString();
      }

      if (pickedTime.minute < 10) {
        min = '0' + pickedTime.minute.toString();
      } else {
        min = pickedTime.minute.toString();
      }
      timeController.text = '$hour:$min';
    }
  }

  List<Step> makeSteps() {
    steps = [
      Step(
          title: Text("Get Ready"),
          isActive: true,
          content: Form(
              key: formKeys[0],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: yearMonthDayPicker,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: ymdController,
                          decoration: InputDecoration(
                            labelText: 'Pick Year-Month-Day',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          onSaved: (val) {
                            yearMonthDay = ymdController.text;
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Year-Month-Date is necessary';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: timePicker,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: timeController,
                          decoration: InputDecoration(
                            labelText: 'Pick Time of your birth',
                            border: OutlineInputBorder(),
                            filled: true,
                          ),
                          onSaved: (val) {
                            timeBirth = timeController.text;
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Time is necessary';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
          )
      ),
      Step(
          title: Text("Get Ready"),
          isActive: true,
          content: Form(
              key: formKeys[1],
              child: Column(children: <Widget>[
                TextFormField(
                    onSaved: (value) {

                    },
                    validator: (value) {
                      if (value.isEmpty || value.length < 2) {
                        return 'Birth month Error';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Month',
                      hintText: 'Enter your month',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    )),
              ]))),
      Step(
          title: Text("Get Ready"),
          isActive: true,
          content: Form(
              key: formKeys[2],
              child: Column(children: <Widget>[
                TextFormField(
                    onSaved: (value) {

                    },
                    validator: (value) {
                      if (value.isEmpty || value.length < 2) {
                        return 'Birth day Error';
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'day',
                      hintText: 'Enter your day',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    )),
              ])))
    ];
    return steps;
  }

  void _registersubmit() async{
    birthdate = yearMonthDay +" "+ timeBirth+":00";
    context.read(registerProvider).register(birthdate);
  }

  Widget buildBody(RegisterState registerState) {
    return Stepper(
        steps: makeSteps(),
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (!formKeys[_currentStep].currentState.validate()) {
            return;
          }
          formKeys[_currentStep].currentState.save();

          setState(() {
            if (_currentStep < steps.length - 1) {
              _currentStep = _currentStep + 1;
            } else {}
          });
        },
        onStepCancel: () {
          setState(() {
            if (_currentStep > 0) {
              _currentStep = _currentStep - 1;
            } else {
              _currentStep = 0;
            }
          });
        },
        controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
          if (_currentStep == 2) {
            return Row(children: <Widget>[
              RaisedButton(
                child: Text('Continue'),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  _registersubmit();
                  //Navigator.popUntil(context, ModalRoute.withName(UrMyLoginPage.routeName));
                  Navigator.popAndPushNamed(context, UrMyLoginPage.routeName);
                },
              ),
              SizedBox(width: 10),
              RaisedButton(
                child: Text('Prev'),
                color: Theme.of(context).primaryColor,
                onPressed: onStepCancel,
              )
            ]);
          }  else {
            return Row(children: <Widget>[
              RaisedButton(
                child: Text('NEXT'),
                color: Theme.of(context).primaryColor,
                onPressed: onStepContinue,
              ),
              SizedBox(width: 10),
              RaisedButton(
                child: Text('Prev'),
                color: Theme.of(context).primaryColor,
                onPressed: onStepCancel,
              )
            ]);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(title: Text("Flutter Playground")),
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
          )
        );
  }
}
