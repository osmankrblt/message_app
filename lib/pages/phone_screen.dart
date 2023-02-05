import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

import 'package:message_app/constants/myGetterWidgets.dart';
import 'package:message_app/widgets/custom_button.dart';

import '../constants/utils.dart';
import '../helper/firebase_provider.dart';

class PhoneScreen extends StatefulWidget {
  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  PhoneNumber _phoneNumber = PhoneNumber(
      isoCode: WidgetsBinding.instance.window.locale.countryCode.toString());

  @override
  Widget build(BuildContext context) {
    final _isLoading =
        Provider.of<FirebaseProvider>(context, listen: true).isLoading;
    return Scaffold(
      appBar: myGetterWidgets.getAppbar("PhoneNumber Screen"),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25.0,
                      vertical: 5.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InternationalPhoneNumberInput(
                          onInputChanged: (PhoneNumber number) {
                            _phoneNumber = number;
                          },
                          selectorConfig: SelectorConfig(
                            selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          ),
                          ignoreBlank: false,
                          autoValidateMode: AutovalidateMode.disabled,
                          selectorTextStyle: TextStyle(color: Colors.black),
                          initialValue: _phoneNumber,
                          formatInput: true,
                          keyboardType: TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          inputBorder: OutlineInputBorder(),
                        ),
                        const SizedBox(
                          height: 27.0,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: CustomButton(
                            text: "Login",
                            onPressed: () => verifyNumber(
                              _phoneNumber.phoneNumber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> verifyNumber(phoneNumber) async {
    phoneNumber = phoneNumber;
    final ap = Provider.of<FirebaseProvider>(context, listen: false);

    try {
      ap.phoneVerify(context, phoneNumber);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
