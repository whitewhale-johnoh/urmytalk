import 'package:flutter/material.dart';

class YearMonthPicker extends StatefulWidget {
  @override
  _YearMonthPickerState createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  GlobalKey<FormState> _fKey = GlobalKey<FormState>();
  String yearMonthDay, timeBirth;
  TextEditingController ymdController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  bool autovalidate = false;

  yearMonthDayPicker() async {
    final year = DateTime.now().year;

    final DateTime dateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(year),
      lastDate: DateTime(year + 10),
    );

    if (dateTime != null) {
      ymdController.text = dateTime.toString().split(' ')[0];
    }
  }

  timePicker() async {
    final year = DateTime.now().year;
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

  submit() {
    setState(() => autovalidate = true);

    if (!_fKey.currentState.validate()) {
      return;
    }

    _fKey.currentState.save();

    print('year-month-day: $yearMonthDay');
    print('time: $timeBirth');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Form(
        key: _fKey,
        autovalidate: autovalidate,
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
              MaterialButton(
                onPressed: submit,
                color: Colors.indigo,
                textColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Text(
                  'Year Picker',
                  style: TextStyle(fontSize: 20.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
