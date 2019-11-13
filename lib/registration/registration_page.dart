import 'package:flutter/material.dart';
import 'package:strong_buddies_connect/shared/components/custom_background.dart';
import 'package:strong_buddies_connect/shared/components/secndary_button.dart';

import 'components/selective_card.dart';
import 'gender_target.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final String user = 'Trevor';
  int _selectedGender;

  void _handleCardSelection(int selectedGender) {
    setState(() => _selectedGender =
        _selectedGender == selectedGender ? null : selectedGender);
  }

  void _goToNextSection() {
    // Navigator.of(context).push(route)
  }

  @override
  Widget build(BuildContext context) {
    final iconFile = 'assets/images/hombregris-04.png';
    final cardLabel = 'Male';
    return Scaffold(
      body: CustomBackground(
          backgroundColor: Color(0xff414042),
          backgroundImage: 'assets/images/background-login.jpg',
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 23, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 24),
                  Text(
                    'Hi, $user',
                    style: TextStyle(
                      fontSize: 28,
                      color: Color(0xffCECECE),
                    ),
                  ),
                  SizedBox(height: 80),
                  Text(
                    'Please, select your gender',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xffCECECE),
                    ),
                  ),
                  SizedBox(height: 86),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SelectiveCard(
                        isSelected: _selectedGender == 1,
                        iconFile: iconFile,
                        cardLabel: cardLabel,
                        onPressed: () => _handleCardSelection(1),
                      ),
                      SizedBox(width: 20),
                      SelectiveCard(
                        isSelected: _selectedGender == 2,
                        iconFile: 'assets/images/iconomujergris-03.png',
                        onPressed: () => _handleCardSelection(2),
                        cardLabel: 'Female',
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox()),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SecondaryButton(
                          onPressed: () {},
                          child: Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: RaisedButton(
                          disabledColor: Colors.grey,
                          onPressed: _selectedGender != null
                              ? () {
                                  Navigator.pushNamed(
                                      context, '/gender_target');
                                }
                              : null,
                          child: Text('Next'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
